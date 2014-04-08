#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

hadoop fs -rmr $BMS_HADOOP_HDFS_ROOT/raw/gnip/twitter 2>/dev/null
hadoop fs -mkdir $BMS_HADOOP_HDFS_ROOT/raw/gnip/twitter 2>/dev/null

for f in $BMS_SOURCE_DATA_PATH/twitter/*.log
do
    log_info "($0) Loading input file $f into HDFS: "
    $BENCHMARK_PATH/apps/twitter/hadoop/gnip_load.sh $f
    if [[ $? -ne 0 ]]
        then
        log_error "($0) Unable to load $f"
        exit 1
    fi
done

echo $BMS_TOKEN_EXIT_OK
