SVRIP=localhost
SVRPORT=34572
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.web_returns_raw
TD_ERROR_TABLE_1=tpcds1000g.web_returns_raw_E1
TD_ERROR_TABLE_2=tpcds1000g.web_returns_raw_E2
TD_LOG_TABLE=tpcds1000g.web_returns_raw_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list web_returns.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120 -field_count 24"
AXSMOD=libamrsock.so
DEFINE=
wr_returned_date_sk (VARCHAR(20)),
wr_returned_time_sk (VARCHAR(20)),
wr_item_sk (VARCHAR(20)),
wr_refunded_customer_sk (VARCHAR(20)),
wr_refunded_cdemo_sk (VARCHAR(100)),
wr_refunded_hdemo_sk (VARCHAR(100)),
wr_refunded_addr_sk (VARCHAR(100)),
wr_returning_customer_sk (VARCHAR(100)),
wr_returning_cdemo_sk (VARCHAR(100)),
wr_returning_hdemo_sk (VARCHAR(100)),
wr_returning_addr_sk (VARCHAR(100)),
wr_web_page_sk (VARCHAR(30)),
wr_reason_sk (VARCHAR(30)),
wr_order_number (VARCHAR(100)),
wr_return_quantity (VARCHAR(100)),
wr_return_amt (VARCHAR(70)),
wr_return_tax (VARCHAR(70)),
wr_return_amt_inc_tax (VARCHAR(70)),
wr_fee (VARCHAR(70)),
wr_return_ship_cost (VARCHAR(70)),
wr_refunded_cash (VARCHAR(70)),
wr_reversed_charge (VARCHAR(70)),
wr_account_credit (VARCHAR(70)),
wr_net_loss (VARCHAR(70))
DEFINE=END
DML="INSERT INTO tpcds1000g.web_returns_raw(
    wr_returned_date_sk,
    wr_returned_time_sk,
    wr_item_sk,
    wr_refunded_customer_sk,
    wr_refunded_cdemo_sk,
    wr_refunded_hdemo_sk,
    wr_refunded_addr_sk,
    wr_returning_customer_sk,
    wr_returning_cdemo_sk,
    wr_returning_hdemo_sk,
    wr_returning_addr_sk,
    wr_web_page_sk,
    wr_reason_sk,
    wr_order_number,
    wr_return_quantity,
    wr_return_amt,
    wr_return_tax,
    wr_return_amt_inc_tax,
    wr_fee,
    wr_return_ship_cost,
    wr_refunded_cash,
    wr_reversed_charge,
    wr_account_credit,
    wr_net_loss
    )
    VALUES
    (
    :wr_returned_date_sk,
    :wr_returned_time_sk,
    :wr_item_sk,
    :wr_refunded_customer_sk,
    :wr_refunded_cdemo_sk,
    :wr_refunded_hdemo_sk,
    :wr_refunded_addr_sk,
    :wr_returning_customer_sk,
    :wr_returning_cdemo_sk,
    :wr_returning_hdemo_sk,
    :wr_returning_addr_sk,
    :wr_web_page_sk,
    :wr_reason_sk,
    :wr_order_number,
    :wr_return_quantity,
    :wr_return_amt,
    :wr_return_tax,
    :wr_return_amt_inc_tax,
    :wr_fee,
    :wr_return_ship_cost,
    :wr_refunded_cash,
    :wr_reversed_charge,
    :wr_account_credit,
    :wr_net_loss
)"

