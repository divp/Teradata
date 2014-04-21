#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)

function drop_table {
    table=$1
    if [ $# -ne 1 ]
    then
        log_error "Drop table: expecting table name as argument"
        exit 1
    fi
    log_info "Dropping ${table} table"
    bteq <<EOF 2>&1 > $log
        .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
        DATABASE ${BMS_TERADATA_DBNAME_ETL1};
        
        .SET ERRORLEVEL 3807 SEVERITY 0
        
        DROP TABLE ${table};
        
        .LOGOFF
        .QUIT
EOF
}

