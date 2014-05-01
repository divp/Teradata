package org.apache.jmeter.protocol.ssh.sampler;

public class SSHCommandException extends Exception {

	private static final long serialVersionUID = 1L;

	public SSHCommandException() {
	}

	public SSHCommandException(String message) {
		super(message);
	}

	public SSHCommandException(Throwable cause) {
		super(cause);
	}

	public SSHCommandException(String message, Throwable cause) {
		super(message, cause);
	}

	public SSHCommandException(String message, Throwable cause,
			boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

}
