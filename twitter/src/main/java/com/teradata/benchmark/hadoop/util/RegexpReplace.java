package com.teradata.benchmark.hadoop.util;

public class RegexpReplace {
	private int fieldPos;
	private String regex;
	private String replacementVal;
	
	public RegexpReplace(int fieldPos, String regex, String replacementVal) {
		this.fieldPos = fieldPos;
		this.regex = regex;
		this.replacementVal = replacementVal;
	}

	public int getFieldPos() {
		return fieldPos;
	}

	public String getRegex() {
		return regex;
	}

	public String getReplacementVal() {
		return replacementVal;
	}
	
	public String replaceValue(String[] inputValues) {
		return inputValues[fieldPos].replaceAll(regex, replacementVal);
	}
	
	public String replaceValue(String inputValue) {
		return inputValue.replaceAll(regex, replacementVal);
	}
	
	public static RegexpReplace valueOf(String regexpReplaceFunction) {
		//regexpReplace(5, '@em[a-z]+', '')
		String function = regexpReplaceFunction.substring(regexpReplaceFunction.indexOf("(")+1,
				regexpReplaceFunction.indexOf(")"));
		String[] functionValues = function.split(",", 3);
		
		String regex = functionValues[1].trim();
		regex = regex.replaceAll("'", "");
		String replaceValue = functionValues[2].trim();
		replaceValue = replaceValue.replaceAll("'", "");
		
		return new RegexpReplace(Integer.parseInt(functionValues[0].trim()), regex, replaceValue);
	}
}
