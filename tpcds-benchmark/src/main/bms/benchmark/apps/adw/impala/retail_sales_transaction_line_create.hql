drop table ADW_sales_transaction_line2;
CREATE TABLE IF NOT EXISTS adw_sales_transaction_line2 (
        SALES_TRAN_ID INT,                      
        SALES_TRAN_LINE_NUM INT,                 
        ITEM_ID STRING,                    
        ITEM_QTY SMALLINT,                    
        UNIT_SELLING_PRICE_AMT FLOAT,             
        UNIT_COST_AMT FLOAT,                      
        TRAN_LINE_STATUS_CD STRING,         
        SALES_TRAN_LINE_START_DTTM STRING,             
        TRAN_LINE_SALES_TYPE_CD STRING,     
        SALES_TRAN_LINE_END_DTTM STRING,               
        LOCATION_ID INT,                   
        TX_TIME STRING    
)
PARTITIONED BY (TRAN_DATE_P STRING)
STORED AS SequenceFile
;

SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET mapred.child.java.opts=-Xmx2048m;
SET hive.mapred.reduce.tasks.speculative.execution=false;

SET hive.exec.compress.output=true;
SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
SET mapred.output.compression.type=BLOCK;

INSERT OVERWRITE TABLE adw_sales_transaction_line2 PARTITION (TRAN_DATE_P)
  SELECT
        SALES_TRAN_ID,
        SALES_TRAN_LINE_NUM,
        ITEM_ID,
        ITEM_QTY,
        UNIT_SELLING_PRICE_AMT,
        UNIT_COST_AMT,
        TRAN_LINE_STATUS_CD,
        SALES_TRAN_LINE_START_DTTM,
        TRAN_LINE_SALES_TYPE_CD,
        SALES_TRAN_LINE_END_DTTM,
        LOCATION_ID,
        TX_TIME,
        TRAN_LINE_DATE as TRAN_DATE_P
  FROM ADW_sales_transaction_line_temp
DISTRIBUTE BY TRAN_DATE_P
;
