CREATE DATABASE IF NOT EXISTS parquet_tpcds1000g;
USE parquet_tpcds1000g;

CREATE TABLE IF NOT EXISTS call_center LIKE raw_tpcds1000g.call_center stored as parquetfile;
INSERT OVERWRITE TABLE call_center SELECT * FROM raw_tpcds1000g.call_center;

CREATE TABLE IF NOT EXISTS catalog_page LIKE raw_tpcds1000g.catalog_page stored as parquetfile;
INSERT OVERWRITE TABLE catalog_page SELECT * FROM raw_tpcds1000g.catalog_page;

CREATE TABLE IF NOT EXISTS catalog_returns LIKE raw_tpcds1000g.catalog_returns stored as parquetfile;
INSERT OVERWRITE TABLE catalog_returns SELECT * FROM raw_tpcds1000g.catalog_returns;

CREATE TABLE IF NOT EXISTS catalog_sales LIKE raw_tpcds1000g.catalog_sales stored as parquetfile;
INSERT OVERWRITE TABLE catalog_sales SELECT * FROM raw_tpcds1000g.catalog_sales;

CREATE TABLE IF NOT EXISTS customer LIKE raw_tpcds1000g.customer stored as parquetfile;
INSERT OVERWRITE TABLE customer SELECT * FROM raw_tpcds1000g.customer;

CREATE TABLE IF NOT EXISTS customer_address LIKE raw_tpcds1000g.customer_address stored as parquetfile;
INSERT OVERWRITE TABLE customer_address SELECT * FROM raw_tpcds1000g.customer_address;

CREATE TABLE IF NOT EXISTS customer_demographics LIKE raw_tpcds1000g.customer_demographics stored as parquetfile;
INSERT OVERWRITE TABLE customer_demographics SELECT * FROM raw_tpcds1000g.customer_demographics;

CREATE TABLE IF NOT EXISTS date_dim LIKE raw_tpcds1000g.date_dim stored as parquetfile;
INSERT OVERWRITE TABLE date_dim SELECT * FROM raw_tpcds1000g.date_dim;

CREATE TABLE IF NOT EXISTS household_demographics LIKE raw_tpcds1000g.household_demographics stored as parquetfile;
INSERT OVERWRITE TABLE household_demographics SELECT * FROM raw_tpcds1000g.household_demographics;

CREATE TABLE IF NOT EXISTS income_band LIKE raw_tpcds1000g.income_band stored as parquetfile;
INSERT OVERWRITE TABLE income_band SELECT * FROM raw_tpcds1000g.income_band;

CREATE TABLE IF NOT EXISTS inventory LIKE raw_tpcds1000g.inventory stored as parquetfile;
INSERT OVERWRITE TABLE inventory SELECT * FROM raw_tpcds1000g.inventory;

CREATE TABLE IF NOT EXISTS item LIKE raw_tpcds1000g.item stored as parquetfile;
INSERT OVERWRITE TABLE item SELECT * FROM raw_tpcds1000g.item;

CREATE TABLE IF NOT EXISTS promotion LIKE raw_tpcds1000g.promotion stored as parquetfile;
INSERT OVERWRITE TABLE promotion SELECT * FROM raw_tpcds1000g.promotion;

CREATE TABLE IF NOT EXISTS reason LIKE raw_tpcds1000g.reason stored as parquetfile;
INSERT OVERWRITE TABLE reason SELECT * FROM raw_tpcds1000g.reason;

CREATE TABLE IF NOT EXISTS ship_mode LIKE raw_tpcds1000g.ship_mode stored as parquetfile;
INSERT OVERWRITE TABLE ship_mode SELECT * FROM raw_tpcds1000g.ship_mode;

CREATE TABLE IF NOT EXISTS store LIKE raw_tpcds1000g.store stored as parquetfile;
INSERT OVERWRITE TABLE store SELECT * FROM raw_tpcds1000g.store;

CREATE TABLE IF NOT EXISTS store_returns LIKE raw_tpcds1000g.store_returns stored as parquetfile;
INSERT OVERWRITE TABLE store_returns SELECT * FROM raw_tpcds1000g.store_returns;

CREATE TABLE IF NOT EXISTS time_dim LIKE raw_tpcds1000g.time_dim stored as parquetfile;
INSERT OVERWRITE TABLE time_dim SELECT * FROM raw_tpcds1000g.time_dim;

CREATE TABLE IF NOT EXISTS warehouse LIKE raw_tpcds1000g.warehouse stored as parquetfile;
INSERT OVERWRITE TABLE warehouse SELECT * FROM raw_tpcds1000g.warehouse;

CREATE TABLE IF NOT EXISTS web_page LIKE raw_tpcds1000g.web_page stored as parquetfile;
INSERT OVERWRITE TABLE web_page SELECT * FROM raw_tpcds1000g.web_page;

CREATE TABLE IF NOT EXISTS web_returns LIKE raw_tpcds1000g.web_returns stored as parquetfile;
INSERT OVERWRITE TABLE web_returns SELECT * FROM raw_tpcds1000g.web_returns;

CREATE TABLE IF NOT EXISTS web_sales LIKE raw_tpcds1000g.web_sales stored as parquetfile;
INSERT OVERWRITE TABLE web_sales SELECT * FROM raw_tpcds1000g.web_sales;

CREATE TABLE IF NOT EXISTS web_site LIKE raw_tpcds1000g.web_site stored as parquetfile;
INSERT OVERWRITE TABLE web_site SELECT * FROM raw_tpcds1000g.web_site;

SHOW TABLES;
