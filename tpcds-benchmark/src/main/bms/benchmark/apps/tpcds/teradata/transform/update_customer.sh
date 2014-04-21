#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

cat <<EOF >/dev/null
TPC-DS ETL update prototype    
Method 1: non history keeping
Dimension Type: Non-Historical
for every row v in view V
   begin transaction /* minimal transaction boundary */
   if there is a row d in table D where the business keys of v and d are equal
      replace all non-primary key values of d with values from v
   end-if
   end transaction
end-for

    -- Validation query (_bak_04150923_customer has snapshot of target before update)
    
    CREATE TABLE 
    SELECT TOP 10 * FROM
    (SELECT 
   c_customer_id, c_customer_sk || c_current_cdemo_sk || c_current_hdemo_sk || c_current_addr_sk || c_first_shipto_date_sk || c_first_sales_date_sk || c_salutation || c_first_name || c_last_name || c_preferred_cust_flag || c_birth_day || c_birth_month || c_birth_year || c_birth_country || COALESCE(c_login,'') || c_email_address || c_last_review_date AS x
     FROM customer) t0
     FULL OUTER JOIN
    (SELECT 
   c_customer_id, c_customer_sk || c_current_cdemo_sk || c_current_hdemo_sk || c_current_addr_sk || c_first_shipto_date_sk || c_first_sales_date_sk || c_salutation || c_first_name || c_last_name || c_preferred_cust_flag || c_birth_day || c_birth_month || c_birth_year || c_birth_country ||  COALESCE(c_login,'') || c_email_address || c_last_review_date AS x
     FROM _bak_04150923_customer) t1
     ON t0.c_customer_id = t1.c_customer_id
     WHERE t0.x <> t1.x 
EOF

target_table='customer'
etl_view='custv'
tmp_table=${etl_view}_tmp

log_info "Updating ${target_table} table"
bteq <<EOF 2>&1 > $log
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};

    DROP TABLE ${tmp_table};
    
    CREATE TABLE ${tmp_table} AS (
    SELECT 
        c_customer_sk
        ,c_customer_id
        ,c_current_cdemo_sk
        ,c_current_hdemo_sk
        ,c_current_addr_sk
        ,c_first_shipto_date_sk
        ,c_first_sales_date_sk
        ,c_salutation
        ,c_first_name
        ,c_last_name
        ,c_preferred_cust_flag
        ,c_birth_day
        ,c_birth_month
        ,c_birth_year
        ,c_birth_country
        ,c_login
        ,c_email_address
        ,c_last_review_date
    FROM ${etl_view}) WITH DATA;
    
    UPDATE ${target_table}
    FROM ${tmp_table} t1
    SET
        c_current_cdemo_sk = t1.c_current_cdemo_sk,
        c_current_hdemo_sk = t1.c_current_hdemo_sk,
        c_current_addr_sk = t1.c_current_addr_sk,
        c_first_shipto_date_sk = t1.c_first_shipto_date_sk,
        c_first_sales_date_sk = t1.c_first_sales_date_sk,
        c_salutation = t1.c_salutation,
        c_first_name = t1.c_first_name,
        c_last_name = t1.c_last_name,
        c_preferred_cust_flag = t1.c_preferred_cust_flag,
        c_birth_day = t1.c_birth_day,
        c_birth_month = t1.c_birth_month,
        c_birth_year = t1.c_birth_year,
        c_birth_country = t1.c_birth_country,
        c_login = t1.c_login,
        c_email_address = t1.c_email_address,
        c_last_review_date = t1.c_last_review_date
    WHERE
        ${target_table}.c_customer_id = t1.c_customer_id
    ;

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
