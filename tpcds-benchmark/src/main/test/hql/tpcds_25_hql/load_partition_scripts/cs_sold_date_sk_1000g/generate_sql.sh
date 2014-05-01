i=0
for f in `cat filelist`
do
	VAL1=`head -n 1 $f`
	VAL2=`tail -n 1 $f`
	HQL="set hive.stats.dbclass = jdbc:mysql;
set hive.stats.jdbcdriver=com.mysql.jdbc.Driver;
set hive.aux.jars.path=/user/hive/hive-aux/mysql-connector-java-5.1.18-bin.jar;
set hive.enforce.bucketing=true;
set hive.exec.dynamic.partition.mode=nonstrict;
insert into table catalog_sales partition (cs_sold_date_sk)
select
cs_sold_time_sk,
cs_ship_date_sk,
cs_bill_customer_sk,
cs_bill_cdemo_sk,
cs_bill_hdemo_sk,
cs_bill_addr_sk,
cs_ship_customer_sk,
cs_ship_cdemo_sk,
cs_ship_hdemo_sk,
cs_ship_addr_sk,
cs_call_center_sk,
cs_catalog_page_sk,
cs_ship_mode_sk,
cs_warehouse_sk,
cs_item_sk,
cs_promo_sk,
cs_order_number,
cs_quantity,
cs_wholesale_cost,
cs_list_price,
cs_sales_price,
cs_ext_discount_amt,
cs_ext_sales_price,
cs_ext_wholesale_cost,
cs_ext_list_price,
cs_ext_tax,
cs_coupon_amt,
cs_ext_ship_cost,
cs_net_paid,
cs_net_paid_inc_tax,
cs_net_paid_inc_ship,
cs_net_paid_inc_ship_tax,
cs_net_profit,
cs_sold_date_sk
from raw_tpcds1000g.catalog_sales where cs_sold_date_sk between $VAL1 and $VAL2;"
	echo $HQL > insert.$i.sql
	let i=i+1
done
