#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

target_table='AGG_FACT_AFFINITY'

log_info "Updating ${target_table} table"
bteq <<EOF 2>&1 > $log
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    DROP TABLE tmp_affinity_marginal_freqs;
   
    -- Calculate marginal (prior) frequencies, or counts of distinct transaction keys
    -- by item key for most frequently sold items.
    CREATE TABLE tmp_affinity_marginal_freqs AS (
        SELECT TOP 1000 
        ss_item_sk, COUNT(DISTINCT(ss_ticket_number)) AS freq
        FROM 
            store_sales
        -- Add catalog_sales and web_sales?
        GROUP   BY ss_item_sk
        ORDER   BY freq DESC
    ) WITH DATA;
    
    DROP TABLE tmp_affinity_total_freq;
   
    -- Calculate total number of transactions (used later to derive probabilities)
    CREATE TABLE tmp_affinity_total_freq AS (
        SELECT COUNT(DISTINCT(ss_ticket_number)) AS freq
        FROM 
            store_sales
        -- Add catalog_sales and web_sales?
    ) WITH DATA;
    
    DROP TABLE tmp_affinity_joint_freqs;
    
    -- Calculate joint (posterior) frequencies, or counts of distinct transaction keys
    -- by item pair occurring in the same transaction. Compute only for selected
    -- items from marginal frequency calculation (pruning)
    CREATE TABLE tmp_affinity_joint_freqs AS (
        SELECT t1.ss_item_sk ss_item_sk1, t2.ss_item_sk ss_item_sk2, COUNT(DISTINCT t1.ss_ticket_number) freq
        FROM
            store_sales t1
        INNER JOIN
            store_sales t2
        ON
            t1.ss_ticket_number = t2.ss_ticket_number
        AND
            t1.ss_item_sk <> t2.ss_item_sk
        INNER JOIN
            tmp_affinity_marginal_freqs t3
        ON
            t1.ss_item_sk = t3.ss_item_sk
        INNER JOIN
            tmp_affinity_marginal_freqs t4
        ON
            t2.ss_item_sk = t4.ss_item_sk
        GROUP BY t1.ss_item_sk, t2.ss_item_sk
    ) WITH DATA;

    DROP TABLE fact_affinity_base;
    
    -- Calculate affinity metrics (note floating point arithmetic for log_lift column)
    CREATE TABLE fact_affinity_base AS (
        SELECT
            ss_item_sk1,
            ss_item_sk2,
            observed_prob,
            expected_prob,
            LOG(observed_prob/expected_prob) log_lift
        FROM (
            SELECT
                ss_item_sk1,
                ss_item_sk2,
                (CAST(joint_freq AS FLOAT) / total_freq) AS observed_prob,
                (CAST((mrg_freq1 * mrg_freq2) AS FLOAT) / POWER(total_freq,2)) AS expected_prob
            FROM (
                SELECT
                    t1.ss_item_sk1,
                    t1.ss_item_sk2,
                    t1.freq joint_freq,
                    t1.freq mrg_freq1,
                    t2.freq mrg_freq2,
                    t4.freq total_freq
                FROM
                    tmp_affinity_joint_freqs t1
                INNER JOIN
                    tmp_affinity_marginal_freqs t2
                ON
                    t1.ss_item_sk1 = t2.ss_item_sk
                INNER JOIN
                    tmp_affinity_marginal_freqs t3
                ON
                    t1.ss_item_sk2 = t3.ss_item_sk
                CROSS JOIN
                    tmp_affinity_total_freq t4
            ) tfreq
        ) tprob
    ) WITH DATA;
    
    SELECT COUNT(*) FROM fact_affinity_base;
    
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

