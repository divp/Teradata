
CREATE DATABASE IF NOT EXISTS raw_ingest_sf1;
USE raw_ingest_sf1;

DROP TABLE IF EXISTS s_purchase_lineitem;

CREATE TABLE s_purchase_lineitem
	(
        plin_purchase_id INT,
        plin_line_number INT,
        plin_item_id STRING ,
        plin_promotion_id STRING,
        plin_quantity INT,
        plin_sale_price DECIMAL(7,2),
        plin_coupon_amt DECIMAL(7,2),
        plin_comment STRING
    )
row format delimited fields terminated by '|' lines terminated by '\n'
stored as textfile
location '/data/benchmark/tpcds/sf1000/001/s_purchase_lineitem';

DROP TABLE IF EXISTS s_purchase;
CREATE TABLE s_purchase
	(
    purc_purchase_id    INT,
    purc_store_id       STRING,
    purc_customer_id    STRING,
    purc_purchase_date  STRING,
    purc_purchase_time  INT,
    purc_register_id    INT,
    purc_clerk_id       INT,
    purc_comment        STRING
) 
row format delimited fields terminated by '|' lines terminated by '\n'
stored as textfile
location '/data/benchmark/tpcds/sf1000/001/s_purchase';
