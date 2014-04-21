#!/bin/bash

# Load source data files into target table structures (initialization load)

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

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
        
        DELETE FROM ${table_name};
        
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

if [ $# -gt 0 ]
then
    log_info "Found command line arguments: running selective load of named tables [$*]"
    tables=$*
else
    log_info "No command line arguments: running complete initial load including tables (existing target tables will be dropped and recreated)"
    tables=(inventory ship_mode time_dim web_site household_demographics store call_center warehouse catalog_page item web_page catalog_returns catalog_sales customer date_dim income_band store_returns customer_demographics web_returns customer_address reason store_sales promotion web_sales)
fi

for table in ${tables[@]}
do
    log_info "Processing table $table"
    input_file=$BMS_SOURCE_DATA_PATH/tpcds/$BMS_ETL1_SCALE_TAG/000/${table}.dat
    script=$(mktemp /tmp/$(basename $0).fastload.script.XXXXXXXXXX)
    log_info "Generating fastload script" | tee -a $log
    get_fastload_script $table $input_file > $script
    [ $? -ne 0 ] && (tail $log; log_error "Error generating fastload script. See detail log: $log"; exit 1)
    
    log_info "Running fastload script ($script)" | tee -a $log
    fastload <$script >> $log
    [ $? -ne 0 ] && (tail $log; log_error "Error running fastload script ($script). See detail log: $log"; exit 1)
done

echo $BMS_TOKEN_EXIT_OK

