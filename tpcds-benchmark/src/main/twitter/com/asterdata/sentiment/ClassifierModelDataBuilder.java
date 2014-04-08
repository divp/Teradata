package com.asterdata.sentiment;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.SequenceFile.CompressionType;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * ClassifierModelDataBuilder prepares the input data for the ClassifierTrain module.
 * It extracts only English related posts and determines if given post has been
 * posted on computer group forum. 
 * 
 * 
 * @author mmichalski
 *
 */

public class ClassifierModelDataBuilder extends Configured implements Tool {
	
	public static class ModelMapper extends Mapper<LongWritable,Text,NullWritable,Text> {
		private static String INPUT_DELIMITER = "\\|";
		private static String OUTPUT_DELIMITER = "\\t";
		
		private static String GROUP_NAME_LIKE_COMPUTER = "compu";
		private static String GROUP_NAME_LIKE_WORLD = ".world";
		
		private Text outputValue = new Text();
		
		@Override
		public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
			String[] inputValues = value.toString().split(INPUT_DELIMITER, 2);
			String groupName = inputValues[0];
			String descText = inputValues[1];
			
			//exclude any records that are part of world group and have a description Text
			if(! groupName.contains(GROUP_NAME_LIKE_WORLD) && descText.trim().length() > 0) {
				String isComputerTopic = groupName.contains(GROUP_NAME_LIKE_COMPUTER) ? "true" : "false";
				StringBuilder sb = new StringBuilder();
				sb.append(groupName).append(OUTPUT_DELIMITER).append(isComputerTopic).append(OUTPUT_DELIMITER)
				.append(descText);
				
				outputValue.set(sb.toString());
				context.write(NullWritable.get(), outputValue);
			}
		}
		
	}
	
	public static class ModelReducer extends Reducer<NullWritable,Text,LongWritable,Text> {
		private long rowNum = 1;
		
		private LongWritable outputKey = new LongWritable();
		
		@Override
		public void reduce(NullWritable key, Iterable<Text> values, Context context) throws IOException, InterruptedException 
		{	
			for(Text value: values) {
				outputKey.set(rowNum);
				
				context.write(outputKey, value);
				
				rowNum ++;
			}
			
		}
	}
	
	
	@Override
	public int run(String[] args) throws Exception {
		if(args.length < 2) {
			throw new RuntimeException("Unable to execute ClassifierModelDataBuilder since input output path "
					+ "parameters were not privided.  Please pass in hitdata hdfs input path "
					+ "and output hdfs path!");
		}
		
		Configuration conf = getConf();
		Job job = new Job(conf, "ClassifierDataModelBuilder");
		job.setJarByClass(ClassifierModelDataBuilder.class);
		
		//Make sure that only one reducer is used for this test
		job.setNumReduceTasks(1);
		
		Path in = new Path(args[0]);
		Path out = new Path(args[1]);
		
		FileInputFormat.setInputPaths(job, in);
		FileOutputFormat.setOutputPath(job, out);
		
		//Compress the sequence files at block level
		SequenceFileOutputFormat.setOutputCompressionType(job, CompressionType.BLOCK);
		
		//Set job's mapper class
		job.setMapperClass(ModelMapper.class);
		job.setReducerClass(ModelReducer.class);
		
		job.setInputFormatClass(TextInputFormat.class);
		job.setOutputFormatClass(SequenceFileOutputFormat.class);
		
		job.setMapOutputKeyClass(NullWritable.class);
		job.setOutputKeyClass(LongWritable.class);
		job.setOutputValueClass(Text.class);
		
		return (job.waitForCompletion(true) ? 0 : 1); 
	}
	
	public static void main(String[] args) throws Exception {
		int res = ToolRunner.run(new Configuration(), new ClassifierModelDataBuilder(), args);
		
		System.exit(res);
	}
}
