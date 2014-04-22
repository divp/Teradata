/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package org.apache.jmeter.protocol.ssh.sampler;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.jmeter.samplers.AbstractSampler;
import org.apache.jmeter.samplers.Entry;
import org.apache.jmeter.samplers.SampleResult;
import org.apache.jmeter.testbeans.TestBean;
import org.apache.jorphan.logging.LoggingManager;
import org.apache.log.Logger;

import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;

/**
 * SSH Sampler that collects single lines of output and returns
 * them as samples.
 */
public class SSHSampler extends AbstractSampler implements TestBean {
	private static final long serialVersionUID = -1644622213906052022L;

	private static final Logger log = LoggingManager.getLoggerForClass();
	
	private static final int CONNECTION_TIMEOUT = 5000;
	
	private static final String VERSION = "1.4.019";

	private String hostname = "";
	private int port = 22;
	private String username = "";
	private String password = "";
	private String debug = "";
	
	private String command = "date";

	private static final JSch jsch = new JSch();
	private static long requestCount = 0;
	private Session session = null;
	
	private String failureReason = "Unknown";
	
	public SSHSampler() {
		super();
		setName("Teradata SSH Sampler for JMeter  (v." + VERSION + ")");
		log.info("Teradata SSH Sampler for JMeter  (v." + VERSION + ")");
	}
	
	public SampleResult sample(Entry e) {
		SampleResult res = new SampleResult();
		//res.setSampleLabel(username + "@" + hostname + ":" + port);
		res.setSampleLabel(getName());
		final String ERROR_DESC="Runtime error while processing SSH request: ";
		log.info("Processing SSH sample #" + requestCount + " on current sampler instance");
		requestCount++;
		
		// Set up sampler return types
		res.setSamplerData(command);
		res.setDataType(SampleResult.TEXT);
		res.setContentType("text/plain");
		
		String response;
		if (session == null) {
			connect();
		} else {
		    try {
		        if (!session.isConnected()) {
		            log.debug("Session is disconnected. Creating new connection ");
		            connect();
		        }
		    } catch (Exception e1) {
				res.setSuccessful(false);
				res.setResponseCode("Exception");
				res.setResponseMessage(e1.getClass().getName() + ":" + e1.getMessage());
				log.error(ERROR_DESC + e1.getClass().getName() + ":" + e1.getMessage());
		    }
		}
		
		try {
			if(session == null) {
				log.error("Failed to connect to server with credentials " +
						getUsername() + "@" + getHostname() + ":" + getPort() +
						" pw=" + getPassword() + "[sampler instance: '" + getName() + "'][reason:'" + failureReason + "']");
				throw new NullPointerException("Failed to connect to server: " + failureReason);
			}
			response = doCommand(session, command, res);
			res.setResponseData(response.getBytes());
			res.setSuccessful(true);
			res.setResponseCodeOK();
	        res.setResponseMessageOK();
		} catch (Exception e1) {
			res.setSuccessful(false);
			res.setResponseCode("Exception");
			res.setResponseMessage(e1.getClass().getName() + ":" + e1.getMessage());
			log.error(ERROR_DESC + e1.getClass().getName() + ":" + e1.getMessage());
		}
		return res;
	}
	
	private String truncate(String string) {
		final int SUBSTR_LENGTH = 8192;
		if (string.length() > SUBSTR_LENGTH) {
			return string.substring(0, SUBSTR_LENGTH) + "[...]";
		} else {
			return string;
		}
	}
	
	private String readBufferString(BufferedReader reader) throws IOException {
		StringBuilder sbStdout = new StringBuilder();
		for(String line = reader.readLine(); line != null; line = reader.readLine()) {
			sbStdout.append(line);
			sbStdout.append("\n");
		}
		return truncate(sbStdout.toString());
	}
	
	/**
	 * Executes a the given command inside a short-lived channel in the session.
	 * 
	 * Performance could be likely improved by reusing a single channel, though
	 * the gains would be minimal compared to sharing the Session.
	 *  
	 * @param session Session in which to create the channel
	 * @param command Command to send to the server for execution
	 * @return All standard output from the command
	 * @throws JSchException 
	 * @throws IOException Error has occurred down in the network layer
	 */
	private String doCommand(Session session, String command, SampleResult res) throws SSHCommandException, JSchException, IOException {

		long startTime = System.nanoTime();
		
		ChannelExec channel = (ChannelExec) session.openChannel("exec");
		log.info("[" + getName() + "][#" + channel.getId() + "]: executing command '" + truncate(command) + "'" );		
		BufferedReader stdoutReader = new BufferedReader(new InputStreamReader(channel.getInputStream()));
		BufferedReader stderrReader = new BufferedReader(new InputStreamReader(channel.getErrStream()));
		channel.setCommand(command);
		res.sampleStart();
		channel.connect();
		String stdout= readBufferString(stdoutReader);
		String stderr= readBufferString(stderrReader);
		res.sampleEnd();
		float elapsedTime = (System.nanoTime() - startTime)/(1.0e9f);
		
		log.info(
			String.format("[%s][#%d][%.3fs] command response (stdout): '%s'",
			getName(), 
			channel.getId(), 
			elapsedTime, 
			stdout));
		if (stderr.length() > 0) {
			log.error(
					String.format("[%s][#%d] command response (stderr): '%s'",
					getName(), 
					channel.getId(), 
					stderr));
			throw new SSHCommandException("Runtime error in SSH sampler '" + this.getName() + "' [" + stderr +"]" );
		}

		channel.disconnect();
		return stdout;
	}
	
	/**
	 * Sets up SSH Session on connection start
	 */
	public void connect() {
		try {
			log.debug("Creating SSH connection to " +  getUsername() + "@" + getHostname() + ":" + getPort() +
					" [sampler instance: '" + getName() + "']");
			failureReason = "Unknown";
			session = jsch.getSession(getUsername(), getHostname(), getPort());
			session.setPassword(getPassword());
			session.setConfig("StrictHostKeyChecking", "no");
			session.connect(CONNECTION_TIMEOUT);
		} catch (JSchException e) {
			failureReason = e.getMessage();
			session.disconnect();
			session = null;
		}
	}
	
	public static void main(String[] args) throws InterruptedException {
		long startTime = System.nanoTime();
		Thread.sleep(3000);
		float elapsedTime = (System.nanoTime() - startTime)/(1.0e9f);
		System.out.println(String.format("[%.3fs]", elapsedTime));
		//return 0;
	}
	
	// Accessors
	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}
	
	public String getDebug() {
		return debug;
	}

	public void setDebug(String debug) {
		this.debug = debug;
	}
	
	public String getHostname() {
		return hostname;
	}

	public void setHostname(String server) {
		this.hostname = server;
	}
	
	public int getPort() {
		return port;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}
	
	public void finalize() {
		try {
			super.finalize();
		} catch (Throwable e) {
			
		} finally {
			if(session != null) {
				log.debug("Closing SSH connection to " +  getUsername() + "@" + getHostname() + ":" + getPort() +
						" [sampler instance: '" + getName() + "']");
				session.disconnect();
				session = null;
			}
		}
	}
}
