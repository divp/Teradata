#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

cat <<EOF >/dev/null
TPC-DS ETL update prototype    
Method 2: history keeping
Dimension Type: Historical
for every row v in view V
   begin transaction // minimal transaction boundary
       if there is a row d in table D where the business keys of v and d are equal
     get the row d of the dimension table
                      where the value of rec_end_date is NULL
     update rec_end_date of d with current date minus one day
     update rec_start_date of v with current date
   end-if 
   generate next primary key value pkv of D
   insert v into D including pkv as primary key and NULL as rec_end_date
   end transaction
end-for
EOF

target_table='store'
etl_view='storv'
tmp_table=${etl_view}_tmp

drop_table ${tmp_table}

log_info "Updating ${target_table} table"
bteq <<EOF 2>&1 > $log
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    -- Save ETL view data in temporary table (required to preserve state before update step below)
    CREATE TABLE ${tmp_table} AS (
    SELECT 
        s_store_sk
        ,s_store_id
        ,s_rec_start_date
        ,s_rec_end_date
        ,s_closed_date_sk
        ,s_store_name
        ,s_number_employees
        ,s_floor_space
        ,s_hours
        ,s_manager
        ,s_market_id
        ,s_geography_class
        ,s_market_desc
        ,s_market_manager
        ,s_division_id
        ,s_division_name
        ,s_company_id
        ,s_company_name
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
        ,s_country
        ,s_gmt_offset
        ,s_tax_percentage
    FROM ${etl_view}) WITH DATA;
    
    -- Update target table
    UPDATE ${target_table}
    SET 
        s_rec_end_date = CURRENT_DATE - 1
    WHERE  s_rec_end_date IS NULL
    AND s_store_id IN (SELECT s_store_id FROM ${etl_view});
    
    -- Insert new rows
    INSERT INTO ${target_table} (
        s_store_sk
        ,s_store_id
        ,s_rec_start_date
        ,s_rec_end_date
        ,s_closed_date_sk
        ,s_store_name
        ,s_number_employees
        ,s_floor_space
        ,s_hours
        ,s_manager
        ,s_market_id
        ,s_geography_class
        ,s_market_desc
        ,s_market_manager
        ,s_division_id
        ,s_division_name
        ,s_company_id
        ,s_company_name
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
        ,s_country
        ,s_gmt_offset
        ,s_tax_percentage
    )
    SELECT *
    FROM ${tmp_table} ;

    .LOGOFF;
    .EXIT;
EOF
rc=$?

if [ $rc -ne 0 ]
then
    tail $log
    log_error "Error loading table ${target_table}. See detail log: $log"
    exit 1
fi

log_info "Table loaded ${target_table} successfully"

echo $BMS_TOKEN_EXIT_OK
