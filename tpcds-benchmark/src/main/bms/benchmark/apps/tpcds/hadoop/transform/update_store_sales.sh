#!/bin/bash

set -x
set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
# . $BENCHMARK_PATH/exports.sh
# . $BENCHMARK_PATH/lib/lib.sh

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
hive_db='orc_tpcds1000g'

log_info "Updating ${target_table} table"
# hive -v <<EOF 2>&1 > $log
hive -v --database=${hive_db} -f store_sales_fact.hql
 
rc=$?

if [ $rc -ne 0 ]
then
    tail $log
    log_error "Error loading table ${target_table}. See detail log: $log"
    exit 1
fi

log_info "Table loaded ${target_table} successfully"

echo $BMS_TOKEN_EXIT_OK
