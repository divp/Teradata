SVRIP=localhost
SVRPORT=34570
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.catalog_sales_raw
TD_ERROR_TABLE_1=tpcds1000g.catalog_sales_raw_E1
TD_ERROR_TABLE_2=tpcds1000g.catalog_sales_raw_E2
TD_LOG_TABLE=tpcds1000g.catalog_sales_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list catalog_sales.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
cs_sold_date_sk (VARCHAR(100)),
cs_sold_time_sk (VARCHAR(100)),
cs_ship_date_sk (VARCHAR(100)),
cs_bill_customer_sk (VARCHAR(100)),
cs_bill_cdemo_sk (VARCHAR(100)),
cs_bill_hdemo_sk (VARCHAR(100)),
cs_bill_addr_sk (VARCHAR(100)),
cs_ship_customer_sk (VARCHAR(100)),
cs_ship_cdemo_sk (VARCHAR(100)),
cs_ship_hdemo_sk (VARCHAR(100)),
cs_ship_addr_sk (VARCHAR(100)),
cs_call_center_sk (VARCHAR(100)),
cs_catalog_page_sk (VARCHAR(100)),
cs_ship_mode_sk (VARCHAR(100)),
cs_warehouse_sk (VARCHAR(100)),
cs_item_sk (VARCHAR(100)),
cs_promo_sk (VARCHAR(100)),
cs_order_number (VARCHAR(100)),
cs_quantity (VARCHAR(100)),
cs_wholesale_cost (VARCHAR(70)),
cs_list_price (VARCHAR(70)),
cs_sales_price (VARCHAR(70)),
cs_ext_discount_amt (VARCHAR(70)),
cs_ext_sales_price (VARCHAR(70)),
cs_ext_wholesale_cost (VARCHAR(70)),
cs_ext_list_price (VARCHAR(70)),
cs_ext_tax (VARCHAR(70)),
cs_coupon_amt (VARCHAR(70)),
cs_ext_ship_cost (VARCHAR(70)),
cs_net_paid (VARCHAR(70)),
cs_net_paid_inc_tax (VARCHAR(70)),
cs_net_paid_inc_ship (VARCHAR(70)),
cs_net_paid_inc_ship_tax (VARCHAR(70)),
cs_net_profit (VARCHAR(70))
DEFINE=END
DML="INSERT INTO tpcds1000g.catalog_sales_raw(
    cs_sold_date_sk,
    cs_sold_time_sk,
    cs_ship_date_sk,
    cs_bill_customer_sk,
    cs_bill_cdemo_sk,
    cs_bill_hdemo_sk,
    cs_bill_addr_sk,
    cs_ship_customer_sk,
    cs_ship_cdemo_sk,
    cs_ship_hdemo_sk,
    cs_ship_addr_sk,
    cs_call_center_sk,
    cs_catalog_page_sk,
    cs_ship_mode_sk,
    cs_warehouse_sk,
    cs_item_sk,
    cs_promo_sk,
    cs_order_number,
    cs_quantity,
    cs_wholesale_cost,
    cs_list_price,
    cs_sales_price,
    cs_ext_discount_amt,
    cs_ext_sales_price,
    cs_ext_wholesale_cost,
    cs_ext_list_price,
    cs_ext_tax,
    cs_coupon_amt,
    cs_ext_ship_cost,
    cs_net_paid,
    cs_net_paid_inc_tax,
    cs_net_paid_inc_ship,
    cs_net_paid_inc_ship_tax,
    cs_net_profit
    )
    VALUES
    (
    :cs_sold_date_sk,
    :cs_sold_time_sk,
    :cs_ship_date_sk,
    :cs_bill_customer_sk,
    :cs_bill_cdemo_sk,
    :cs_bill_hdemo_sk,
    :cs_bill_addr_sk,
    :cs_ship_customer_sk,
    :cs_ship_cdemo_sk,
    :cs_ship_hdemo_sk,
    :cs_ship_addr_sk,
    :cs_call_center_sk,
    :cs_catalog_page_sk,
    :cs_ship_mode_sk,
    :cs_warehouse_sk,
    :cs_item_sk,
    :cs_promo_sk,
    :cs_order_number,
    :cs_quantity,
    :cs_wholesale_cost,
    :cs_list_price,
    :cs_sales_price,
    :cs_ext_discount_amt,
    :cs_ext_sales_price,
    :cs_ext_wholesale_cost,
    :cs_ext_list_price,
    :cs_ext_tax,
    :cs_coupon_amt,
    :cs_ext_ship_cost,
    :cs_net_paid,
    :cs_net_paid_inc_tax,
    :cs_net_paid_inc_ship,
    :cs_net_paid_inc_ship_tax,
    :cs_net_profit
)"

