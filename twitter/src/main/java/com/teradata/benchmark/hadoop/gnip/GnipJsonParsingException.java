package com.teradata.benchmark.hadoop.gnip;

public class GnipJsonParsingException extends Exception {
	private static final long serialVersionUID = 2848350738535005829L;
	
	public GnipJsonParsingException() {
		super();
	}
	
	public GnipJsonParsingException(String message) {
		super(message);
	}
	
	public GnipJsonParsingException(String message, Throwable t) {
		super(message, t);
	}
}
