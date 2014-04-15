#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

fact_tables=(s_catalog_order s_catalog_order_lineitem s_catalog_returns s_inventory s_purchase s_purchase_lineitem s_store s_store_returns s_web_order s_web_order_lineitem s_web_returns)
dim_tables=(s_call_center s_catalog_page s_customer s_customer_address s_item s_promotion s_warehouse s_web_page s_web_site s_zip_to_gmt)

my_tables=(customer customer_address store item)
tstamp=$(date +%Y%m%d%H%M%S)
for table in ${my_tables[@]} #${dim_tables[@]} # ${fact_tables[@]}
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


