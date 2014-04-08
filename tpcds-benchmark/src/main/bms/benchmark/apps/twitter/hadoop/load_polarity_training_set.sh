#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

hadoop fs -rmr ${BMS_HADOOP_HDFS_ROOT}/gnip/twitter/model/data/polarity

hive <<EOF
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET hive.exec.max.dynamic.partitions=500;
SET hive.exec.max.dynamic.partitions.pernode=500;

DROP TABLE polarity_model_data_temp;
CREATE TABLE polarity_model_data_temp (
    document_id BIGINT,
    doc_txt_reg STRING,
    polarity STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS SEQUENCEFILE;

DROP TABLE polarity_model_data;
CREATE EXTERNAL TABLE polarity_model_data (
    doc_txt_reg STRING,
    polarity STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS SEQUENCEFILE
LOCATION '${BMS_HADOOP_HDFS_ROOT}/gnip/twitter/model/data/polarity/'
;

INSERT OVERWRITE table polarity_model_data_temp
   SELECT
        document_id,
        regexp_replace(doc_txt_reg, '@em[a-z]+', '') doc_txt_reg,
        CASE WHEN doc_txt_reg regexp '@empos' AND doc_txt_reg regexp '^((?!@emneg).)*$' THEN '+'
             WHEN doc_txt_reg regexp '@emneg' AND doc_txt_reg regexp '^((?!@empos).)*$' THEN '-'
             WHEN doc_txt_reg regexp '^((?!@empos).)*$' AND doc_txt_reg regexp '^((?!@emneg).)*$' THEN '='
             ELSE '?'
        END as polarity
    FROM activity_stream_stage
;

INSERT OVERWRITE table polarity_model_data
    SELECT doc_txt_reg, polarity FROM (
        SELECT * FROM polarity_model_data_temp WHERE polarity = '+' order by document_id limit 100000
        UNION ALL
        SELECT * FROM polarity_model_data_temp WHERE polarity = '-' order by document_id limit 100000
        UNION ALL
        SELECT * FROM polarity_model_data_temp WHERE polarity = '=' order by document_id limit 100000
    ) unionresult
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
