SVRIP=localhost
SVRPORT=34578
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.catalog_returns_raw
TD_ERROR_TABLE_1=tpcds1000g.catalog_returns_raw_E1
TD_ERROR_TABLE_2=tpcds1000g.catalog_returns_raw_E2
TD_LOG_TABLE=tpcds1000g.catalog_returns_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list catalog_returns.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
cr_returned_date_sk (VARCHAR(100)),
cr_returned_time_sk (VARCHAR(100)),
cr_item_sk (VARCHAR(100)),
cr_refunded_customer_sk (VARCHAR(100)),
cr_refunded_cdemo_sk (VARCHAR(100)),
cr_refunded_hdemo_sk (VARCHAR(100)),
cr_refunded_addr_sk (VARCHAR(100)),
cr_returning_customer_sk (VARCHAR(100)),
cr_returning_cdemo_sk (VARCHAR(100)),
cr_returning_hdemo_sk (VARCHAR(100)),
cr_returning_addr_sk (VARCHAR(100)),
cr_call_center_sk (VARCHAR(100)),
cr_catalog_page_sk (VARCHAR(100)),
cr_ship_mode_sk (VARCHAR(100)),
cr_warehouse_sk (VARCHAR(100)),
cr_reason_sk (VARCHAR(100)),
cr_order_number (VARCHAR(100)),
cr_return_quantity (VARCHAR(100)),
cr_return_amount (VARCHAR(70)),
cr_return_tax (VARCHAR(70)),
cr_return_amt_inc_tax (VARCHAR(70)),
cr_fee (VARCHAR(70)),
cr_return_ship_cost (VARCHAR(70)),
cr_refunded_cash (VARCHAR(70)),
cr_reversed_charge (VARCHAR(70)),
cr_store_credit (VARCHAR(70)),
cr_net_loss (VARCHAR(70))
DEFINE=END
DML="INSERT INTO tpcds1000g.catalog_returns_raw(
    cr_returned_date_sk,
    cr_returned_time_sk,
    cr_item_sk,
    cr_refunded_customer_sk,
    cr_refunded_cdemo_sk,
    cr_refunded_hdemo_sk,
    cr_refunded_addr_sk,
    cr_returning_customer_sk,
    cr_returning_cdemo_sk,
    cr_returning_hdemo_sk,
    cr_returning_addr_sk,
    cr_call_center_sk,
    cr_catalog_page_sk,
    cr_ship_mode_sk,
    cr_warehouse_sk,
    cr_reason_sk,
    cr_order_number,
    cr_return_quantity,
    cr_return_amount,
    cr_return_tax,
    cr_return_amt_inc_tax,
    cr_fee,
    cr_return_ship_cost,
    cr_refunded_cash,
    cr_reversed_charge,
    cr_store_credit,
    cr_net_loss
    )
    VALUES
    (
    :cr_returned_date_sk,
    :cr_returned_time_sk,
    :cr_item_sk,
    :cr_refunded_customer_sk,
    :cr_refunded_cdemo_sk,
    :cr_refunded_hdemo_sk,
    :cr_refunded_addr_sk,
    :cr_returning_customer_sk,
    :cr_returning_cdemo_sk,
    :cr_returning_hdemo_sk,
    :cr_returning_addr_sk,
    :cr_call_center_sk,
    :cr_catalog_page_sk,
    :cr_ship_mode_sk,
    :cr_warehouse_sk,
    :cr_reason_sk,
    :cr_order_number,
    :cr_return_quantity,
    :cr_return_amount,
    :cr_return_tax,
    :cr_return_amt_inc_tax,
    :cr_fee,
    :cr_return_ship_cost,
    :cr_refunded_cash,
    :cr_reversed_charge,
    :cr_store_credit,
    :cr_net_loss
)"

