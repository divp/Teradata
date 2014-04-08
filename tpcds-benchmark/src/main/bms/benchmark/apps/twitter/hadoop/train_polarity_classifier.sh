#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

hadoop fs -rmr ${BMS_HADOOP_HDFS_ROOT}/gnip/twitter/model/data/polarity

log_info "($0) Training polarity classifier with compression=$BMS_EXEC_APP_COMPRESS_SA"
hadoop jar ${BENCHMARK_PATH}/apps/lib/aster-mr.jar com.asterdata.sentiment.ClassifierTrain evaluateFileLoc=$BMS_HADOOP_HDFS_ROOT/gnip/twitter/model/data/polarity/ evaluateFileDelimiter='\t' categoryFieldPos=2 contentFieldPos=1 categories="+,-,=" modelFileLoc=$BMS_HADOOP_HDFS_ROOT/classifier/train/polarity inputFileFormat=sequence compress=$BMS_EXEC_APP_COMPRESS_SA

rc=$? 

if [ $rc != 0 ] 
then 
  log_error "($0) Runtime error polarity classifier training, exiting"
  exit $rc
fi

log_info "($0) Done with polarity classifier training"

echo $BMS_TOKEN_EXIT_OK
