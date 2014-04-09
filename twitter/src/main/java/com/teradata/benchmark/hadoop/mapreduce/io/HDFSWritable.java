package com.teradata.benchmark.hadoop.mapreduce.io;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;

/**
 * Wrapper class for 2 WritableComparableTypes
 * 
 * @author mmichalski
 */

@SuppressWarnings("rawtypes")
public class HDFSWritable implements WritableComparable {
	//Type holders
	private WritableComparableType firstType;
	private IntWritable fType;
	
	
	/**
	 * the first field holder
	 */
	private Text firstText;
	private IntWritable firstInt;
	private LongWritable firstLong;

	
	public HDFSWritable() {
		this.fType = new IntWritable();
	}
	
	public HDFSWritable(WritableComparableType firstType, WritableComparableType secondType) {
		this.fType = new IntWritable(firstType.getType());
		this.firstType = firstType;
		
		if(firstType == WritableComparableType.TEXT)
			firstText = new Text();
		else if(firstType == WritableComparableType.INT)
			firstInt = new IntWritable();
		else
			firstLong = new LongWritable();	
	}
	
	/**
	 * set the first Text
	 * 
	 * @param t1
	 */
	public void setFirst(String first) {
		if(firstText == null) {
			firstText = new Text();
			fType.set(WritableComparableType.TEXT.getType());
		}
		
		this.firstText.set(first);
	}
	
	public void setFirst(long first) {
		if(firstLong == null) {
			firstLong = new LongWritable();
			fType.set(WritableComparableType.LONG.getType());
		}
		
		this.firstLong.set(first);
	}
	
	public void setFirst(int first) {
		if(firstInt == null) {
			firstInt = new IntWritable();
			fType.set(WritableComparableType.INT.getType());
		}
		
		this.firstInt.set(first);
	}

	
	public WritableComparableType getFirstType() {
		return firstType;
	}

	
	public Text getFirstText() {
		return firstText;
	}

	public IntWritable getFirstInt() {
		return firstInt;
	}

	public LongWritable getFirstLong() {
		return firstLong;
	}
	
	/**
	 * get the first field
	 * 
	 * @return the first field
	 */
	public String getFirstValueAsString() {
		if(firstType == WritableComparableType.TEXT)
			return firstText.toString();
		else if(firstType == WritableComparableType.INT)
			return firstInt.toString();
		else
			return firstLong.toString();
	}
	
	
	

	public void write(DataOutput out) throws IOException {
		fType.write(out);
		
		if(firstType == WritableComparableType.TEXT)
			firstText.write(out);
		else if(firstType == WritableComparableType.INT)
			firstInt.write(out);
		else
			firstLong.write(out);
	}

	public void readFields(DataInput in) throws IOException {
		fType.readFields(in);
		firstType = WritableComparableType.fromType(fType.get());
		
		if(firstType == WritableComparableType.TEXT) {
			firstText = new Text();
			firstText.readFields(in);
		} else if(firstType == WritableComparableType.INT) {
			firstInt = new IntWritable();
			firstInt.readFields(in);
		} else {
			firstLong = new LongWritable();
			firstLong.readFields(in);
		}
	}

	/**
	 * compare method for comparing 2 HDFSWritable object together
	 */
	public int compareTo(Object object) {
		HDFSWritable hwp2 = (HDFSWritable) object;
		int cmp = this.firstType.compareTo(hwp2.firstType);
		if(cmp != 0)
			return cmp;
		
		if(firstType == WritableComparableType.TEXT)
			cmp = firstText.compareTo(hwp2.firstText);
		else if(firstType == WritableComparableType.INT)
			cmp = firstInt.compareTo(hwp2.firstInt);
		else
			cmp = firstLong.compareTo(hwp2.firstLong);
		
		return cmp;
	}
	
	public int firstHashCode() {
		if(firstType == WritableComparableType.TEXT)
			return firstText.hashCode();
		else if(firstType == WritableComparableType.INT)
			return firstInt.hashCode();
		else
			return firstLong.hashCode();
	}

	/**
	 * Only use the first field when computing the hash code so that
	 * data gets split only by the first field from the HDFSWritablePair 
	 * across the Nodes.
	 */
	public int hashCode() {
		int hash = 1;
		hash = hash * 31 + firstHashCode();		
		
		return hash;
	}

	/**
	 * Only compare the first field in for the equals
	 */
	public boolean equals(Object o) {
		HDFSWritable p = (HDFSWritable) o;
		
		if(this.getFirstType() != p.getFirstType())
			return false;
		
		if(firstType == WritableComparableType.TEXT)
			return firstText.equals(p.firstText);
		else if(firstType == WritableComparableType.INT)
			return firstInt.equals(p.firstInt);
		else
			return firstLong.equals(p.firstLong);
	}
	
	public static int compareFirstValues(HDFSWritable p1, HDFSWritable p2) {
		int cmp = p1.getFirstType().compareTo(p2.getFirstType());
		if(cmp != 0)
			return cmp;
		
		if(p1.getFirstType() == WritableComparableType.TEXT)
			return compareValues(p1.getFirstText(), p2.getFirstText());
		else if(p1.getFirstType() == WritableComparableType.INT)
			return compareValues(p1.getFirstInt(), p2.getFirstInt());
		else
			return compareValues(p1.getFirstLong(), p2.getFirstLong());
	}
	
	public static int compareFirstValuesReverse(HDFSWritable p1, HDFSWritable p2) {
		int cmp = compareFirstValues(p1, p2);
		
		//reverse regular compare
		if(cmp!=0)
			cmp = -cmp;
		
		return cmp;
	}
	
	public static int compareValues(Text val1, Text val2) {
		return val1.compareTo(val2);
	}
	
	public static int compareValues(IntWritable val1, IntWritable val2) {
		return val1.compareTo(val2);
	}

	public static int compareValues(LongWritable val1, LongWritable val2) {
		return val1.compareTo(val2);
	}   
}
