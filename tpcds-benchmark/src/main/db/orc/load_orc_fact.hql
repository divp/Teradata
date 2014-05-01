
USE orc_tpcds1000g;

SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET hive.exec.max.dynamic.partitions.pernode=20000;
SET hive.exec.max.dynamic.partitions=20000;
SET hive.exec.max.created.files=150000;


INSERT OVERWRITE TABLE store_sales PARTITION (ss_sold_date_sk)
SELECT  ss_sold_time_sk,
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
        case when ss_sold_date_sk='' then null else ss_sold_date_sk end ss_sold_date_sk
FROM raw_tpcds1000g.store_sales
distribute by ss_sold_date_sk
;
