package com.asterdata.sentiment;

import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import com.aliasi.classify.Classification;
import com.aliasi.classify.Classified;
import com.aliasi.classify.DynamicLMClassifier;
import com.aliasi.lm.NGramProcessLM;
import com.asterdata.mapreduce.io.FileFormatType;

/**
 * ClassifierTrain map/reduce job allows to train Lingpipe statistical model for ClassifierEvaluate module. 
 * Before running ClassifierTrain, it is necessary to run the ClassifierDataModelBuilder first in order 
 * to massage the data for this module to work.  When running ClassifierTrain, it is possible to train the 
 * Lingpipe model on subset of the input data by specifying sampling parameter named: "sampleRows". 
 * Please refer to the usage description for all the details on how to run this map/reduce job.
 *  
 * 
 * Usage example:
 *  hadoop jar aster-mr.jar com.asterdata.sentiment.ClassifierTrain evaluateFileLoc=/data/classifier/model/part* 
 *    evaluateFileDelimiter=| categoryFieldPos=2 contentFieldPos=3 categories=true,false  
 *    modelFileLoc=/data/classifier/train sampleRows=1-100000 debug=true
 * 
 * 
 * Required job arguments:
 *   evaluateFileLoc  --> HDFS path to the file that was generate by ClassifierModelBuilder
 *   categoryFieldPos --> position of the category field in the training file 
 *   contentFieldPos --> position of the content field in the training file
 *   categories --> category field values from the training file
 *   modelFileLoc --> HDFS path to model file that this job will generate
 *   
 *   
 * Optional job arguments
 *   inputFileFormat --> either text or sequence.  if not specified text by default
 *   sampleRows --> which sample row numbers to process for example sampleRows=1-1000
 *   debug --> true/false if to run in debug mode  
 * 
 * @author mmichalski
 */

public class ClassifierTrain extends Configured implements Tool {
	
	public static enum ClassifierTrainCounter {
		SAMPLE_MATCH,SAMPLE_NON_MATCH;
	}
	
	public static class ClassifierMapper extends Mapper<Writable, Text, NullWritable, Text> {
		private boolean debug = false;
		private boolean useSampling = false;
		private long fromRowNum = 0;
		private long toRowNum = 0;
		
		@Override
		public void setup(Context context) {
			Configuration conf = context.getConfiguration();
			
			debug = conf.getBoolean(ClassifierArg.debug.name(), false);
			
			String sampleRows = conf.get(ClassifierArg.sampleRows.name());
			if(sampleRows != null) {
				useSampling = true;
				int indx = sampleRows.indexOf("-");
				if(indx == -1) {
					throw new RuntimeException("Incorrect \"sampleRows\" argument values encountered!" 
							+ " Please make su to pass \"sampleRows=1000000-2000000\"");
				}

				fromRowNum = Long.parseLong(sampleRows.substring(0,indx));
				toRowNum = Long.parseLong(sampleRows.substring(indx+1));
				
				if(debug) {
					System.out.println("useSampling...fromRowNum: " + fromRowNum + " toRowNum: " + toRowNum);
				}
			}
		}
		
		@Override
		public void map(Writable key, Text value, Context context) throws IOException, InterruptedException {
			
			//Sampling logic is enabled, so make sure we only go a
			if(useSampling) {
				long rowNum = Long.parseLong(key.toString());
				if(rowNum < fromRowNum || rowNum > toRowNum) {
					context.getCounter(ClassifierTrainCounter.SAMPLE_NON_MATCH).increment(1);
					return;
				}
			} 
			
			context.getCounter(ClassifierTrainCounter.SAMPLE_MATCH).increment(1);
			context.write(NullWritable.get(), value);
		}
	}
	
	public static class ClassifierReducer extends Reducer<NullWritable, Text, NullWritable, Text> {
		private boolean debug = false;
		private int categoryFieldPos;
		private int contentFieldPos;
		private String[] categoryArray;
		private Map<String,String> categories;
		private String modelFile;
		private String delimiter;
		private Text valueOut = new Text();
		
		@Override
		public void setup(Context context) {
			Configuration conf = context.getConfiguration();
			debug = conf.getBoolean(ClassifierArg.debug.name(), false);
			delimiter = conf.get(ClassifierArg.evaluateFileDelimiter.name());
			categoryFieldPos = conf.getInt(ClassifierArg.categoryFieldPos.name(), 1)-1;
			contentFieldPos = conf.getInt(ClassifierArg.contentFieldPos.name(), 1)-1;
			categoryArray = conf.get(ClassifierArg.categories.name()).split(",");
			modelFile = context.getConfiguration().get(ClassifierArg.modelFileLoc.name())
					+ "/sentiment.model";
			
			if(debug) {
				System.out.println("evaluateFileDelimter: [" + delimiter + "]");
			}
			
			categories = new HashMap<String, String>(categoryArray.length);
			for(String category: categoryArray) {
				if(debug) {
					System.out.println("adding: " + category + " to categories Map");
				}
				categories.put(category, category);
			}
		}
		
		private int cntr;
		@Override
		public void reduce(NullWritable key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
			DynamicLMClassifier<NGramProcessLM> mClassifier;
	        int nGram = 8;
	        mClassifier = DynamicLMClassifier.createNGramProcess(categoryArray, nGram);
	        Classification classification;
	        
	        Map<String, Classification> classificationMap = new HashMap<String, Classification>();
	        String[] classifierInputs;
	        String content;
	        String category;
	        
	        if(debug) {
	        	System.out.println("ClassifierTrain.reduce: looping through inputs");
	        }
	        
	        //Loop through all the values for the same key
	        for(Text value: values) {
	        	classifierInputs = value.toString().split(delimiter);
	        	if(debug && cntr < 10) {
	        		System.out.println("input key: ["+key.toString()+"]");
	        		System.out.println("input value: ["+value.toString()+"]");
	        		System.out.println("number of input values: " + classifierInputs.length);
	        	}
	        	
	        	category = classifierInputs[categoryFieldPos];
	        	content = classifierInputs[contentFieldPos];
	        	
	        	if(debug && cntr < 10) {
	        		System.out.println("category: [" + category + "]");
	        		System.out.println("content: [" + content + "]");
	        	}
	        	
	        	// Check if the category in the current row was specified in the MR arguments
	        	if(categories.containsKey(category)) {
	        		// Check inside hashmap to see if we've already created a classification for this category.
					// Create one if it doesn't already exist.
					if (!classificationMap.containsKey(category)) {
						classificationMap.put(category, new Classification(category));
					}
					classification = classificationMap.get(category);
					Classified<CharSequence> classified = new Classified<CharSequence>(content,classification);
	                mClassifier.handle(classified);
	        	}
	        	cntr ++;
	        }
	        
	        if(debug) {
	        	System.out.println("ClassifierTrain.reduce: done looping through inputs");
	        }
	        
	        
	        // Serialize classifier model object into a file and write it to HDFS.
			ObjectOutputStream oos = null;
			FileSystem hdfs = null;
			try {
				//Create a new file in hdfs manually
				hdfs = FileSystem.get(context.getConfiguration());
				Path modelFileHDFSLoction = new Path(modelFile);
				
				if(debug) {
					System.out.println("ClassifierTrain.reduce: creating model file in HDFS");
				}
				oos = new ObjectOutputStream(hdfs.create(modelFileHDFSLoction));
		        if(debug) {
		        	System.out.println("ClassifierTrain.reduce: done creating model file in HDFS");
		        }
		        
		        if(debug) {
		        	System.out.println("ClassifierTrain.reduce: compiling model to ObjectOutputStream");
		        }
		        mClassifier.compileTo(oos);
		        if(debug) {
		        	System.out.println("ClassifierTrain.reduce: done compiling model to ObjectOutputStream");
		        }
		        
				@SuppressWarnings("deprecation")
				long fileSize = hdfs.getLength(modelFileHDFSLoction);
				if(debug) {
					System.out.println("written following file to HDFS: " + modelFile + " size: " + fileSize/1024/1024 + "MB");
				}
				
				valueOut.set("Created following model file in HDFS: " + modelFile + "size: " + fileSize/1024/1024 + "MB");
			} catch(IOException ioe) {
				valueOut.set("Unable to create model file in HDFS, error message: " + ioe.getMessage());
				throw ioe;
			} finally {
				try {
					oos.close();
				} catch(Exception e) {}
			}
			
			context.write(NullWritable.get(), valueOut);
		}
	}
	
	public int run(String[] args) throws Exception {
		Map<ClassifierArg, String> jobArgs = getInputArguments(args);
		Configuration conf = getConf();
		boolean debug = false;
		boolean compress=false;
		
		conf.setInt(ClassifierArg.categoryFieldPos.name(), Integer.parseInt(
				jobArgs.get(ClassifierArg.categoryFieldPos)));
		conf.setInt(ClassifierArg.contentFieldPos.name(), Integer.parseInt(
				jobArgs.get(ClassifierArg.contentFieldPos)));
		conf.set(ClassifierArg.categories.name(), jobArgs.get(ClassifierArg.categories));
		conf.set(ClassifierArg.modelFileLoc.name(), jobArgs.get(ClassifierArg.modelFileLoc));
		conf.set(ClassifierArg.evaluateFileDelimiter.name(), jobArgs.get(ClassifierArg.evaluateFileDelimiter));
		
		if(jobArgs.containsKey(ClassifierArg.sampleRows)) {
			conf.set(ClassifierArg.sampleRows.name(), jobArgs.get(ClassifierArg.sampleRows));
		}
		if(jobArgs.containsKey(ClassifierArg.debug)) {
			debug = Boolean.valueOf(jobArgs.get(ClassifierArg.debug));
			conf.setBoolean(ClassifierArg.debug.name(), debug);
		}
		
		//Enable Compression
		if(jobArgs.containsKey(ClassifierArg.compress)) {
			compress = Boolean.valueOf(jobArgs.get(ClassifierArg.compress));
		}
		conf.setBoolean("mapred.output.compress", compress);
		conf.setBoolean("mapred.compress.map.output", compress);
		
		if(debug) {
			System.out.println("evaluateFileLoc: " + jobArgs.get(ClassifierArg.evaluateFileLoc));
			System.out.println("evaluateFieldDelimiter: " + jobArgs.get(ClassifierArg.evaluateFileDelimiter));
			System.out.println("sampleRows: " + jobArgs.get(ClassifierArg.sampleRows));
			System.out.println("categoryFieldPos: " + jobArgs.get(ClassifierArg.categoryFieldPos));
			System.out.println("contentFieldPos: " + jobArgs.get(ClassifierArg.contentFieldPos));
			System.out.println("categories: " + jobArgs.get(ClassifierArg.categories));
			System.out.println("modelFileLoc: " + jobArgs.get(ClassifierArg.modelFileLoc));
			System.out.println("sampleRows: " + jobArgs.get(ClassifierArg.sampleRows));
			System.out.println("inputFileFormat: " + jobArgs.get(ClassifierArg.inputFileFormat));
			System.out.println("compress: " + jobArgs.get(ClassifierArg.compress));
		}
		
		Job job = new Job(conf, "ClassifierTrain");
		job.setJarByClass(ClassifierTrain.class);
		
		//Training should only happen on one node
		job.setNumReduceTasks(1);
		
		Path in = new Path(jobArgs.get(ClassifierArg.evaluateFileLoc));
		Path out = new Path(jobArgs.get(ClassifierArg.modelFileLoc));
		
		//Set input/output paths
		FileInputFormat.setInputPaths(job, in);	
		FileOutputFormat.setOutputPath(job, out);
		
		//Set job's mapper class
		job.setMapperClass(ClassifierMapper.class);
		
		//Set job's reducer class
		job.setReducerClass(ClassifierReducer.class);
		
		//Set input/output formats and key/value types
		FileFormatType inputFormatType = FileFormatType.text;
		if(jobArgs.containsKey(ClassifierArg.inputFileFormat)) {
			inputFormatType = FileFormatType.valueOf(jobArgs.get(ClassifierArg.inputFileFormat));
		}
		
		if(inputFormatType == FileFormatType.text) {
			job.setInputFormatClass(TextInputFormat.class);
		} else {
			job.setInputFormatClass(SequenceFileInputFormat.class);
		}
		
		job.setOutputFormatClass(TextOutputFormat.class);
		
		//job.setMapOutputValueClass(Text.class);
		job.setOutputKeyClass(NullWritable.class);
		job.setOutputValueClass(Text.class);
		
		return (job.waitForCompletion(true) ? 0 : 1);
	}
	
	public static void main(String[] args) throws Exception {
		int res = ToolRunner.run(new Configuration(), new ClassifierTrain(), args);
		final String VERSION = "1.0.31";
		System.out.println("Running ClassifierTrain (v. " + VERSION + ")");
		System.exit(res);
	}
	
	/**
	 * Validates and retrieves ClassfierTrain input arguments.
	 * 
	 * @param args
	 * @return
	 */
	private Map<ClassifierArg, String> getInputArguments(String[] args) {
		Map<ClassifierArg, String> classfierArgs = new HashMap<ClassifierArg, String>();
		int requiredArgCntr = 0;
		
		for(String arg: args) {
			if(arg.startsWith(ClassifierArg.evaluateFileLoc.name()) && arg.contains("=")) {
				classfierArgs.put(ClassifierArg.evaluateFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgCntr ++;
				continue;
			}
				
			if(arg.startsWith(ClassifierArg.categoryFieldPos.name())) {
				classfierArgs.put(ClassifierArg.categoryFieldPos, arg.substring(arg.indexOf("=")+1));
				requiredArgCntr ++;
				continue;
			}
				
			if(arg.startsWith(ClassifierArg.contentFieldPos.name())) {
				classfierArgs.put(ClassifierArg.contentFieldPos, arg.substring(arg.indexOf("=")+1));
				requiredArgCntr ++;
				continue;
			}
				
			if(arg.startsWith(ClassifierArg.categories.name())) {
				classfierArgs.put(ClassifierArg.categories, arg.substring(arg.indexOf("=")+1));
				requiredArgCntr ++;
				continue;
			}
				
			if(arg.startsWith(ClassifierArg.modelFileLoc.name())) {
				classfierArgs.put(ClassifierArg.modelFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgCntr ++;
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.evaluateFileDelimiter.name())) {
				classfierArgs.put(ClassifierArg.evaluateFileDelimiter, arg.substring(arg.indexOf("=")+1));
				requiredArgCntr ++;
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.sampleRows.name())) {
				classfierArgs.put(ClassifierArg.sampleRows, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.inputFileFormat.name())) {
				classfierArgs.put(ClassifierArg.inputFileFormat, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.debug.name())) {
				classfierArgs.put(ClassifierArg.debug, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.compress.name())) {
				classfierArgs.put(ClassifierArg.compress, arg.substring(arg.indexOf("=")+1));
				continue;
			}
		}
		
		if(requiredArgCntr < 6) {
			System.out.println("Usage: ClassfierTrain [-d] evaluateFileLoc=/hdfs/path sampleRows=1-1000000 categoryFieldPos=1"
					+ " contentFieldPos=2 categories=true,false modelFileLoc=/hdfs/path evalutateFieldDelimiter=|"
					+" inputFileFormat=sequence debug=true compress=true");
			
			throw new RuntimeException("Unable to execute ClassifierTrain since all the required"
					+ " input arguments were not provided! Required arguments are: evaluateFileLoc, categoryFieldPos,"
					+ " contentFieldPos, categories, modelFileLoc, evaluateFieldDelimiter");
		}
		
		return classfierArgs;
	}
}
