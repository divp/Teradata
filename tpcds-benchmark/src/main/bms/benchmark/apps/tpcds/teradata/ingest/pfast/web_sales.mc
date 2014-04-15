SVRIP=localhost
SVRPORT=34575
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.web_sales_raw
TD_ERROR_TABLE_1=tpcds1000g.web_sales_raw_E1
TD_ERROR_TABLE_2=tpcds1000g.web_sales_raw_E2
TD_LOG_TABLE=tpcds1000g.web_sales_raw_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list web_sales.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
ws_sold_date_sk (VARCHAR(100)),
ws_sold_time_sk (VARCHAR(100)),
ws_ship_date_sk (VARCHAR(100)),
ws_item_sk (VARCHAR(100)),
ws_bill_customer_sk (VARCHAR(100)),
ws_bill_cdemo_sk (VARCHAR(100)),
ws_bill_hdemo_sk (VARCHAR(100)),
ws_bill_addr_sk (VARCHAR(100)),
ws_ship_customer_sk (VARCHAR(100)),
ws_ship_cdemo_sk (VARCHAR(100)),
ws_ship_hdemo_sk (VARCHAR(100)),
ws_ship_addr_sk (VARCHAR(100)),
ws_web_page_sk (VARCHAR(100)),
ws_web_site_sk (VARCHAR(100)),
ws_ship_mode_sk (VARCHAR(100)),
ws_warehouse_sk (VARCHAR(100)),
ws_promo_sk (VARCHAR(100)),
ws_order_number (VARCHAR(100)),
ws_quantity (VARCHAR(100)),
ws_wholesale_cost (VARCHAR(70)),
ws_list_price (VARCHAR(70)),
ws_sales_price (VARCHAR(70)),
ws_ext_discount_amt (VARCHAR(70)),
ws_ext_sales_price (VARCHAR(70)),
ws_ext_wholesale_cost (VARCHAR(70)),
ws_ext_list_price (VARCHAR(70)),
ws_ext_tax (VARCHAR(70)),
ws_coupon_amt (VARCHAR(70)),
ws_ext_ship_cost (VARCHAR(70)),
ws_net_paid (VARCHAR(70)),
ws_net_paid_inc_tax (VARCHAR(70)),
ws_net_paid_inc_ship (VARCHAR(70)),
ws_net_paid_inc_ship_tax (VARCHAR(70)),
ws_net_profit (VARCHAR(70))
DEFINE=END
DML="INSERT INTO tpcds1000g.web_sales_raw(
    ws_sold_date_sk,
    ws_sold_time_sk,
    ws_ship_date_sk,
    ws_item_sk,
    ws_bill_customer_sk,
    ws_bill_cdemo_sk,
    ws_bill_hdemo_sk,
    ws_bill_addr_sk,
    ws_ship_customer_sk,
    ws_ship_cdemo_sk,
    ws_ship_hdemo_sk,
    ws_ship_addr_sk,
    ws_web_page_sk,
    ws_web_site_sk,
    ws_ship_mode_sk,
    ws_warehouse_sk,
    ws_promo_sk,
    ws_order_number,
    ws_quantity,
    ws_wholesale_cost,
    ws_list_price,
    ws_sales_price,
    ws_ext_discount_amt,
    ws_ext_sales_price,
    ws_ext_wholesale_cost,
    ws_ext_list_price,
    ws_ext_tax,
    ws_coupon_amt,
    ws_ext_ship_cost,
    ws_net_paid,
    ws_net_paid_inc_tax,
    ws_net_paid_inc_ship,
    ws_net_paid_inc_ship_tax,
    ws_net_profit
    )
    VALUES
    (
    :ws_sold_date_sk,
    :ws_sold_time_sk,
    :ws_ship_date_sk,
    :ws_item_sk,
    :ws_bill_customer_sk,
    :ws_bill_cdemo_sk,
    :ws_bill_hdemo_sk,
    :ws_bill_addr_sk,
    :ws_ship_customer_sk,
    :ws_ship_cdemo_sk,
    :ws_ship_hdemo_sk,
    :ws_ship_addr_sk,
    :ws_web_page_sk,
    :ws_web_site_sk,
    :ws_ship_mode_sk,
    :ws_warehouse_sk,
    :ws_promo_sk,
    :ws_order_number,
    :ws_quantity,
    :ws_wholesale_cost,
    :ws_list_price,
    :ws_sales_price,
    :ws_ext_discount_amt,
    :ws_ext_sales_price,
    :ws_ext_wholesale_cost,
    :ws_ext_list_price,
    :ws_ext_tax,
    :ws_coupon_amt,
    :ws_ext_ship_cost,
    :ws_net_paid,
    :ws_net_paid_inc_tax,
    :ws_net_paid_inc_ship,
    :ws_net_paid_inc_ship_tax,
    :ws_net_profit
)"

