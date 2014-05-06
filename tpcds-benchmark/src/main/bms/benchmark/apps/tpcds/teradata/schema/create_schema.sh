#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

log_info "Creating schema at ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID} DB:${BMS_TERADATA_DBNAME_ETL1}"
bteq_output=$(mktemp)
bteq <<EOF | tee $bteq_output
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};

    .RUN FILE ${BENCHMARK_PATH}/apps/tpcds/teradata/schema/create_staging_tables.sql
    .RUN FILE ${BENCHMARK_PATH}/apps/tpcds/teradata/schema/create_target_tables.sql
    .RUN FILE ${BENCHMARK_PATH}/apps/tpcds/teradata/schema/create_etl_views.sql
    .RUN FILE ${BENCHMARK_PATH}/apps/tpcds/teradata/schema/create_derived_tables.sql

    .LOGOFF;
    .EXIT;
EOF
rc=$?
    
if [ $rc -ne 0 ]
then
    log_error "Error executing table backup"
    exit 1
fi  
log_info "Done"
    
done

