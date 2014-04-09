package com.teradata.benchmark.hadoop.util;

import org.codehaus.jackson.JsonNode;
import org.codehaus.jackson.map.ObjectMapper;

public class QueryParameters {
	//{"params":[{"fieldName":"timestamp","fieldPos":0,"operator":"likest","value":"03-01-2012"},
	//{"fieldName":"ipAddrs","fieldPos":1,"operator":"likest","value":"153."}]}
	
	private static final ObjectMapper mapper = new ObjectMapper();
	private QueryParam [] params;
	
	public QueryParam [] getParams() {
		return params;
	}

	public void setParams(QueryParam [] queryParams) {
		this.params = queryParams;
	}

	public static QueryParameters parseJson(String jsonDoc) throws Exception {
		JsonNode rootNode = mapper.readTree(jsonDoc);
		return mapper.treeToValue(rootNode, QueryParameters.class);
		
	}
	
	public static class QueryParam {
		private String fieldName;
		private int FieldPos;
		private Operator operator;
		private String value;
		
		public String getFieldName() {
			return fieldName;
		}
		public void setFieldName(String fieldName) {
			this.fieldName = fieldName;
		}
		public int getFieldPos() {
			return FieldPos;
		}
		public void setFieldPos(int fieldPos) {
			FieldPos = fieldPos;
		}
		public Operator getOperator() {
			return operator;
		}
		public void setOperator(String operator) {
			this.operator = Operator.valueOf(operator);
		}
		public String getValue() {
			return value;
		}
		public void setValue(String value) {
			this.value = value;
		}
	}
	
	/**
	 * valid values are:
	 *   eq - equals
	 *   likeSt - string comparesement start with
	 *   likeEnd - string comparesement ends with
	 *   likeCntn - string comparesement contains
	 * 
	 * @author mmichalski
	 *
	 */
	public static enum Operator {
		eq,likeSt,likeEnd,likeCntn,notlikeSt;
	}
	
	public static void main(String[] args) {
		String params = "{\"params\":[{\"fieldName\":\"timestamp\",\"fieldPos\":0,\"operator\":\"likeSt\",\"value\":\"03-01-2012\"},{\"fieldName\":\"ipAddrs\",\"fieldPos\":1,\"operator\":\"likeSt\",\"value\":\"153.\"}]}";
		
		try {
			QueryParameters qps = QueryParameters.parseJson(params);
			for(QueryParam qp: qps.getParams()) {
				System.out.println("field: " + qp.getFieldName());
			}
			
		} catch(Exception e) {
			e.printStackTrace();
		}
		
	}
}
