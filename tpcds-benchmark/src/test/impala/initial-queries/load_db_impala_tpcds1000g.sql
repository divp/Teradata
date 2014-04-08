
create database if not exists impala_tpcds1000g;

use impala_tpcds1000g;

create table if not exists date_dim like raw_tpcds1000g.date_dim stored as parquetfile;



create table if not exists time_dim like raw_tpcds1000g.time_dim stored as parquetfile;
insert overwrite table time_dim select * from raw_tpcds1000g.time_dim;


create table if not exists customer like raw_tpcds1000g.customer stored as parquetfile;
insert overwrite table customer select * from raw_tpcds1000g.customer;


create table if not exists customer_address like raw_tpcds1000g.customer_address stored as parquetfile;
insert overwrite table customer_address select * from raw_tpcds1000g.customer_address;


create table if not exists customer_demographics like raw_tpcds1000g.customer_demographics stored as parquetfile;
insert overwrite table customer_demographics select * from raw_tpcds1000g.customer_demographics;


create table if not exists household_demographics like raw_tpcds1000g.household_demographics stored as parquetfile;
insert overwrite table household_demographics select * from raw_tpcds1000g.household_demographics;


create table if not exists item like raw_tpcds1000g.item stored as parquetfile;



create table if not exists promotion like raw_tpcds1000g.promotion stored as parquetfile;
insert overwrite table promotion select * from raw_tpcds1000g.promotion;


create table if not exists store like raw_tpcds1000g.store stored as parquetfile;


create table if not exists store_sales
(
ss_sold_time_sk int,
ss_item_sk int,
ss_customer_sk int,
ss_cdemo_sk int,
ss_hdemo_sk int,
ss_addr_sk int,
ss_store_sk int,
ss_promo_sk int,
ss_ticket_number int,
ss_quantity int,
ss_wholesale_cost double,
ss_list_price double,
ss_sales_price double,
ss_ext_discount_amt double,
ss_ext_sales_price double,
ss_ext_wholesale_cost double,
ss_ext_list_price double,
ss_ext_tax double,
ss_coupon_amt double,
ss_net_paid double,
ss_net_paid_inc_tax double,
ss_net_profit double
)
partitioned by (ss_sold_date_sk int)
stored as parquetfile
;



show tables;