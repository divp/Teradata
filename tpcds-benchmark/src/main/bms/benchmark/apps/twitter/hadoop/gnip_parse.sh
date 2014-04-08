#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

JOB_IN_DIR=$BMS_HADOOP_HDFS_ROOT/raw/gnip/twitter
JOB_OUT_DIR=$BMS_HADOOP_HDFS_ROOT/gnip/twitter/parsed
JAR_DIR=$BENCHMARK_PATH/apps/lib

log_info "($0) Parsing JSON markup from $JOB_IN_DIR into $JOB_IN_DIR"

hadoop fs -rmr $JOB_OUT_DIR

log_info "($0) Running JSON parser with compression=$BMS_EXEC_APP_COMPRESS_SA"

hadoop jar $JAR_DIR/aster-mr.jar com.asterdata.gnip.GnipTwitterParser inputFileLoc=$JOB_IN_DIR outputFileLoc=$JOB_OUT_DIR gnipMappingFileLoc=$BENCHMARK_PATH/apps/twitter/hadoop/gnip_files_mapping.properties compress=$BMS_EXEC_APP_COMPRESS_SA
rc=$? 

if [ $rc != 0 ] 
then 
  log_error "($0) Runtime error in parser, exiting"
  exit $rc
fi

log_info "($0) Done parsing JSON markup"

echo $BMS_TOKEN_EXIT_OK
