--
-- Setup hive parameters then run INSERT INTO TABLE SELECT
--

-- Compress intermediate outputs
SET hive.exec.compress.intermediate=true;
SET mapreduce.map.output.compress=true;
SET mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;

--Reuse JVM for upto 10 tasks
SET mapreduce.job.jvm.numtasks=50;

--  Enable map join but set default size (cluster was 1GB)
SET hive.auto.convert.join=true;
SET hive.auto.convert.join.noconditionaltask=true;
SET hive.auto.convert.join.noconditionaltask.size=500000000;

-- Enable dynamic partitioning
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET hive.exec.max.dynamic.partitions.pernode=20000;
SET hive.exec.max.dynamic.partitions=20000;
SET hive.exec.max.created.files=150000;

-- use store_sales_t1 to ease re-setting test, should be identical performance to appending to table.
DROP TABLE IF EXISTS store_sales_t1;
CREATE TABLE store_sales_t1 LIKE store_sales;

-- EXPLAIN
INSERT INTO TABLE store_sales_t1 PARTITION (ss_sold_date_sk)
SELECT
        ss_sold_time_sk, 
        ss_item_sk, 
        ss_customer_sk, 
        ss_cdemo_sk, 
        ss_hdemo_sk,
        ss_addr_sk,
        ss_store_sk, 
        ss_promo_sk,
        ss_ticket_number, 
        ss_quantity, 
        ss_wholesale_cost, 
        ss_list_price,
        ss_sales_price,
        ss_ext_discount_amt,
        ss_ext_sales_price,
        ss_ext_wholesale_cost, 
        ss_ext_list_price, 
        ss_ext_tax, 
        ss_coupon_amt,
        ss_net_paid,
        ss_net_paid_inc_tax,
        ss_net_profit,
        ss_sold_date_sk
FROM ssv
;

