#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).$BENCHMARK_RUN_ID.log
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

log_info "($0) Building stopwords table"

hive <<EOF
DROP TABLE stopwords;

CREATE TABLE stopwords (
	word STRING
)
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '${BMS_SOURCE_DATA_PATH}/twitter/stopwords.txt' INTO TABLE stopwords;

EOF

rc=$?
if [ $rc -ne 0 ]
then
  log_error "ERROR: ($0) Runtime error building stopwords table"
  exit $rc
fi

echo $BMS_TOKEN_EXIT_OK
