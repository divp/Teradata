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
public class HDFSWritablePair implements WritableComparable {
	//Type holders
	private WritableComparableType firstType;
	private WritableComparableType secondType;
	private IntWritable fType;
	private IntWritable sType;
	
	
	/**
	 * the first field holder
	 */
	private Text firstText;
	private IntWritable firstInt;
	private LongWritable firstLong;

	/**
	 * the second field holder
	 */
	private Text secondText;
	private IntWritable secondInt;
	private LongWritable secondLong;
	
	public HDFSWritablePair() {
		this.fType = new IntWritable();
		this.sType = new IntWritable();
	}
	
	public HDFSWritablePair(WritableComparableType firstType, WritableComparableType secondType) {
		this.fType = new IntWritable(firstType.getType());
		this.sType = new IntWritable(secondType.getType());
		this.firstType = firstType;
		this.secondType = secondType;
		
		if(firstType == WritableComparableType.TEXT)
			firstText = new Text();
		else if(firstType == WritableComparableType.INT)
			firstInt = new IntWritable();
		else
			firstLong = new LongWritable();
		
		if(secondType == WritableComparableType.TEXT)
			secondText = new Text();
		else if(secondType == WritableComparableType.INT)
			secondInt = new IntWritable();
		else
			secondLong = new LongWritable();
		
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

	/**
	 * set the second text
	 * 
	 * @param t2
	 */
	public void setSecond(String second) {
		if(secondText == null) {
			secondText = new Text();
			sType.set(WritableComparableType.TEXT.getType());
		}
		
		this.secondText.set(second);
	}
	
	public void setSecond(long second) {
		if(secondLong == null) {
			secondLong = new LongWritable();
			sType.set(WritableComparableType.LONG.getType());
		}
		
		this.secondLong.set(second);
	}
	
	public void setSecond(int second) {
		if(secondInt == null) {
			secondInt = new IntWritable();
			sType.set(WritableComparableType.TEXT.getType());
		}
		
		this.secondInt.set(second);
	}

	public WritableComparableType getFirstType() {
		return firstType;
	}

	public WritableComparableType getSecondType() {
		return secondType;
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

	public Text getSecondText() {
		return secondText;
	}

	public IntWritable getSecondInt() {
		return secondInt;
	}

	public LongWritable getSecondLong() {
		return secondLong;
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
	
	
	/**
	 * get the second field
	 * 
	 * @return the second field
	 */
	public String getSecondValueAsString() {
		if(secondType == WritableComparableType.TEXT)
			return secondText.toString();
		else if(secondType == WritableComparableType.INT)
			return secondInt.toString();
		else
			return secondLong.toString();
	}

	public void write(DataOutput out) throws IOException {
		fType.write(out);
		sType.write(out);
		
		if(firstType == WritableComparableType.TEXT)
			firstText.write(out);
		else if(firstType == WritableComparableType.INT)
			firstInt.write(out);
		else
			firstLong.write(out);
		
		if(secondType == WritableComparableType.TEXT)
			secondText.write(out);
		else if(secondType == WritableComparableType.INT)
			secondInt.write(out);
		else
			secondLong.write(out);
	}

	public void readFields(DataInput in) throws IOException {
		fType.readFields(in);
		sType.readFields(in);
		
		firstType = WritableComparableType.fromType(fType.get());
		secondType = WritableComparableType.fromType(sType.get());
		
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
		
		if(secondType == WritableComparableType.TEXT) {
			secondText = new Text();
			secondText.readFields(in);
		} else if(secondType == WritableComparableType.INT) {
			secondInt = new IntWritable();
			secondInt.readFields(in);
		} else {
			secondLong = new LongWritable();
			secondLong.readFields(in);
		}
	}

	/**
	 * compare method for comparing 2 HDFSWritable object together
	 */
	public int compareTo(Object object) {
		HDFSWritablePair hwp2 = (HDFSWritablePair) object;
		int cmp = this.firstType.compareTo(hwp2.firstType);
		if(cmp != 0)
			return cmp;
		
		if(firstType == WritableComparableType.TEXT)
			cmp = firstText.compareTo(hwp2.firstText);
		else if(firstType == WritableComparableType.INT)
			cmp = firstInt.compareTo(hwp2.firstInt);
		else
			cmp = firstLong.compareTo(hwp2.firstLong);
		
		if (cmp != 0)
			return cmp;
		
		cmp = this.secondType.compareTo(hwp2.secondType);
		if(cmp != 0)
			return cmp;
		
		if(secondType == WritableComparableType.TEXT)
			return secondText.compareTo(hwp2.secondText);
		else if(secondType == WritableComparableType.INT)
			return secondInt.compareTo(hwp2.secondInt);
		else
			return secondLong.compareTo(hwp2.secondLong);
	}
	
	public int firstHashCode() {
		if(firstType == WritableComparableType.TEXT)
			return firstText.hashCode();
		else if(firstType == WritableComparableType.INT)
			return firstInt.hashCode();
		else
			return firstLong.hashCode();
	}
	
	public int secondHashCode() {
		if(secondType == WritableComparableType.TEXT)
			return secondText.hashCode();
		else if(secondType == WritableComparableType.INT)
			return secondInt.hashCode();
		else
			return secondLong.hashCode();
	}

	/**
	 * Only use the first field when computing the hash code so that
	 * data gets split only by the first field from the HDFSWritablePair 
	 * across the Nodes.
	 */
	public int hashCode() {
		int hash = 1;
		hash = hash * 31 + firstHashCode();
		hash = hash * 31 + secondHashCode();
		
		return hash;
	}

	/**
	 * Only compare the first field in for the equals
	 */
	public boolean equals(Object o) {
		HDFSWritablePair p = (HDFSWritablePair) o;
		
		if(this.getFirstType() != p.getFirstType())
			return false;
		
		if(firstType == WritableComparableType.TEXT)
			return firstText.equals(p.firstText);
		else if(firstType == WritableComparableType.INT)
			return firstInt.equals(p.firstInt);
		else
			return firstLong.equals(p.firstLong);
	}
	
	public static int compareFirstValues(HDFSWritablePair p1, HDFSWritablePair p2) {
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
	
	public static int compareFirstValuesReverse(HDFSWritablePair p1, HDFSWritablePair p2) {
		return - compareFirstValues(p1, p2);
	}
	
	public static int compareSecondValues(HDFSWritablePair p1, HDFSWritablePair p2) {
		int cmp = p1.getSecondType().compareTo(p2.getSecondType());
		if(cmp != 0)
			return cmp;
		
		if(p1.getSecondType() == WritableComparableType.TEXT)
			return compareValues(p1.getSecondText(), p2.getSecondText());
		else if(p1.getSecondType() == WritableComparableType.INT)
			return compareValues(p1.getSecondInt(), p2.getSecondInt());
		else
			return compareValues(p1.getSecondLong(), p2.getSecondLong());
	}
	
	public static int compareSecondValuesReverse(HDFSWritablePair p1, HDFSWritablePair p2) {
		return - compareSecondValues(p1, p2);
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
