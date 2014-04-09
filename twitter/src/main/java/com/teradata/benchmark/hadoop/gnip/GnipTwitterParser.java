package com.teradata.benchmark.hadoop.gnip;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SequenceFile.CompressionType;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import com.teradata.benchmark.hadoop.gnip.GnipActivity.Gnip.Language;
import com.teradata.benchmark.hadoop.mapreduce.io.FileFormatType;
import com.teradata.benchmark.hadoop.util.TextLib;


/**
 * GnipTwitterParser Map only job reads GNIP twitter related json documents and extracts 
 * twitter data that can be utilized in downstream analysis.  This program could be chained
 * in more advanced Map/Reduce job with dynamic partitioning which would partition the data
 * extracted twitter data by date.
 * 
 * As of now, this program will only extract properly fomrated GNIP json documents
 * that were tweeted by users that have their profile's language set to English.
 * 
 * The parser outputs the following fields in tab delimited fashion:
 * 
 * activity_dt          - date of the activity
 * record_type_id       - Type of file record that is getting processed based on the gnipMappingFile
 * document_id 			- tweet message status id
 * posted_time			- time the tweet was posted
 * doc_txt				- tweet text
 * doc_txt_reg			- regulized tweet text
 * is_retweet			- true/false if tweet is a retweet of original content
 * user_id				- twitter user id of the person who has tweeted
 * user_name				- twitter user name
 * screen_name			- twitter user screen name
 * follower_count		- twitter user follower count for the user
 * friends_count		- twitter user friends count
 * user_location		- location of the user as he/she provided in twitter registration page
 * in_reply_to_status_id- status id of the original tweet that the user is replying to
 * in_reply_to			- in reply to user name
 * language				- language
 * kloutScore			- Klout score 
 * 
 * Usage example:
 * 
 * hadoop jar aster-mr.jar com.asterdata.gnip.GnipTwitterParer inputFileLoc=/data/raw/gnip/twitter 
 *  outputFileLoc=/data/gnip/twitter gnipMappingFileLoc=/home/hadoop/gnip_files_mapping.properties debug=true
 * 
 * Required job arguments:
 *   inputFileLoc --> HDFS path to twitter gnip activity file(s)
 *   outputFileLoc --> HDFS path to directory where GnipTwitterParser will write the output to
 *   gnipMappingFileLoc --> Local unix path to gnip input files to recordType mapping file
 *   
 *   
 * Optional job arguments
 *   debug --> true/false if to run in debug mode 
 *   outputFileFormat --> text or sequence (This sets the job's output format class) 
 * 
 * 
 * @author mmichalski
 *
 */

public class GnipTwitterParser extends Configured implements Tool {
	public enum TwitterCounter {
		INVALID_JSON_FORMAT,GNIP_PARSING_ERROR,ENGLISH_LANGUAGE_RECORD,NON_ENGLISH_LANGUAGE_RECORD;
	}
	
	public static enum GnipTwitterArg {
		inputFileLoc,outputFileLoc,gnipMappingFileLoc,outputFileFormat,debug,compress;
	}
	
	public static class TwitterMapper extends Mapper<LongWritable,Text,Text,Text> {
		private static String BEGIN_JSON = "{\"";
		private static String END_JSON = "}}";
		private static String LANGUAGE_EN = "en";
		private static String DELIMITER = "\t";
		
		private boolean debug = false;
		private int recordTypeId = 0;
		private Text outputValue = new Text();
		private Text outputKey = new Text();
		
		@Override
		protected void setup(Context context) {
			Configuration conf = context.getConfiguration();
			//debug = conf.getBoolean(WeblogParserArg.debug.name(), false);
			
			FileSplit fileSplit = (FileSplit)context.getInputSplit();
			String filename = fileSplit.getPath().getName();
			
			if(debug) {
				System.out.println("processing file name: " + filename);
			}
			
			
			//Determine the recordType based on the file split that is being processed by each mapper
			int numberOfMappingFiles = conf.getInt("gnip.mapping.file.count", 0);
			if(debug) {
				System.out.println("number of mappings: " + numberOfMappingFiles);
			}
			
			String mappingRecord;
			GnipMappingRecord gmr;
			for(int i=0; i<numberOfMappingFiles; i++) {
				mappingRecord = conf.get("gnip.mapping.file."+(i+1));
				if(mappingRecord != null) {
					gmr = GnipMappingRecord.valueOf(mappingRecord);
					if(filename.contains(gmr.getFileNamePattern())) {
						if(debug) {
							System.out.println("current file matches file pattern: " + gmr.getFileNamePattern()
									+ " , file mapped to recordType: " + gmr.getRecordType());
						}
						
						recordTypeId = gmr.getRecordType();
						break;
					}
				}
			}
		}
		
		private int cntr;
		@Override
		protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
			String json = value.toString();
			
			//Skip any records that don't have full twitter JSON text
			if(! json.startsWith(BEGIN_JSON) && ! json.endsWith(END_JSON)) {
				context.getCounter(TwitterCounter.INVALID_JSON_FORMAT).increment(1);
				if(debug) {
					System.out.println("invalid gnip json: [" + value.toString() +"]");
				}
				return;
			}
			
			try {
				GnipActivity gnipActivity = GnipActivity.parseJSON(json);
				Language lang = null;
				
				if(gnipActivity.getGnip() != null) {
					lang = gnipActivity.getGnip().getLanguage();
				}
				
				if(debug && cntr <25) {
					System.out.println("dealing with language: " + lang);
					System.out.println("gnip activity: " + gnipActivity.extractGnipTwitterData(DELIMITER));
					
				}
				
				//Only extract records that Gnip thinks that are in English language
				if(lang != null && lang.getValue().toLowerCase().equals(LANGUAGE_EN)) {
					String postedTime = gnipActivity.getPostedTime();
					outputKey.set(postedTime.substring(0,postedTime.indexOf("T")));
					
					/*record_type_id INT,
					documentId
					activity_dt STRING,
					posted_time STRING,
				    doc_txt character varying, -- original payload
				    doc_txt_reg character varying, -- regularized payload
				    is_retweet character varying,
				    user_id bigint,
				    user_name character varying,
				    screen_name character varying,
				    follower_count integer,
				    friends_count integer,
				    user_location character varying,
				    in_reply_doc_id bigint,
				    language character varying,
				    klout_score integer*/
					
					StringBuilder gnipActivityInfo = new StringBuilder();
					gnipActivityInfo.append(recordTypeId).append(DELIMITER).append(gnipActivity.getTweetId())
					.append(DELIMITER).append(gnipActivity.getPostedTime()).append(DELIMITER).append(gnipActivity.getBody())
					.append(DELIMITER).append(TextLib.regularize(gnipActivity.getBody())).append(DELIMITER)
					.append(gnipActivity.isRetweet()).append(DELIMITER).append(gnipActivity.getActor().getUserId())
					.append(DELIMITER).append(gnipActivity.getActor().getPreferredUsername()).append(DELIMITER)
					.append(gnipActivity.getActor().getDisplayName()).append(DELIMITER)
					.append(gnipActivity.getActor().getFollowersCount()).append(DELIMITER)
					.append(gnipActivity.getActor().getFriendsCount()).append(DELIMITER);
					
					if(gnipActivity.getActor().getLocation() != null)
						gnipActivityInfo.append(gnipActivity.getActor().getLocation().getDisplayName());
					gnipActivityInfo.append(DELIMITER);
					
					if(gnipActivity.getInReplyTo() == null) {
						gnipActivityInfo.append(-1);
					} else {
						gnipActivityInfo.append(gnipActivity.getInReplyTo().getStatusId());
					}
					gnipActivityInfo.append(DELIMITER);
					
					if(gnipActivity.getGnip().getLanguage() != null)
						gnipActivityInfo.append(gnipActivity.getGnip().getLanguage().getValue());
					
					gnipActivityInfo.append(DELIMITER).append(gnipActivity.getGnip().getKlout_score());
					
					outputValue.set(gnipActivityInfo.toString());
					
					context.write(outputKey, outputValue);
					context.getCounter(TwitterCounter.ENGLISH_LANGUAGE_RECORD).increment(1);
				} else {
					context.getCounter(TwitterCounter.NON_ENGLISH_LANGUAGE_RECORD).increment(1);
				}
			} catch(Exception e) {
				if(debug) {
					e.printStackTrace();
				}
				context.getCounter(TwitterCounter.GNIP_PARSING_ERROR).increment(1);
			}
			cntr++;
		}
	}
	 
	public static class GnipMappingRecord {
		private String fileNamePattern;
		private int recordType;
		
		public GnipMappingRecord(String fileNamePattern, int recordType) {
			this.fileNamePattern = fileNamePattern;
			this.recordType = recordType;
		}
		
		public String getFileNamePattern() {
			return fileNamePattern;
		}

		public void setFileNamePattern(String fileNamePattern) {
			this.fileNamePattern = fileNamePattern;
		}

		public int getRecordType() {
			return recordType;
		}

		public void setRecordType(int recordType) {
			this.recordType = recordType;
		}

		public static GnipMappingRecord valueOf(String mappingRecordInfo) {
			int indx = mappingRecordInfo.indexOf("=");
			return new GnipMappingRecord(mappingRecordInfo.substring(0,indx), 
					Integer.parseInt(mappingRecordInfo.substring(indx+1)));
		}
	}
	
	
	public int run(String[] args) throws Exception {
		Configuration conf = getConf();
		Map<GnipTwitterArg, String> jobArgs = getInputArguments(args);
		boolean debug = false;
		if(jobArgs.get(GnipTwitterArg.debug) != null) {
			debug = Boolean.valueOf(jobArgs.get(GnipTwitterArg.debug));
		}
		
		boolean compress = false;
		if(jobArgs.get(GnipTwitterArg.compress) != null) {
			compress = Boolean.valueOf(jobArgs.get(GnipTwitterArg.compress));
		}
		
		conf.setBoolean("mapred.output.compress", compress);
		conf.setBoolean("mapred.compress.map.output", compress);
		
		mapInputFiles(jobArgs.get(GnipTwitterArg.gnipMappingFileLoc), conf);
		conf.setBoolean(GnipTwitterArg.debug.name(), debug);
		
		if(debug) {
			System.out.println("inputFileLoc: " + jobArgs.get(GnipTwitterArg.inputFileLoc));
			System.out.println("outputFileLoc: " + jobArgs.get(GnipTwitterArg.outputFileLoc));
			System.out.println("gnipMappingFileLoc : " + jobArgs.get(GnipTwitterArg.gnipMappingFileLoc));
			System.out.println("outputFileFormat: " + jobArgs.get(GnipTwitterArg.outputFileFormat));
			System.out.println("compress: " + jobArgs.get(GnipTwitterArg.compress));
		}
		
		Job job = new Job(conf, "GnipTwitterParser");
		job.setJarByClass(GnipTwitterParser.class);
		
		
		//This is only map job, no reducers needed
		job.setNumReduceTasks(0);
		
		//This is to let hadoop know to load my jar files in lib directory first
		//and then load jars from /usr/lib/hadoop/lib
		//job.setUserClassesTakesPrecedence(true);
		
		Path in = new Path(jobArgs.get(GnipTwitterArg.inputFileLoc));
		Path out = new Path(jobArgs.get(GnipTwitterArg.outputFileLoc));
		
		FileInputFormat.setInputPaths(job, in);
		FileOutputFormat.setOutputPath(job, out);
		
		//Set job's mapper class
		job.setMapperClass(TwitterMapper.class);
		job.setInputFormatClass(TextInputFormat.class);
		
		//Set the outputFormat type
		FileFormatType outputFormatType = FileFormatType.text;
		if(jobArgs.containsKey(GnipTwitterArg.outputFileFormat)) {
			outputFormatType = FileFormatType.valueOf(jobArgs.get(GnipTwitterArg.outputFileFormat));
		}
		if(outputFormatType == FileFormatType.text) {
			job.setOutputFormatClass(TextOutputFormat.class);
		} else {
			//Compress the sequence files at block level
			SequenceFileOutputFormat.setOutputCompressionType(job, CompressionType.BLOCK);
			job.setOutputFormatClass(SequenceFileOutputFormat.class);
		}
		
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		
		return (job.waitForCompletion(true) ? 0 : 1); 
	}
	
	/**
	 * Validates and retrieves Sessionize input arguments.
	 * 
	 * @param args
	 * @return
	 */
	private Map<GnipTwitterArg, String> getInputArguments(String[] args) {
		Map<GnipTwitterArg, String> weblogArgs = new HashMap<GnipTwitterArg, String>();
		
		int requiredArgsCntr = 0;
		
		for(String arg: args) {
			if(arg.startsWith(GnipTwitterArg.inputFileLoc.name()) && arg.contains("=")) {
				weblogArgs.put(GnipTwitterArg.inputFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgsCntr ++;
				continue;
			}
			
			if(arg.startsWith(GnipTwitterArg.outputFileLoc.name())) {
				weblogArgs.put(GnipTwitterArg.outputFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgsCntr ++;
				continue;
			}
			
			if(arg.startsWith(GnipTwitterArg.gnipMappingFileLoc.name())) {
				weblogArgs.put(GnipTwitterArg.gnipMappingFileLoc, arg.substring(arg.indexOf("=")+1));
				requiredArgsCntr ++;
				continue;
			}
			
			if(arg.startsWith(GnipTwitterArg.outputFileFormat.name())) {
				weblogArgs.put(GnipTwitterArg.outputFileFormat, arg.substring(arg.indexOf("=")+1));
				continue;
			}
			
			if(arg.startsWith(GnipTwitterArg.debug.name())) {
				weblogArgs.put(GnipTwitterArg.debug, arg.substring(arg.indexOf("=")+1).toLowerCase());
				continue;
			}
			
			if(arg.startsWith(GnipTwitterArg.compress.name())) {
				weblogArgs.put(GnipTwitterArg.compress, arg.substring(arg.indexOf("=")+1).toLowerCase());
				continue;
			}
		}
		
		if(requiredArgsCntr < 3) {
			System.out.println("Usage: GnipTwitterParser [-d] inputFileLoc=/hdfs/path outputFileLoc=/hdfs/path"
					+ " gnipMappingFileLoc=/local/unx/path debug=true");
			
			throw new RuntimeException("Unable to execute GnipTwitterParser since all the required input arguments"
					+ " were not provided! Required arguments are: inputFileLoc, outputFileLoc, and gnipMappingFileLoc");
		}
		
		return weblogArgs;
	}
	
	public static void main(String[] args) throws Exception {
		int res = ToolRunner.run(new Configuration(), new GnipTwitterParser(), args);
		
		System.exit(res);
	}
	
	private void mapInputFiles(String gnipFileMappingLoc, Configuration conf) throws IOException {
		BufferedReader br = null;
		try {
			br = new BufferedReader(new FileReader(gnipFileMappingLoc));
			String mapppingInfo;
			int mappingFileCount = 0;
			
			while((mapppingInfo=br.readLine()) != null) {
				mappingFileCount ++;
				conf.set("gnip.mapping.file."+mappingFileCount, mapppingInfo);
			}
			
			conf.setInt("gnip.mapping.file.count", mappingFileCount);
		} finally {
			try {
				br.close();
			} catch(Exception e) {}
		}
		
	}
}
