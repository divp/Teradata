#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

INFILE=$1
HDFSLOC=$2

if [[ ! -f $INFILE ]]
then
    log_error "($0) File $INFILE not found."
    exit 1
fi

STAGEDIR=$BMS_TEMP_DATA_PATH/stage

[[ ! -d $STAGEDIR ]] && mkdir -p $STAGEDIR

if [[ ! -d $STAGEDIR ]]
then
   log_error "($0) Directory $STAGEDIR not found"
   exit 1
fi

STAGEFILE=$STAGEDIR/$(basename $INFILE)

mv $INFILE $STAGEFILE

log_info "($0) Removing $HDFSLOC/$(basename $INFILE)"
hadoop fs -rm -skipTrash $HDFSLOC/$(basename $INFILE)
log_info "($0) Putting $STAGEFILE into HDFS $HDFSLOC"
hadoop fs -D dfs.block.size=$BMS_HADOOP_PARM_SA_HDFS_BLOCK_SIZE -put $STAGEFILE $HDFSLOC

if [[ $? -ne 0 ]]
then
    log_error "HDFS runtime error when putting $STAGEFILE into $HDFSLOC"
    exit 1
else
	rm $STAGEFILE
fi
