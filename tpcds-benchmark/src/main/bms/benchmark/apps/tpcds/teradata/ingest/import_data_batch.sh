#!/bin/bash

# Load source data files into staging table structures

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

function print_help {
    echo "Usage: $0 -b BATCH_ID -t TABLES"
    echo "Import a data batch identified by BATCH_ID. TABLES allows a comma-delimited list of tables to be loaded; if omitted, all tables in the target are loaded"
}

# Generate fastload scripts from live data dictionary definitions
function get_fastload_script  {
    table_name="$1"
    input_file="$2"
    if [ $# -ne 2 ]
    then
        log_error "Expecting exactly two arguments: [table_name] [input_file]"
        exit 1
    fi
    # Get column list from catalog
    bteq_output=$(mktemp)
    bteq <<EOF > $bteq_output
        .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
        DATABASE ${BMS_TERADATA_DBNAME_ETL1};
        
        SELECT columnName FROM dbc.columns WHERE tableName='${table_name}' AND databaseName='${BMS_TERADATA_DBNAME_ETL1}';

        .LOGOFF;
        .EXIT;
EOF

    out_script=$(mktemp)

    cat <<EOF >$out_script
        
        .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
        DATABASE ${BMS_TERADATA_DBNAME_ETL1};
        
        ERRLIMIT 1;

        SET RECORD VARTEXT '|';
        DEFINE    
EOF

    columns_list=$(mktemp)
    # Parse bteq output and extract column information
    state=0
    # Use state machine to select column names out of BTEQ output
    while read line
    do
        if [[ $state -eq 0 ]] && [[ $line == 'ColumnName' ]]
        then
            state=1
            continue
        fi
        if [[ $state -eq 1 ]] && [[ $line =~ --* ]]
        then
            state=2
            continue
            fi
        if [[ $state -eq 2 ]] 
        then
            if [[ $line =~ ^$ ]]
            then
                break
            else
                echo $line
            fi
        fi
    done <$bteq_output >>$columns_list

    count=0
    column_count=$(cat $columns_list | wc -l)
    while read column
    do
        count=$(( $count + 1 ))
        echo -n "        in_${column} (VARCHAR(200))"
        if [ $count -lt $column_count ]
        then
            echo ','
        else
            echo
        fi
    done < $columns_list >>$out_script

    cat <<EOF >>$out_script
        FILE=$input_file;

        SHOW;
        
        DROP TABLE FASTLOAD_ERR1;
        DROP TABLE FASTLOAD_ERR2;
        
        BEGIN LOADING ${table_name} ERRORFILES FASTLOAD_ERR1, FASTLOAD_ERR2;
        
        INSERT INTO ${table_name} VALUES (
EOF

    count=0
    column_count=$(cat $columns_list | wc -l)
    while read column
    do
        count=$(( $count + 1 ))
        echo -n "        :in_${column}"
        if [ $count -lt $column_count ]
        then
            echo ','
        else
            echo
        fi
    done < $columns_list >>$out_script

    cat <<EOF >>$out_script
        );
        
        END LOADING;
        LOGOFF;
EOF

    rm $bteq_output
    rm $columns_list

    cat $out_script
    rm $out_script
}

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

batch_id=-1
tables=''
while getopts "b:t:" opt
do
    case $opt in
        b) batch_id=$OPTARG ;;
        t) tables=$OPTARG ;;
        \?)
            print_help >&2
            exit 1
        ;;
    esac
done

if [ $batch_id -eq -1 ]
then
    log_error "Expecting batch identifier as single argument"
    print_help >&2
    exit 1
else    
    log_info "Found command line arguments: request for load of batch ${batch_id}"
    batch_dir=$BMS_SOURCE_DATA_PATH/tpcds/$BMS_ETL_SCALE_TAG/$(printf "%03d" ${batch_id})
    if [ -d $batch_dir ]
    then
        log_info "Batch ${batch_id} found at ${batch_dir}"
    else
        log_error "Batch does not exist (${batch_dir})"
        exit 1
    fi
fi    
log_info "No command line arguments: running complete load including all staging tables (existing staging tables will be dropped and recreated)"
tables=(s_call_center s_catalog_order s_catalog_order_lineitem s_catalog_page s_catalog_returns s_customer s_customer_address s_inventory s_item s_promotion s_purchase s_purchase_lineitem s_store s_store_returns s_warehouse s_web_order s_web_order_lineitem s_web_page s_web_returns s_web_site s_zip_to_gmt)

log_info "Dropping staging tables" | tee -a $log
$(dirname $0)/../util/run_sql_script.sh $(dirname $0)/../schema/drop_staging_tables.sql >> $log
[ $? -ne 0 ] && (tail $log; log_error "Error dropping staging tables. See detail log: $log"; exit 1)

log_info "Creating staging tables" | tee -a $log
$(dirname $0)/../util/run_sql_script.sh $(dirname $0)/../schema/create_staging_tables.sql >> $log
[ $? -ne 0 ] && (tail $log; log_error "Error creating staging tables. See detail log: $log"; exit 1)

for table in ${tables[@]}
do
    input_file=${batch_dir}/${table}_${batch_id}.dat
    script=$(mktemp /tmp/$(basename $0).fastload.script.XXXXXXXXXX)
    get_fastload_script $table $input_file > $script
    [ $? -ne 0 ] && (tail $log; log_error "Error generating fastload script. See detail log: $log"; exit 1)
    
    remove_fastload_table_lock $table
    log_info "Running fastload into '${table}' from ${input_file}. Script: ${script}" | tee -a $log
    fastload <$script >> $log
    [ $? -ne 0 ] && (tail $log; log_error "Error running fastload script ($script). See detail log: $log"; exit 1)
done

echo $BMS_TOKEN_EXIT_OK

