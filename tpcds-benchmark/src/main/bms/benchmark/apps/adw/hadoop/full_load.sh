#!/bin/sh
data_dir="/home/data/adw/zippedretail"
mkdir $data_dir/temp
mkdir $data_dir/temp/stage
echo "starting to load files: ...time started: $(date)"
hadoop fs -mkdir /data/raw/retail/associate
hadoop fs -mkdir /data/raw/retail/district
hadoop fs -mkdir /data/raw/retail/item
hadoop fs -mkdir /data/raw/retail/item_inventory
hadoop fs -mkdir /data/raw/retail/location
hadoop fs -mkdir /data/raw/retail/return_transaction_line
hadoop fs -mkdir /data/raw/retail/sales_transaction
hadoop fs -mkdir /data/raw/retail/sales_transaction_line

hadoop fs -put /home/data/adw/zippedretail/ASSOCIATE.csv /data/raw/retail/associate/
hadoop fs -put /home/data/adw/zippedretail/district.csv /data/raw/retail/district/
hadoop fs -put /home/data/adw/zippedretail/item.csv /data/raw/retail/item/
hadoop fs -put /home/data/adw/zippedretail/ITEM_INVENTORY.csv /data/raw/retail/item_inventory/
hadoop fs -put /home/data/adw/zippedretail/location.csv /data/raw/retail/location/
hadoop fs -put /home/data/adw/zippedretail/return_transaction_line.csv /data/raw/retail/return_transaction_line/
hadoop fs -put /home/data/adw/zippedretail/SALES_TRANSACTION.csv /data/raw/retail/sales_transaction/


./retail_load.sh $data_dir/sales_transaction_line.csv $data_dir/temp > adw_stl_loading.out 
echo "File loaded into HDFS location /data/raw/retail/ ....end time: $(date)"


