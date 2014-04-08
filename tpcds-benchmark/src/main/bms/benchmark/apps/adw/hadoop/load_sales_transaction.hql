SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET mapred.child.java.opts=-Xmx2048m;
SET hive.mapred.reduce.tasks.speculative.execution=false;

INSERT OVERWRITE TABLE ADW_sales_transaction PARTITION (TRAN_DATE_P)
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

