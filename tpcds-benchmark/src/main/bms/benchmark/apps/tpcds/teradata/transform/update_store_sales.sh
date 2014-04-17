#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

cat <<EOF >/dev/null
TPC-DS ETL update prototype    
Method 3: fact table load

for every row v in view V
   begin transaction /* minimal transaction boundary */
   for every type 1 business key column bkc in v
      find row d from dimension table corresponding to bkc
           where business key values are identical
      substitute value in bkc with surrogate key of d
   end for
   for every type 2 business key column bkc in v
      find row d from dimension table corresponding to bkc
      where business key values are identical and rec_end_date is NULL
      substitute value in bkc with surrogate key of d
   end for
   insert v into fact table.
   end transaction
end for

EOF

target_table='store_sales'
etl_view='ssv'

log_info "Updating ${target_table} table"
bteq <<EOF 2>&1 > $log
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    INSERT INTO ${target_table} 
        ss_sold_date_sk, 
        ss_sold_time_sk, 
        ss_item_sk, 
        ss_customer_sk, 
        ss_cdemo_sk, 
        ss_hdemo_sk,
        ss_addr_sk,
        ss_store_sk, 
        ss_promo_sk,
        ss_ticket_number, 
        ss_quantity, 
        ss_wholesale_cost, 
        ss_list_price,
        ss_sales_price,
        ss_ext_discount_amt,
        ss_ext_sales_price,
        ss_ext_wholesale_cost, 
        ss_ext_list_price, 
        ss_ext_tax, 
        ss_coupon_amt,
        ss_net_paid,
        ss_net_paid_inc_tax,
        ss_net_profit
    SELECT
        ss_sold_date_sk, 
        ss_sold_time_sk, 
        ss_item_sk, 
        ss_customer_sk, 
        ss_cdemo_sk, 
        ss_hdemo_sk,
        ss_addr_sk,
        ss_store_sk, 
        ss_promo_sk,
        ss_ticket_number, 
        ss_quantity, 
        ss_wholesale_cost, 
        ss_list_price,
        ss_sales_price,
        ss_ext_discount_amt,
        ss_ext_sales_price,
        ss_ext_wholesale_cost, 
        ss_ext_list_price, 
        ss_ext_tax, 
        ss_coupon_amt,
        ss_net_paid,
        ss_net_paid_inc_tax,
        ss_net_profit
    FROM ${etl_view} WITH DATA;

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


