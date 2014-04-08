#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

EXEC_APP_COMPRESS_SA=$1 # expects 'true' or 'false'

echo "($0) Evaluating classifiers"

JOB_IN_DIR=$HADOOP_HDFS_ROOT/gnip/twitter/parsed/part*
JOB_OUT_DIR=output/evaluate/twitter/topic
MODEL_FILE=$HADOOP_HDFS_ROOT/classifier/train/topic/sentiment.model


hadoop fs -rmr ${HADOOP_HDFS_ROOT}/classifier/evaluate/twitter/topic ${CL_STDERR_REDIR}

echo "($0) Using language model file: $MODEL_FILE"

echo "($0) Clearing target path $JOB_OUT_DIR"

trap "echo ERROR: ($0) Runtime error clearing directory structure for topic training set; exit $?" ERR

hadoop fs -rmr $JOB_OUT_DIR

if [ $EXEC_APP_COMPRESS_SA == true ]
then
    echo "($0) Evaluating topic classifier with compression"
    hadoop jar $BENCHMARK_PATH/apps/lib/aster-mr.jar com.asterdata.sentiment.ClassifierEvaluate evaluateFileLoc=$JOB_IN_DIR outputFileLoc=$JOB_OUT_DIR contentFieldPos=6 modelFileLoc=$MODEL_FILE evaluateFileDelimiter=\\t outputInFields=true inputFileFormat=text compress=true
else
    echo "($0) Evaluating topic classifier without compression"
    hadoop jar $BENCHMARK_PATH/apps/lib/aster-mr.jar com.asterdata.sentiment.ClassifierEvaluate evaluateFileLoc=$JOB_IN_DIR outputFileLoc=$JOB_OUT_DIR contentFieldPos=6 modelFileLoc=$MODEL_FILE evaluateFileDelimiter=\\t outputInFields=true inputFileFormat=text compress=false
fi
rc=$?
if [ $rc != 0 ]
then
  echo "ERROR: ($0) Runtime error evaluating topic classifier"
  exit $rc
fi

JOB_IN_DIR=output/evaluate/twitter/topic/part*
JOB_OUT_DIR=output/evaluate/twitter/topicandpolarity
MODEL_FILE=$HADOOP_HDFS_ROOT/classifier/train/polarity/sentiment.model
echo "($0) Clearing target path $JOB_OUT_DIR"
trap "echo ERROR: ($0) Runtime error clearing directory structure for topic training set; exit $?" ERR
hadoop fs -rmr $JOB_OUT_DIR

if [ $EXEC_APP_COMPRESS_SA == true ]
then
    echo "($0) Evaluating polarity classifier with compression"
    hadoop jar $BENCHMARK_PATH/apps/lib/aster-mr.jar com.asterdata.sentiment.ClassifierEvaluate evaluateFileLoc=$JOB_IN_DIR outputFileLoc=$JOB_OUT_DIR contentFieldPos=8 modelFileLoc=$MODEL_FILE evaluateFileDelimiter=\\t outputInFields=true "regexpReplace(8, '@em[a-z]+', '')" inputFileFormat=text compress=true
else
    echo "($0) Evaluating polarity classifier without compression"
    hadoop jar $BENCHMARK_PATH/apps/lib/aster-mr.jar com.asterdata.sentiment.ClassifierEvaluate evaluateFileLoc=$JOB_IN_DIR outputFileLoc=$JOB_OUT_DIR contentFieldPos=8 modelFileLoc=$MODEL_FILE evaluateFileDelimiter=\\t outputInFields=true "regexpReplace(8, '@em[a-z]+', '')" inputFileFormat=text compress=false
fi

rc=$?

if [ $rc != 0 ]
then
  echo "ERROR: ($0) Runtime error evaluating polarity classifier"
  exit $rc
fi

echo "($0) Creating and loading activity stream analytic tables"
trap "echo ERROR: ($0) Runtime error in Hive queries to create target activity_stream table; exit $?" ERR
hive -f $HIVE_DIR/activity_stream_create.hql
trap "echo ERROR: ($0) Runtime error in Hive queries to insert into target activity_stream table; exit $?" ERR
if [ $EXEC_APP_COMPRESS_SA == true ]
then
    echo "($0) Running bulk insert into activity_stream with compression"
    hive -f $HIVE_DIR/activity_stream_bulk_insert.hql
else
    echo "($0) Running bulk insert into activity_stream without compression"
    hive -f $HIVE_DIR/activity_stream_bulk_insert_uncompressed.hql
fi

echo "($0) Loading stopwords"
hive -f $HIVE_DIR/stopwords.hql
trap "echo ERROR: ($0) Runtime error in Hive queries load stopwords; exit $?" ERR
