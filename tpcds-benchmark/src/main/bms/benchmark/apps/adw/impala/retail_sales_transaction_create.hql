drop table adw_sales_transaction2;
CREATE TABLE IF NOT EXISTS adw_sales_transaction2 (
        SALES_TRAN_ID INT,
        VISIT_ID INT,
        TRAN_STATUS_CD STRING,
        REPORTED_AS_DTTM STRING,
        TRAN_TYPE_CD   STRING,
        MKB_COST_AMT DOUBLE,
        MKB_ITEM_QTY INT,
        MKB_NUMERIC_UNIQUE_ITEMS_QTY SMALLINT,
        MKB_REV_AMT DOUBLE,
        ASSOCIATE_PARTY_ID INT,
        TRAN_START_DTTM_DD STRING,
        TRAN_END_DTTM_DD STRING,
        TRAN_END_HOUR TINYINT,
        TRAN_END_MINUTE TINYINT,
        REWARD_CD STRING
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

INSERT OVERWRITE TABLE adw_sales_transaction2 PARTITION (TRAN_DATE_P)
  SELECT
        SALES_TRAN_ID,
        VISIT_ID,
        TRAN_STATUS_CD,
        REPORTED_AS_DTTM,
        TRAN_TYPE_CD,
        MKB_COST_AMT,
        MKB_ITEM_QTY,
        MKB_NUMERIC_UNIQUE_ITEMS_QTY,
        MKB_REV_AMT,
        ASSOCIATE_PARTY_ID,
        TRAN_START_DTTM_DD,
        TRAN_END_DTTM_DD,
        TRAN_END_HOUR,
        TRAN_END_MINUTE,
        REWARD_CD,
        TRAN_DATE as TRAN_DATE_P
  FROM ADW_sales_transaction_temp
DISTRIBUTE BY TRAN_DATE_P
;

