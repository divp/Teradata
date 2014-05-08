#!/bin/bash

# Load source data files into target table structures (initialization load)

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

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

    if [ $? -ne 0 ]
    then
        tail $log
        log_error "Error generating fastload script. See detail log: $log"
        exit 1
    fi
    
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

function recreate_table {
    
    table_name=$1
    
    log_info "Creating empty copy of table ${table_name}"
    
    bteq <<EOF
        .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
        DATABASE ${BMS_TERADATA_DBNAME_ETL1};
        
        SELECT 1 FROM dbc.TablesV WHERE databasename = DATABASE AND TableName = '${table_name}_bak';
        .IF activitycount = 0 THEN .GOTO skipDrop
        DROP TABLE ${table_name}_bak;
        
        .LABEL skipDrop
        
        CREATE TABLE ${table_name}_bak AS (
        SELECT * FROM ${table_name}
        ) WITH NO DATA;
    
        DROP TABLE ${table_name};
    
        RENAME TABLE ${table_name}_bak to ${table_name};
        .LOGOFF
        .QUIT
EOF

    rc=$?
    if [ $rc -ne 0 ]
    then
        log_error "Unable to recreate table $table_name"
        exit 1
    fi
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
    input_file=$BMS_SOURCE_DATA_PATH/tpcds/$BMS_ETL_SCALE_TAG/000/${table}.dat
    
    recreate_table $table
    
    script=$(mktemp /tmp/$(basename $0).fastload.script.XXXXXXXXXX)
    get_fastload_script $table $input_file > $script
    
    log_info "Running fastload script ($script)" | tee -a $log
    fastload <$script >> $log
    rc=$?
    if [ $rc -ne 0 ]
    then
        log_error "Error running fastload script ($script). See detail log: $log (tail below)"
        tail -20 $log
        exit 1
    fi
done

echo $BMS_TOKEN_EXIT_OK

