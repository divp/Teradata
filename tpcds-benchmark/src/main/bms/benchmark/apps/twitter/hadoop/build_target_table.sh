#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

log_info "($0) Building target classifier table"

HIVE_COMPRESSION_OPTIONS=''

if [ $BMS_EXEC_APP_COMPRESS_SA == 'true' ]
then
    HIVE_COMPRESSION_OPTIONS="$BMS_HADOOP_ENABLE_COMPRESSION_PARMS"
else
	HIVE_COMPRESSION_OPTIONS="$BMS_HADOOP_DISABLE_COMPRESSION_PARMS"
fi

hive <<EOF
drop table activity_stream_stage2;
CREATE EXTERNAL TABLE activity_stream_stage2 (
    polarity STRING,
    polarity_score DOUBLE,
    topic STRING,
    topic_score DOUBLE,
    activity_dt STRING,
    record_type_id INT,
    document_id BIGINT,
    activity_ts STRING,
    doc_txt STRING,
    doc_txt_reg STRING,
    is_retweet BOOLEAN,
    user_id BIGINT,
    user_name STRING,
    screen_name STRING,
    follower_count INT,
    friends_count INT,
    user_location STRING,
    in_reply_to_status_id BIGINT,
    language STRING,
    klout_score INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${BMS_HADOOP_HDFS_ROOT}/classifier/evaluate/twitter/topicandpolarity'
;

drop table activity_stream;
CREATE TABLE activity_stream (
    record_type_id INT,
    document_id BIGINT,
    posted_ts STRING,
    posted_hour INT,
    posted_day INT,
    posted_week INT,
    posted_month INT,
    posted_year INT,
    doc_txt STRING,
    doc_txt_reg STRING,
    is_retweet BOOLEAN,
    user_id BIGINT,
    user_name STRING,
    screen_name STRING,
    follower_count INT,
    friends_count INT,
    user_location STRING,
    in_reply_to_status_id BIGINT,
    language STRING,
    klout_score INT,
    polarity STRING,
    polarity_score DOUBLE,
    topic STRING,
    topic_score DOUBLE)
PARTITIONED BY (posted_dt STRING)
STORED AS RCFILE
;

SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET hive.exec.max.dynamic.partitions=500;
SET hive.exec.max.dynamic.partitions.pernode=500;

$HIVE_COMPRESSION_OPTIONS

SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET hive.exec.max.dynamic.partitions=500;
SET hive.exec.max.dynamic.partitions.pernode=500;
SET mapred.child.java.opts=-Xmx2048m ;
SET mapred.reduce.tasks=40 ;
SET hive.mapred.reduce.tasks.speculative.execution=false ;

INSERT OVERWRITE TABLE activity_stream PARTITION (posted_dt)
    SELECT
        record_type_id,
        document_id,
        activity_ts,
        hour(regexp_replace(activity_ts, 'T', ' ')) as posted_hour,
        dayofmonth(activity_ts) as posted_day,
        weekofyear(activity_ts) as posted_week,
        month(activity_ts) as posted_month,
        year(activity_ts) as posted_year,
        doc_txt,
        doc_txt_reg,
        is_retweet,
        user_id,
        user_name,
        screen_name,
        follower_count,
        friends_count,
        user_location,
        in_reply_to_status_id,
        language,
        klout_score,
        polarity,
        polarity_score,
        topic,
        topic_score,
        activity_dt as posted_dt
  FROM activity_stream_stage2
DISTRIBUTE BY posted_dt;

EOF

rc=$?
if [ $rc -ne 0 ]
then
  log_error "ERROR: ($0) Runtime error building activity_stream target table"
  exit $rc
fi

echo $BMS_TOKEN_EXIT_OK
