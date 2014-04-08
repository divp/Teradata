#!/bin/bash

#
# Executes all the sentiment related pre-query test cases (except data load) and capture their times 
#
#

HOME_DIR=/home/htester
HIVE_DIR=$HOME_DIR/impala/twitter

#
# 1. Creating Hive analytic tables
#

echo "creating and loading activity stream analytic tables"
START=$(date +%s)

hive -f $HIVE_DIR/activity_stream.hql

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds to create and load Hive analytic tables"
echo "##########################################################################################################"

# Refresh Imapala metadata
impala-shell -f /home/htester/impala/refresh.impala
