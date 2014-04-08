SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET mapred.child.java.opts=-Xmx2048m;
SET hive.mapred.reduce.tasks.speculative.execution=false;

INSERT OVERWRITE TABLE ADW_sales_transaction_line PARTITION (TRAN_DATE_P)
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

