#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

log_info "($0) Evaluating topic classifier"

JOB_IN_DIR=${BMS_HADOOP_HDFS_ROOT}/gnip/twitter/parsed/part*
JOB_OUT_DIR=output/evaluate/twitter/topic
MODEL_FILE=${BMS_HADOOP_HDFS_ROOT}/classifier/train/topic/sentiment.model

log_info "($0) Using language model file: $MODEL_FILE"

log_info "($0) Clearing target path $JOB_OUT_DIR"
hadoop fs -rmr $JOB_OUT_DIR

log_info "($0) Evaluating topic classifier with compression=$BMS_EXEC_APP_COMPRESS_SA"
hadoop jar $BENCHMARK_PATH/apps/lib/aster-mr.jar com.asterdata.sentiment.ClassifierEvaluate evaluateFileLoc=$JOB_IN_DIR outputFileLoc=$JOB_OUT_DIR contentFieldPos=6 modelFileLoc=$MODEL_FILE evaluateFileDelimiter=\t outputInFields=true inputFileFormat=text compress=$BMS_EXEC_APP_COMPRESS_SA

rc=$?
if [ $rc != 0 ]
then
  log_error "ERROR: ($0) Runtime error evaluating topic classifier"
  exit $rc
fi

echo $BMS_TOKEN_EXIT_OK