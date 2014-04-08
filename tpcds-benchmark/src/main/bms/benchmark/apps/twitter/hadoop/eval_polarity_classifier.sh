#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

log_info "($0) Evaluating polarity classifier"

JOB_IN_DIR=output/evaluate/twitter/topic/part*
JOB_OUT_DIR=output/evaluate/twitter/topicandpolarity
MODEL_FILE=${BMS_HADOOP_HDFS_ROOT}/classifier/train/polarity/sentiment.model

log_info "($0) Clearing target path $JOB_OUT_DIR"
hadoop fs -rmr $JOB_OUT_DIR

log_info "($0) Evaluating polarity classifier with compression=$BMS_EXEC_APP_COMPRESS_SA"
hadoop jar $BENCHMARK_PATH/apps/lib/aster-mr.jar com.asterdata.sentiment.ClassifierEvaluate evaluateFileLoc=$JOB_IN_DIR outputFileLoc=$JOB_OUT_DIR contentFieldPos=8 modelFileLoc=$MODEL_FILE evaluateFileDelimiter=\\t outputInFields=true "regexpReplace(8, '@em[a-z]+', '')" inputFileFormat=text compress=$BMS_EXEC_APP_COMPRESS_SA

rc=$?
if [ $rc -ne 0 ]
then
  log_error "ERROR: ($0) Runtime error evaluating polarity classifier"
  exit $rc
fi

echo $BMS_TOKEN_EXIT_OK



