#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

fact_tables=(catalog_order catalog_sales catalog_returns inventory store store_sales store_returns web_sales web_returns)
dim_tables=(call_center catalog_page customer customer_address customer_demographics date_dim household_demographics income_band item promotion reason ship_mode store time_dim warehouse web_page web_site)

my_tables=(customer customer_address store item)
tstamp=$(date +%m%d%H%M)
#for table in ${my_tables[@]} 
for table in ${dim_tables[@]} # ${fact_tables[@]}
do
    log_info "Backing up table ${table}"
    bteq_output=$(mktemp)
    bteq <<EOF > $bteq_output
        .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
        DATABASE ${BMS_TERADATA_DBNAME_ETL1};

        CREATE TABLE _bak_${tstamp}_${table} AS (
            SELECT * FROM ${table}
        ) WITH DATA;

        .LOGOFF;
        .EXIT;
EOF
done


