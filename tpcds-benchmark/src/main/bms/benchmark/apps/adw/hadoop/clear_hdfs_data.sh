#!/bin/sh
set -o errexit

echo "Deleting HDFS directory $1"
BASE_PATH="$1"
hadoop fs -rmr $BASE_PATH/\*

echo "Recreating HDFS directory structure"
hadoop fs -mkdir $BASE_PATH/associate
hadoop fs -mkdir $BASE_PATH/district
hadoop fs -mkdir $BASE_PATH/item
hadoop fs -mkdir $BASE_PATH/item_inventory
hadoop fs -mkdir $BASE_PATH/location
hadoop fs -mkdir $BASE_PATH/return_transaction_line
hadoop fs -mkdir $BASE_PATH/sales_transaction
hadoop fs -mkdir $BASE_PATH/sales_transaction_line
