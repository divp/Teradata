#!/bin/bash

# Validate target table structures after initialization load

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

if [ $# -gt 0 ]
then
    log_info "Found command line arguments: running selective validation of named tables [$*]"
    tables=$*
else
    log_info "No command line arguments: running complete validation of initial load "
    tables=(inventory ship_mode time_dim web_site household_demographics store call_center warehouse catalog_page item web_page catalog_returns catalog_sales customer date_dim income_band store_returns customer_demographics web_returns customer_address reason store_sales promotion web_sales)
fi

bteq_output=$(mktemp)
sql=''
i=0
for table in ${tables[@]}
do
    #log_info "Processing table $table"
    (( i+=1 ))
    sql="${sql} SELECT CAST('${table}' AS VARCHAR(25)) AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM ${table} "
    if [ $i -lt ${#tables[@]} ] 
    then
        sql="${sql} UNION"
    else
        sql="${sql};"
    fi
done
    #input_file=$BMS_SOURCE_DATA_PATH/tpcds/$BMS_ETL_SCALE_TAG/000/${table}.dat
    
bteq <<EOF >/dev/null
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    .EXPORT FILE=${bteq_output}
    .SET SEPARATOR '|'
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    ${sql}

    .LOGOFF;
    .EXIT;
EOF
    #[ $? -ne 0 ] && (tail $log; log_error "Error running fastload script ($script). See detail log: $log"; exit 1)
cat $bteq_output

echo $BMS_TOKEN_EXIT_OK

