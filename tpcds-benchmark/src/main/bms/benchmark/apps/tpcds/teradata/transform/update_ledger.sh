#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

target_table='fact_agg_sales_ledger'

log_info "Updating ${target_table} table"
bteq <<EOF 2>&1 > $log
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    MERGE INTO ${target_table} AS t_tgt
    USING (
        SELECT   
            t_d.d_date,
            t_i.i_item_id,
            t_i.i_brand,
            t_s.s_store_id,
            t_s.s_store_name,
            COUNT(*) AS transaction_count,
            SUM(t_ss.ss_quantity) AS quantity,
            SUM(t_ss.ss_wholesale_cost) AS wholesale_cost,
            SUM(t_ss.ss_net_paid) AS net_paid,
            SUM(
                CASE 
                WHEN t_i.i_category_id IN (1,3,4,6) 
                AND t_cdemo.cd_marital_status IN ('S','W','D')
                AND t_promo.p_channel_dmail = 'Y'
                THEN
                    t_ss.ss_net_paid
                 ELSE
                    0
                 END
             ) singles_promo_apparel_net_paid,
            SUM(
                CASE 
                WHEN t_i.i_category_id NOT IN (1,3,4,6) 
                AND t_cdemo.cd_marital_status NOT IN ('S','W','D')
                AND t_cdemo.cd_credit_rating NOT IN ('High Risk','Unknown')
                AND t_cdemo.cd_dep_count > 0
                AND t_promo.p_channel_dmail = 'Y'
                THEN
                    t_ss.ss_net_paid
                 ELSE
                    0
                 END
             ) family_credit_promo_apparel_net_paid
        /* Add other similar SUM/CASE metrics */
        FROM 
            store_sales t_ss
        /* Add catalog_sales and web_sales*/
        LEFT OUTER JOIN
            item t_i
        ON
            t_ss.ss_item_sk = t_i.i_item_sk
        LEFT OUTER JOIN
            date_dim t_d
        ON
            t_ss.ss_sold_date_sk = t_d.d_date_sk
        LEFT OUTER JOIN
            store t_s
        ON
            t_ss.ss_store_sk = t_s.s_store_sk
        LEFT OUTER JOIN
            customer_demographics t_cdemo
            ON   
            t_ss.ss_cdemo_sk = t_cdemo.cd_demo_sk
        LEFT OUTER JOIN
            promotion t_promo
            ON   
            t_ss.ss_promo_sk = t_promo.p_promo_sk   
        GROUP BY 
            t_d.d_date,
            t_i.i_item_id,
            t_i.i_brand,
            t_s.s_store_id,
            t_s.s_store_name
    ) AS t_src
    ON t_src.d_date = t_tgt.d_date
    AND t_src.i_item_id = t_tgt.i_item_id
    AND t_src.s_store_id = t_tgt.s_store_id
    WHEN MATCHED THEN UPDATE SET 
        i_brand = t_src.i_brand,
        s_store_name = t_src.s_store_name,
        transaction_count = t_src.transaction_count,
        quantity = t_src.quantity,
        wholesale_cost = t_src.wholesale_cost,
        net_paid = t_src.net_paid,
        singles_promo_apparel_net_paid = t_src.singles_promo_apparel_net_paid,
        family_credit_promo_apparel_net_paid = t_src.family_credit_promo_apparel_net_paid
    WHEN NOT MATCHED THEN INSERT VALUES (   
        t_src.d_date,
        t_src.i_item_id,
        t_src.i_brand,
        t_src.s_store_id,
        t_src.s_store_name,
        t_src.transaction_count,
        t_src.quantity,
        t_src.wholesale_cost,
        t_src.net_paid,
        t_src.singles_promo_apparel_net_paid,
        t_src.family_credit_promo_apparel_net_paid
    );
    
    SELECT COUNT(*) FROM ${target_table};

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



