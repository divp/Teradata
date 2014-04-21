#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

target_table='AGG_FACT_AFFINITY'
etl_view='ssv'

log_info "Updating ${target_table} table"
bteq <<EOF 2>&1 > $log
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    // Calculate prior frequencies, or counts of distinct transaction keys
    by item key. Prune seach to exclude rarely sold items.
    CREATE VIEW fact_mba_support AS
    SELECT  ss_item_sk, COUNT(DISTINCT(ticket_number)) AS txn_count
    INTO  mba_support_tmp
    FROM 
        store_sales
    /* Add catalog_sales and web_sales*/
    GROUP   BY prod_key
    ORDER   BY txn_count DESC
    LIMIT 1000;

    // Identify all transactions involving at least one item of interest
    CREATE VIEW fact_mba_search_space AS
    SELECT  DISTINCT s.ss_item_sk, s.ss_item_sk
    INTO 
    FROM 
       store_sales t
    INNER JOIN
        mba_support_tmp s
        ON   
        t.ss_item_sk= s. ss_item_sk;

    // Calculate global transaction count, allowing calculation of probabilities.
    CREATE VIEW fact_mba_global_tmp AS
    SELECT  COUNT(DISTINCT ss_item_sk) AS txn_count
    FROM fact_mba_search_space; 

    // Calculate affinity metrics (note floating point arithmetic for log_lift column)
    CREATE TABLE fact_mba_base AS    
    SELECT  *
    FROM (
        SELECT
            pk1 AS prod_key1,
            pk2 AS prod_key2,
            MAX(tmp.txn_count) AS mrg_freq,
            MAX(tmp2.txn_count) AS rel_mrg_freq,
            MAX(j.joint_freq) AS joint_freq,
            MAX(tmp3.txn_count) AS total_transactions
            LOG( (MAX(j.joint_freq) - ( MAX(tmp.txn_count) * MAX(tmp2.txn_count) )  ) / MAX(tmp.txn_count) ) AS log_lift
        FROM (
            SELECT
                f1. ss_item_sk AS pk1,
                f2. ss_item_sk AS pk2,
                COUNT(DISTINCT f1. ss_ticket_number) AS joint_freq
            FROM
                fact_mba_search_space f1
            INNER JOIN
                fact_mba_search_space f2
            ON
                f1.ss_ticket_number = f2. ss_ticket_number
            AND
                f1.ss_item_sk <> f2. ss_item_sk
            GROUP BY
                f1.ss_item_sk,f2. ss_item_sk
        ) j
        INNER JOIN fact_mba_support tmp
            ON j.pk1 = tmp. ss_item_sk
        INNER JOIN fact_mba_support tmp2
            ON j.pk2 = tmp2. ss_item_sk
        CROSS JOIN fact_mba_global_tmp tmp3
        GROUP BY
            j.pk1,j.pk2
    ) p;
    
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

