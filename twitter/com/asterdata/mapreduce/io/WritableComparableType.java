package com.asterdata.mapreduce.io;


public enum WritableComparableType {
	TEXT(1),INT(2),LONG(3);
	
	private int type;
	
	WritableComparableType(int type) {
		this.type = type;
	}
	
	public int getType() {
		return type;
	}
	
	public static WritableComparableType fromType(int type) {
		if(type == 1)
			return TEXT;
		else if(type ==2)
			return INT;
		else
			return LONG;
	}
}
