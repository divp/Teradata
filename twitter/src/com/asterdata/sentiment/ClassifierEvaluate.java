package com.asterdata.sentiment;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.filecache.DistributedCache;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.SequenceFile.CompressionType;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import com.aliasi.classify.JointClassification;
import com.aliasi.classify.JointClassifier;
import com.asterdata.mapreduce.io.FileFormatType;
import com.asterdata.util.RegexpReplace;

/**
 * ClassfierEvaluate map only job evaluates textual content fields based on previously generated
 * Lingpie training model.  In order to run the ClassifierEvaluate one must run a Lingpipe training
 * on the training dataset.  This is achieved via executing ClassifierTrain job. Please refer to 
 * the usage description for all the details on how to run this map/reduce job.
 * 
 * 
 * Usage example:
 * 
 * hadoop jar aster-mr.jar com.asterdata.sentiment.ClassifierEvaluate evaluateFileLoc=/data/classifier/model/part* 
 *  contentFieldPos=5 modelFileLoc=/data/classifier/train/sentiment.model categoryFieldPos=3
 *  outputFileLoc=/data/classifier/out evaluateFileDelimiter="\|" outputFileDelimiter=\t debug=true
 * 
 * Required job arguments:
 *   evaluateFileLoc  --> HDFS path to the file that will be evaluated
 *   contentFieldPos --> position of the content field in the input file "evaluateFileLoc"
 *   modelFileLoc --> HDFS path to model file that ClassifierTrain m/r job generated
 *   outputFileLoc --> HDFS path to directory where the ClassifierEvaluate will write its output to
 *   
 * Optional job arguments
 *   categoryFieldPos --> position of the category field in the input file "evaluateFileLoc".  This field 
 *                        should only be passed when verifying the trained model.
 *   evaluateFileDelimter --> evaluate file delimiter, for example: "\|" 
 *                        If not provided, default delimiter is \|  
 *   outputFileDelimiter --> output file delimiter, for example: "\|"  
 *                   If not provided default output delimiter is \t
 *   outputInFields --> true/false if all input fields should be outputed after classifier evaluation info
 *   regexpReplace --> regular expression function for replacing evaluate contentField values with something else
 *                     For example: regexpReplace(5, '@em[a-z]+', '')
 *                     First field(5) stands for position of the input field, second field is the regular expression
 *                     and final 3rd field is the replacement value.
 *   inputFormatType --> text or sequence
 *   outputFormatType --> text or sequence 
 *   debug --> true/false if to run in debug mode  
 * 
 * @author mmichalski
 */

public class ClassifierEvaluate extends Configured implements Tool {
	private static String DEFAULT_INPUT_DELIMITER = "\\|";
	private static String DEFAULT_OUTPUT_DELIMITER = "\t";
	
	
	public static class ClassifierMapper extends Mapper<Writable, Text, Text, NullWritable> {
		private boolean debug = false;
		private boolean outputOriginalCategory = false;
		private boolean outputInFields = false;
		private String modelFile;
		private int contentFieldPos;
		private int categoryFieldPos;
		private String inputDelimiter;
		private String outputDelimiter;
		private RegexpReplace regexpReplace = null;
		
		private JointClassifier<CharSequence> subjectivityClassifier = null;
		private Text valueOut = new Text();
		
		@SuppressWarnings("unchecked")
		@Override
		public void setup(Context context) {
			Configuration conf = context.getConfiguration();
			debug = conf.getBoolean(ClassifierArg.debug.name(), false);
			outputInFields = conf.getBoolean(ClassifierArg.outputInFields.name(), false);
			modelFile = context.getConfiguration().get(ClassifierArg.modelFileLoc.name());
			contentFieldPos = conf.getInt(ClassifierArg.contentFieldPos.name(), 1);
			categoryFieldPos = conf.getInt(ClassifierArg.categoryFieldPos.name(), -1);
			inputDelimiter = conf.get(ClassifierArg.evaluateFileDelimiter.name(), DEFAULT_INPUT_DELIMITER);
			outputDelimiter = conf.get(ClassifierArg.outputFileDelimiter.name(), DEFAULT_OUTPUT_DELIMITER);
			String regexpReplaceFunction = conf.get(ClassifierArg.regexpReplace.name(), null);
			if(regexpReplaceFunction != null) {
				regexpReplace = RegexpReplace.valueOf(regexpReplaceFunction);
			}
			
			if(categoryFieldPos > -1) {
				outputOriginalCategory = true;
			}
			
			ObjectInputStream is = null;
			
			try {
				Path[] cachedFiles = DistributedCache.getLocalCacheFiles(conf);
				
				if(cachedFiles == null || cachedFiles.length < 1) {
					System.err.println("No distributed cache files present!");
					throw new RuntimeException("ClassifierEvaluate requires the following"
							+ " distributed cache file: " + modelFile);
				}
				
				boolean fileFound = false;
				String modelFileName = new Path(modelFile).getName();
				for(Path cachedFile: cachedFiles) {
					if(debug) {
						System.out.println("cachedFile: " + cachedFile);
					}
					
					if(cachedFile.getName().equals(modelFileName)) {
						fileFound = true;
						if(debug) {
							System.out.println("..creating ObjectInputStream....");
						}
						is = new ObjectInputStream(new FileInputStream(cachedFile.toString()));
						if(debug) {
							System.out.println("..created ObjectInputStream, deserilzing JointClassifier for ObjectInputStream....");
						}
						subjectivityClassifier = (JointClassifier<CharSequence>) is.readObject();
						if(debug) {
							System.out.println("JointClassifier deserialized from file...");
						}
					} 
				}
				
				//In order to continue with program execution, the modelFile had to be loaded from distributed caches
				if(!fileFound) {
					throw new RuntimeException("ClassifierEvaluate requires the following ditributed cache"
							+ " file: " + modelFile);
				}
			} catch(IOException ioe) {
				System.err.println("Error reading diserializing from distributed cache!");
				ioe.printStackTrace();
				throw new RuntimeException(ioe);
			} catch(ClassNotFoundException cnfe) {
				System.err.println("Unable to desrialize object into JointClassifier");
				throw new RuntimeException(cnfe);
			} finally {
				try {
					if(debug) {
						System.out.println("closing input stream");
					}
					is.close();
				} catch(Exception e) {}
			}
		}
		
		private int cnt = 0;
		
		@Override
		public void map(Writable key, Text value, Context context) throws IOException, InterruptedException {
			String inputValues = value.toString();
			String[] classifierInputs = inputValues.split(inputDelimiter);
			if(debug && cnt < 20) {
        		System.out.println("input key: ["+key.toString()+"]");
        		System.out.println("input value: [" + inputValues + "]");
        	}
			
			String content = classifierInputs[contentFieldPos];
			if(regexpReplace != null) {
				content = regexpReplace.replaceValue(content);
			}
        	
        	JointClassification jc = subjectivityClassifier.classify(content);
        	StringBuilder sb = new StringBuilder();
        	
        	//Output original content
        	if(outputInFields) {
        		sb.append(jc.bestCategory()).append(outputDelimiter).append(jc.score(0));
        		if(! outputDelimiter.equals(inputDelimiter))
        			inputValues =inputValues.replaceAll(inputDelimiter, outputDelimiter);
        		//if(key instanceof Text)
        		//	sb.append(outputDelimiter).append(key.toString());
        		
        		sb.append(outputDelimiter).append(inputValues);
        	} else { //this must mean we are running cross validation
        		sb.append(key.toString()).append(outputDelimiter).append(content)
            	.append(outputDelimiter).append(jc.bestCategory()).append(outputDelimiter)
            	.append(jc.score(0));
        		
        		if(outputOriginalCategory)
        			sb.append(outputDelimiter).append(classifierInputs[categoryFieldPos]);
        	}
        	
        	valueOut.set(sb.toString());
        	
        	if(debug && cnt < 25) {
        		System.out.println("key: [" + key.toString() +"]");
        		System.out.println("value: [" + value.toString() +"]");
        		System.out.println("content: [" + content + "]");
        		System.out.println("bestCategory: [" + jc.bestCategory() + "]");
        		System.out.println("score 0: [" + jc.score(0) + "]");
        		
        		if(outputOriginalCategory)
        			System.out.println("orig category: " + classifierInputs[categoryFieldPos]);
        		
        		System.out.println("jc.toString: [" + jc.toString() + "]");
        		System.out.println("jc.size: " + jc.size());
        	}
        	
        	context.write(valueOut,NullWritable.get());
        	cnt ++;
		}
	}
	
	
	public int run(String[] args) throws Exception {
		Map<ClassifierArg, String> jobArgs = getInputArguments(args);
		Configuration conf = getConf();
		boolean debug = false;
		boolean compress = true;
		
		/** Override default settings for Hadoop cluster */
		//allow the mapper to run with maximum of 3GB of memory
		conf.set("mapred.child.java.opts", "-Xmx3072m -XX:+UseSerialGC");
		/** Done with default overrides */
		
		//Add Lingpie model file into distributed cache
		DistributedCache.addCacheFile(new URI(jobArgs.get(ClassifierArg.modelFileLoc)), conf);
		
		conf.setInt(ClassifierArg.contentFieldPos.name(), Integer.parseInt(
				jobArgs.get(ClassifierArg.contentFieldPos))-1);
		conf.set(ClassifierArg.modelFileLoc.name(), jobArgs.get(ClassifierArg.modelFileLoc));
		
		if(jobArgs.containsKey(ClassifierArg.categoryFieldPos)) {
			conf.setInt(ClassifierArg.categoryFieldPos.name(), Integer.parseInt(
					jobArgs.get(ClassifierArg.categoryFieldPos))-1);
		}
		
		if(jobArgs.containsKey(ClassifierArg.debug)) {
			debug = Boolean.valueOf(jobArgs.get(ClassifierArg.debug));
			conf.setBoolean(ClassifierArg.debug.name(), debug);
		}
		
		//Enable Compression
		if(jobArgs.containsKey(ClassifierArg.compress)) {
			debug = Boolean.valueOf(jobArgs.get(ClassifierArg.compress));
		}
		conf.setBoolean("mapred.output.compress", compress);
		conf.setBoolean("mapred.compress.map.output", compress);
		
		if(debug) {
			System.out.println("evaluateFileLoc: " + jobArgs.get(ClassifierArg.evaluateFileLoc));
			System.out.println("modelFileLoc: " + jobArgs.get(ClassifierArg.modelFileLoc));
			System.out.println("outputFileLoc: " + jobArgs.get(ClassifierArg.outputFileLoc));
			System.out.println("contentFieldPos: " + jobArgs.get(ClassifierArg.contentFieldPos));
			System.out.println("categoryFieldPos: " + jobArgs.get(ClassifierArg.categoryFieldPos));
			System.out.println("evaluateFileDelimiter: " +jobArgs.get(ClassifierArg.evaluateFileDelimiter));
			System.out.println("outputFileDelimiter: " + jobArgs.get(ClassifierArg.outputFileDelimiter));
			System.out.println("regexpReplace: " + jobArgs.get(ClassifierArg.regexpReplace));
			System.out.println("outputInFields: " + jobArgs.get(ClassifierArg.outputInFields));
			System.out.println("inputFileFormat: " + jobArgs.get(ClassifierArg.inputFileFormat));
			System.out.println("outputFileFormat: " + jobArgs.get(ClassifierArg.outputFileFormat));
			System.out.println("compress: " + jobArgs.get(ClassifierArg.compress));
		}
		
		if(jobArgs.containsKey(ClassifierArg.regexpReplace)) {
			conf.set(ClassifierArg.regexpReplace.name(), jobArgs.get(ClassifierArg.regexpReplace));
		}
		
		if(jobArgs.containsKey(ClassifierArg.outputInFields)) {
			conf.setBoolean(ClassifierArg.outputInFields.name(), 
					Boolean.valueOf(jobArgs.get(ClassifierArg.outputInFields)));
		}
		
		if(jobArgs.containsKey(ClassifierArg.evaluateFileDelimiter)) {
			conf.set(ClassifierArg.evaluateFileDelimiter.name(), jobArgs.get(ClassifierArg.evaluateFileDelimiter));
		}
		
		if(jobArgs.containsKey(ClassifierArg.outputFileDelimiter)) {
			conf.set(ClassifierArg.outputFileDelimiter.name(), jobArgs.get(ClassifierArg.outputFileDelimiter));
		}
		
		Job job = new Job(conf, "ClassifierEvaluate");
		job.setJarByClass(ClassifierEvaluate.class);
		
		//This is map only job
		job.setNumReduceTasks(0);
		
		Path in = new Path(jobArgs.get(ClassifierArg.evaluateFileLoc));
		Path out = new Path(jobArgs.get(ClassifierArg.outputFileLoc));
		
		FileInputFormat.setInputPaths(job, in);
		FileOutputFormat.setOutputPath(job, out);
		//Set job's mapper class
		job.setMapperClass(ClassifierMapper.class);
		
		FileFormatType inputFormatType = FileFormatType.text;
		FileFormatType outputFormatType = FileFormatType.text;
		if(jobArgs.containsKey(ClassifierArg.inputFileFormat)) {
			inputFormatType = FileFormatType.valueOf(jobArgs.get(ClassifierArg.inputFileFormat));
		}
		if(jobArgs.containsKey(ClassifierArg.outputFileFormat)) {
			outputFormatType = FileFormatType.valueOf(jobArgs.get(ClassifierArg.outputFileDelimiter));
		}
		
		if(inputFormatType == FileFormatType.text) {
			job.setInputFormatClass(TextInputFormat.class);
		} else {
			job.setInputFormatClass(SequenceFileInputFormat.class);
		}
		
		if(outputFormatType == FileFormatType.text) {
			job.setOutputFormatClass(TextOutputFormat.class);
		} else {
			//Compress the sequence files at block level
			SequenceFileOutputFormat.setOutputCompressionType(job, CompressionType.BLOCK);
			job.setOutputFormatClass(SequenceFileOutputFormat.class);
		}
		
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(NullWritable.class);
		
		return (job.waitForCompletion(true) ? 0 : 1);
	}
	
	public static void main(String[] args) throws Exception {
		int res = ToolRunner.run(new Configuration(), new ClassifierEvaluate(), args);
		
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
		
		int requiredArgsCntr = 0;
		
		for(String arg: args) {
			if(arg.startsWith(ClassifierArg.evaluateFileLoc.name()) && arg.contains("=")) {
				classfierArgs.put(ClassifierArg.evaluateFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgsCntr ++;
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.contentFieldPos.name())) {
				classfierArgs.put(ClassifierArg.contentFieldPos, arg.substring(arg.indexOf("=")+1));
				requiredArgsCntr ++;
				continue;
			}
				
			if(arg.startsWith(ClassifierArg.modelFileLoc.name())) {
				classfierArgs.put(ClassifierArg.modelFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgsCntr ++;
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.outputFileLoc.name())) {
				classfierArgs.put(ClassifierArg.outputFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgsCntr ++;
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.categoryFieldPos.name())) {
				classfierArgs.put(ClassifierArg.categoryFieldPos, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.evaluateFileDelimiter.name())) {
				classfierArgs.put(ClassifierArg.evaluateFileDelimiter, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.outputFileDelimiter.name())) {
				classfierArgs.put(ClassifierArg.outputFileDelimiter, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.regexpReplace.name())) {
				classfierArgs.put(ClassifierArg.regexpReplace, arg);
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.inputFileFormat.name())) {
				classfierArgs.put(ClassifierArg.inputFileFormat, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.outputFileFormat.name())) {
				classfierArgs.put(ClassifierArg.outputFileFormat, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(ClassifierArg.outputInFields.name())) {
				classfierArgs.put(ClassifierArg.outputInFields, arg.substring(arg.indexOf("=")+1));
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
		
		if(requiredArgsCntr < 4) {
			System.out.println("Usage: ClassfierEvaluate [-d] evaluateFileLoc=/hdfs/path contentFieldPos=1"
					+ " modelFileLoc=/hdfs/path outputFileLoc=/hdfs/path evaluateFileDelimiter=\"\\|\""
					+ " outputFileDelimiter=\t categoryFieldPos=3 outputInFields=true inputFileFormat=sequence"
					+ " outputFileFormat=sequence debug=true");
			
			throw new RuntimeException("Unable to execute ClassifierEvaluate since all the required input arguments"
					+ " were not provided! Required arguments are: evaluateFileLoc, contentFieldPos, outputFileLoc,"
					+ " modelFileLoc");
		}
		
		return classfierArgs;
	}
}
