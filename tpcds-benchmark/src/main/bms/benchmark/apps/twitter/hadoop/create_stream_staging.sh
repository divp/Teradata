#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

hive <<EOF
DROP TABLE activity_stream_stage;

CREATE EXTERNAL TABLE activity_stream_stage (
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
LOCATION '${BMS_HADOOP_HDFS_ROOT}/gnip/twitter/parsed/'
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




