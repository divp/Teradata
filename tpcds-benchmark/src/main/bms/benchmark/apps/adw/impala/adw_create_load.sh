#!/bin/bash

#
# 1. Create and load adw hive Impala tables
#

HIVE_DIR=/home/htester/impala/adw

# stepr1. create and load adw_sales_transaction2 table
echo "Starting to load hourly_pv2 partition: WP1a  Conversions before Load (ESG 2b)"
START=$(date +%s)

hive -f $HIVE_DIR/retail_sales_transaction_create.hql

# stepr2. create and load adw_sales_transaction_line2 table
hive -f $HIVE_DIR/retail_sales_transaction_line_create.hql

END=$(date +%s)
DIFF=$(( $END - $START ))
TOT_TIME=`expr $TOT_TIME + $DIFF`
echo "It took $DIFF seconds to create and load all the adw Impala hive tables"
echo "##########################################################################################################

"

# Refresh Imapala metadata
impala-shell -f /home/htester/impala/refresh.impala
