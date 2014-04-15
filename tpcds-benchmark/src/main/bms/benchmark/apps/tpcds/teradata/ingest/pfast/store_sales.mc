SVRIP=localhost
SVRPORT=61000
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.store_sales_raw
TD_ERROR_TABLE_1=tpcds1000g.store_sales_raw_E1
TD_ERROR_TABLE_2=tpcds1000g.store_sales_raw_E2
TD_LOG_TABLE=tpcds1000g.store_sales_raw_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list store_sales.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
ss_sold_date_sk (VARCHAR(100)),
ss_sold_time_sk (VARCHAR(100)),
ss_item_sk (VARCHAR(100)),
ss_customer_sk (VARCHAR(100)),
ss_cdemo_sk (VARCHAR(100)),
ss_hdemo_sk (VARCHAR(100)),
ss_addr_sk (VARCHAR(100)),
ss_store_sk (VARCHAR(100)),
ss_promo_sk (VARCHAR(100)),
ss_ticket_number (VARCHAR(100)),
ss_quantity (VARCHAR(100)),
ss_wholesale_cost (VARCHAR(70)),
ss_list_price (VARCHAR(70)),
ss_sales_price (VARCHAR(70)),
ss_ext_discount_amt (VARCHAR(70)),
ss_ext_sales_price (VARCHAR(70)),
ss_ext_wholesale_cost (VARCHAR(70)),
ss_ext_list_price (VARCHAR(70)),
ss_ext_tax (VARCHAR(70)),
ss_coupon_amt (VARCHAR(70)),
ss_net_paid (VARCHAR(70)),
ss_net_paid_inc_tax (VARCHAR(70)),
ss_net_profit (VARCHAR(70))
DEFINE=END
DML="INSERT INTO tpcds1000g.store_sales_raw(
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
    )
    VALUES
    (
    :ss_sold_date_sk,
    :ss_sold_time_sk,
    :ss_item_sk,
    :ss_customer_sk,
    :ss_cdemo_sk,
    :ss_hdemo_sk,
    :ss_addr_sk,
    :ss_store_sk,
    :ss_promo_sk,
    :ss_ticket_number,
    :ss_quantity,
    :ss_wholesale_cost,
    :ss_list_price,
    :ss_sales_price,
    :ss_ext_discount_amt,
    :ss_ext_sales_price,
    :ss_ext_wholesale_cost,
    :ss_ext_list_price,
    :ss_ext_tax,
    :ss_coupon_amt,
    :ss_net_paid,
    :ss_net_paid_inc_tax,
    :ss_net_profit
)"

