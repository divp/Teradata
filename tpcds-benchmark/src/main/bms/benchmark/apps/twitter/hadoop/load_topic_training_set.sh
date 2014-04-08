#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

hadoop fs -rmr ${BMS_HADOOP_HDFS_ROOT}/classifier
hadoop fs -mkdir ${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train
hadoop fs -mkdir ${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train_input
hadoop fs -mkdir ${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train_resample_input
hadoop fs -put ${BMS_SOURCE_DATA_PATH}/twitter/training_input.dat ${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train_input
hadoop fs -put ${BMS_SOURCE_DATA_PATH}/twitter/training_resampling.dat ${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train_resample_input

hive <<EOF
DROP TABLE topic_train_input;
CREATE EXTERNAL TABLE topic_train_input (
   row_num STRING,
   topic1 STRING,
   topic2 STRING,
   topic3 STRING,
   desc_txt STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train_input/'
;

DROP TABLE topic_train_resample_input;
CREATE EXTERNAL TABLE topic_train_resample_input (row_num STRING)
ROW FORMAT DELIMITED LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train_resample_input/'
;

DROP TABLE topic_train;
CREATE EXTERNAL TABLE topic_train (
   row_num BIGINT,
   topic1 STRING,
   topic2 STRING,
   topic3 STRING,
   desc_txt STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train'
;

DROP TABLE topic_train_resample;
CREATE EXTERNAL TABLE topic_train_resample (row_num BIGINT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${BMS_HADOOP_HDFS_ROOT}/classifier/model/topic/train_resample'
;

INSERT OVERWRITE TABLE topic_train_resample
  SELECT CAST(TRIM(ti.row_num) as BIGINT)
  FROM topic_train_resample_input ti;

INSERT OVERWRITE TABLE topic_train
  SELECT CAST(TRIM(ti.row_num) as BIGINT),
         ti.topic1,
         ti.topic2,
         ti.topic3,
         ti.desc_txt
  FROM topic_train_input ti
  JOIN topic_train_resample tr ON (ti.row_num = tr.row_num)
;
EOF

rc=$?
if [ $rc -eq 0 ]
then
	echo $BMS_TOKEN_EXIT_OK
else
    echo $BMS_TOKEN_EXIT_ERROR
fi
exit $rc