#!/bin/bash

# Get fastload error data

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

bteq <<EOF
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    .SET RECORDMODE ON
    .EXPORT DATA FILE=/tmp/fastload_error_data.out
    
    LOCKING ROW FOR ACCESS
    SELECT trim(DataParcel) FROM ${BMS_TERADATA_DBNAME_ETL1}.FASTLOAD_ERR1
    ;

    .EXPORT RESET;
    .LOGOFF;
    .QUIT;
EOF
