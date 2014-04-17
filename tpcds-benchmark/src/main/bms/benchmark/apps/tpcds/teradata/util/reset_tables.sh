#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"
BACKUP_SET=_bak_04150923

tables=( customer )
for table in ${tables[@]}
do
    log_info "Loading ${table} table"
    bteq <<EOF 2>&1 > $log
        .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
        DATABASE ${BMS_TERADATA_DBNAME_ETL1};

        DELETE FROM ${table};
        INSERT INTO ${table} SELECT * FROM ${BACKUP_SET}_${table};
        
        .LOGOFF;
        .EXIT;
EOF
    rc=$?

    if [ $rc -ne 0 ]
    then
        tail $log
        log_error "Error loading table ${table}. See detail log: $log"
        exit 1
    fi

    log_info "Table loaded ${table} successfully"
done