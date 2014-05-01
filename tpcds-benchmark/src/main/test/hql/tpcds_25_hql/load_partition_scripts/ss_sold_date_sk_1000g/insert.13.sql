set hive.stats.dbclass = jdbc:mysql;
set hive.stats.jdbcdriver=com.mysql.jdbc.Driver;
set hive.aux.jars.path=/user/hive/hive-aux/mysql-connector-java-5.1.18-bin.jar;
set hive.enforce.bucketing=true;
set hive.exec.dynamic.partition.mode=nonstrict;
insert into table store_sales partition (ss_sold_date_sk) select ss_sold_time_sk, ss_item_sk, ss_customer_sk, ss_cdemo_sk, ss_hdemo_sk, ss_addr_sk, ss_store_sk, ss_promo_sk, ss_ticket_number, ss_quantity, ss_wholesale_cost, ss_list_price, ss_sales_price, ss_ext_discount_amt, ss_ext_sales_price, ss_ext_wholesale_cost, ss_ext_list_price, ss_ext_tax, ss_coupon_amt, ss_net_paid, ss_net_paid_inc_tax, ss_net_profit, ss_sold_date_sk from raw_tpcds1000g.store_sales where ss_sold_date_sk between 2452118 and 2452217;
