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

import java.beans.PropertyDescriptor;

import org.apache.jmeter.testbeans.BeanInfoSupport;

public class SSHSamplerBeanInfo extends BeanInfoSupport {

	public SSHSamplerBeanInfo() {
		super(SSHSampler.class);
		
		createPropertyGroup("Host", // $NON-NLS-1$
				new String[]{
				"Hostname", // $NON-NLS-1$
				"Port" // $NON-NLS-1$
		});
		
		createPropertyGroup("User", // $NON-NLS-1$
				new String[]{
				"Username", // $NON-NLS-1$
				"Password" // $NON-NLS-1$
		});
		
		createPropertyGroup("Execute", new String[]{
				"Command" // $NON-NLS-1$
		});
		
		createPropertyGroup("Debug", new String[]{
				"Debug" // $NON-NLS-1$
		});
		
		PropertyDescriptor p;
		p = property("Wsername"); // $NON-NLS-1$
		p.setValue(NOT_UNDEFINED, Boolean.TRUE);
		p.setValue(DEFAULT, "");
		
		p = property("Password"); // $NON-NLS-1$
		p.setValue(NOT_UNDEFINED, Boolean.TRUE);
		p.setValue(DEFAULT, "");
		
		p = property("Hostname"); // $NON-NLS-1$
		p.setValue(NOT_UNDEFINED, Boolean.TRUE);
		p.setValue(DEFAULT, "");
		
		p = property("Port"); // $NON-NLS-1$
		p.setValue(NOT_UNDEFINED, Boolean.TRUE);
		p.setValue(DEFAULT, new Integer(22));
		
		p = property("Command"); // $NON-NLS-1$
		p.setValue(NOT_UNDEFINED, Boolean.TRUE);
		p.setValue(DEFAULT, "date");
		
		p = property("Debug");
		p.setValue(NOT_UNDEFINED, Boolean.TRUE);
		p.setValue(DEFAULT, false);
		
	}
}
