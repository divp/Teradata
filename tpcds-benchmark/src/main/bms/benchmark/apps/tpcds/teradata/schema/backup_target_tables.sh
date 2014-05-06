#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

function print_help {
    echo "Usage:"
    echo "$(basename $0) copy       Copy current content into backup version and retain original target content"
    echo "$(basename $0) move       Move current content into backup table (via rename) and create empty target"
}    

if [ $# -eq 1 ]
then
    option=$1
    case $option in
    copy) 
        log_info "Using copy option: Copy current content into backup version and retain original target content"
        ;;
    move)
        log_info "Using move option: Move current content into backup table (via rename) and create empty target"
        ;;
    *)
        echo "Invalid option"
        print_help
        exit 1
        ;;
    esac
else
    echo "Expecting backup option as single argument"
    print_help
    exit 1
fi    

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

fact_tables=(catalog_sales catalog_returns inventory store_sales store_returns web_sales web_returns)
dim_tables=(call_center catalog_page customer customer_address customer_demographics date_dim household_demographics income_band item promotion reason ship_mode store time_dim warehouse web_page web_site)
#my_tables=(store)
tstamp=$(date +%m%d%H%M%S)
#for table in ${my_tables[@]} 
for table in ${dim_tables[@]} ${fact_tables[@]}
do
    backup_table="_bak_${tstamp}_${table}"
    case $option in
    copy)
        log_info "Copying data from table ${table} into backup table ${backup_table}"
        bteq_output=$(mktemp)
        bteq <<EOF > $bteq_output
            .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
            DATABASE ${BMS_TERADATA_DBNAME_ETL1};

            CREATE TABLE ${backup_table} AS (
                SELECT * FROM ${table}
            ) WITH DATA;

            .LOGOFF;
            .EXIT;
EOF
    rc=$?
    ;;
    move)
        log_info "Moving table contents (rename) from ${table} into ${backup_table}, keep empty source"
        bteq_output=$(mktemp)
        remove_fastload_table_lock ${table}
        bteq <<EOF > $bteq_output
            .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
            DATABASE ${BMS_TERADATA_DBNAME_ETL1};

            RENAME TABLE ${table} TO ${backup_table};
            
            CREATE TABLE ${table} AS (
                SELECT * FROM ${backup_table}
            ) WITH NO DATA;

            .LOGOFF;
            .EXIT;
EOF
    rc=$?
    ;;
    esac
    
    if [ $rc -ne 0 ]
    then
        log_error "Error executing table backup"
        exit 1
    fi  
    log_info "Done"
    
done

