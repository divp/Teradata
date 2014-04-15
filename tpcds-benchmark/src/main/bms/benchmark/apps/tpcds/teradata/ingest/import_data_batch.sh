#!/bin/bash

# Generate fastload scripts from live data dictionary definitions

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

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

        select columnname from dbc.columns where tablename='${table_name}';

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

log_info "Dropping staging tables" | tee -a $log
$(dirname $0)/../util/run_sql_script.sh $(dirname $0)/../schema/drop_staging_tables.sql >> $log
[ $? -ne 0 ] && (tail $log; log_error "Error dropping staging tables. See detail log: $log"; exit 1)

log_info "Creating staging tables" | tee -a $log
$(dirname $0)/../util/run_sql_script.sh $(dirname $0)/../schema/create_staging_tables.sql >> $log
[ $? -ne 0 ] && (tail $log; log_error "Error creating staging tables. See detail log: $log"; exit 1)

tables=(s_call_center s_catalog_order s_catalog_order_lineitem s_catalog_page s_catalog_returns s_customer s_customer_address s_inventory s_item s_promotion s_purchase s_purchase_lineitem s_store s_store_returns s_warehouse s_web_order s_web_order_lineitem s_web_page s_web_returns s_web_site s_zip_to_gmt)
for table in ${tables[@]}
do
    log_info "Processing table $table"
    if [[ $table =~ 's_customer' ]]
    then
        echo "################### SKIPPING $table !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        continue
    fi

    input_file=${BMS_SOURCE_DATA_PATH}/tpcds/${table}_1.dat
    script=$(mktemp /tmp/$(basename $0).fastload.script.XXXXXXXXXX)
    log_info "Generating fastload script" | tee -a $log
    get_fastload_script $table $input_file > $script
    [ $? -ne 0 ] && (tail $log; log_error "Error generating fastload script. See detail log: $log"; exit 1)
    
    log_info "Running fastload script ($script)" | tee -a $log
    fastload <$script >> $log
    [ $? -ne 0 ] && (tail $log; log_error "Error running fastload script ($script). See detail log: $log"; exit 1)
done
