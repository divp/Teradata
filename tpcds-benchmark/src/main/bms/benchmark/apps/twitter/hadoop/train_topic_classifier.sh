#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

hadoop fs -rmr ${BMS_HADOOP_HDFS_ROOT}/classifier/train/topic

BMS_HADOOP_JAR=$BENCHMARK_PATH/apps/lib/aster-mr.jar
HADOOP_CLASSPATH=$BENCHMARK_PATH/apps/lib/lingpipe-4.1.0.jar
JAVA_OPTS='-Xms1536m -Xmx3072m -XX:+UseSerialGC'


CATEGORIES=arts,business,computers,games,health,home,news,recreation,reference,science,shopping,society,sports

if [ ! -r $BMS_HADOOP_JAR ] || [ ! -r $HADOOP_CLASSPATH ]
then
    log_error "ERROR: ($0) Runtime error running topic classifier: required JAR files $BMS_HADOOP_JAR, $HADOOP_CLASSPATH cannot be accessed "
    echo $BMS_TOKEN_EXIT_ERROR
    exit 1
fi

JOB_IN_DIR=${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train
#JOB_OUT_DIR=$BMS_HADOOP_HDFS_ROOT/classifier/model/topic
JOB_OUT_DIR=${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/trained

log_info "($0) Running training routine for topic classifier"

log_info "($0) Clearing target path $JOB_OUT_DIR"
hadoop fs -rmr $JOB_OUT_DIR

if [ $BMS_EXEC_APP_COMPRESS_SA == true ]
then
    log_info "($0) Executing topic classifier training with compression"
else
    log_info "($0) Executing topic classifier training without compression"
fi

hadoop jar $BMS_HADOOP_JAR com.asterdata.sentiment.ClassifierTrain -libjars $HADOOP_CLASSPATH evaluateFileLoc=$JOB_IN_DIR evaluateFileDelimiter="\|" categoryFieldPos=3 contentFieldPos=5 categories=$CATEGORIES modelFileLoc=$JOB_OUT_DIR compress=$BMS_EXEC_APP_COMPRESS_SA -D mapred.reduce.child.java.opts=JAVA_OPTS

rc=$?
if [ $rc -eq 0 ]
then
	echo $BMS_TOKEN_EXIT_OK
else
    log_error "ERROR: ($0) Runtime error running topic classifier training MR job"
    echo $BMS_TOKEN_EXIT_ERROR
fi
exit $rc