package com.asterdata.util;

public class TextLib {
	// Regularize content string to reduce irrelevant features and improve model performance
	public static String regularize(String content) {
		String output = content;
		output = output.replaceAll("@\\w+","@USER"); // replace user references with generic token
		output = output.replaceAll("http://[\\w\\./]+","@LINK"); // replace links with generic token
		output = output.replaceAll("\\$[0-9]+(\\.[0-9]+)*", "@CURRENCY"); // replace currency values with generic token
		output = output.replaceAll("([A-Za-z])\\1\\1+","$1"); // normalize repeated letters beyond 2
		output = output.replaceAll("((:|8|=)(-|o)?(\\)|D))|<3|&lt;3","@EMPOS"); // normalize positive emoticons
		output = output.replaceAll("(:|8|=)(-|o)?\\(","@EMNEG"); // normalize negative emoticons
		output = output.replaceAll("(X|x|;)(-|o)?(\\)|D)","@EMHUM"); // normalize humor emoticons
		output = output.replaceAll("\\&[a-z]+;",""); // remove URL-encoded characters, e.g. '&lt;'
		output = output.replaceAll("(?<=(\\W|^))RT(?=(\\W|$))",""); // remove retweet marker 'RT'
		output = output.replaceAll("[^\\p{Alnum}@#\\s]+", " "); // remove remaining punctuation (preserve @ and #)
		output = output.replaceAll("(?<=(\\s|^))\\s+",""); // normalize whitespace
		output = output.toLowerCase(); // make lowercase
		return output;
	}
	
	// Remove unusable text payload for JSON parsing
	public static String normalize(String string) {
	    String s = string.replaceAll("\\u000A"," "); // remove LF
		s = s.replaceAll("\\u000D", " "); // remove CR
		s = s.replaceAll("\\u0009", " "); // remove tab
		s = s.replaceAll("\\\\t", " "); // remove escaped '\t'
		s = s.replaceAll("\\\\n", " "); // remove escaped '\n'
		s = s.replaceAll("\\n", " "); // remove unescaped '\n'
		s = s.replaceAll("\\\\r", " "); // remove escaped'\r'
		s = s.replaceAll("\\r", " "); // remove unescaped'\r'
		s = s.replaceAll("\\\\[0-9][0-9][0-9]*"," "); // remove encoded non-printable unicode, e.g. \355
		s = s.replaceAll("\\s\\s*"," "); // normalize blank space sequences
		s = s.replaceAll("[^\\p{ASCII}]", ""); // remove non-ASCII characters
		s = s.replaceAll("\\\\[0-9\\\\]*",""); // remove all numbers preceded by \
		// Replace unescaped double quotes in text payload by escaped double quotes: '\"'
		// Java's Pattern.compile() requires escaping of regex pattern, so the expression below is
		// interpreted as ...compile("(?<![\\\[\{,:])\"(?![\\\]\},:])")
		// or 'add \ to escape all quotes that are NOT preceded by either '\', '[', '{', ',' or ':'
		// NOR followed by either '\', ']', '}', ',' or ':'
    	s = s.replaceAll("(?<![\\\\\\[\\{,:])\"(?![\\\\\\]\\},:])","\\\\\"");
		return(s);
	}
}

