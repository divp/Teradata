SVRIP=localhost
SVRPORT=34579
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.store_returns_raw
TD_ERROR_TABLE_1=tpcds1000g.store_returns_raw_E1
TD_ERROR_TABLE_2=tpcds1000g.store_returns_raw_E2
TD_LOG_TABLE=tpcds1000g.store_returns_raw_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list store_returns.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
sr_returned_date_sk (VARCHAR(100)),
sr_return_time_sk (VARCHAR(100)),
sr_item_sk (VARCHAR(100)),
sr_customer_sk (VARCHAR(100)),
sr_cdemo_sk (VARCHAR(100)),
sr_hdemo_sk (VARCHAR(100)),
sr_addr_sk (VARCHAR(100)),
sr_store_sk (VARCHAR(100)),
sr_reason_sk (VARCHAR(100)),
sr_ticket_number (VARCHAR(100)),
sr_return_quantity (VARCHAR(100)),
sr_return_amt (VARCHAR(70)),
sr_return_tax (VARCHAR(70)),
sr_return_amt_inc_tax (VARCHAR(70)),
sr_fee (VARCHAR(70)),
sr_return_ship_cost (VARCHAR(70)),
sr_refunded_cash (VARCHAR(70)),
sr_reversed_charge (VARCHAR(70)),
sr_store_credit (VARCHAR(70)),
sr_net_loss (VARCHAR(70))
DEFINE=END
DML="INSERT INTO tpcds1000g.store_returns_raw(
    sr_returned_date_sk,
    sr_return_time_sk,
    sr_item_sk,
    sr_customer_sk,
    sr_cdemo_sk,
    sr_hdemo_sk,
    sr_addr_sk,
    sr_store_sk,
    sr_reason_sk,
    sr_ticket_number,
    sr_return_quantity,
    sr_return_amt,
    sr_return_tax,
    sr_return_amt_inc_tax,
    sr_fee,
    sr_return_ship_cost,
    sr_refunded_cash,
    sr_reversed_charge,
    sr_store_credit,
    sr_net_loss
    )
    VALUES
    (
    :sr_returned_date_sk,
    :sr_return_time_sk,
    :sr_item_sk,
    :sr_customer_sk,
    :sr_cdemo_sk,
    :sr_hdemo_sk,
    :sr_addr_sk,
    :sr_store_sk,
    :sr_reason_sk,
    :sr_ticket_number,
    :sr_return_quantity,
    :sr_return_amt,
    :sr_return_tax,
    :sr_return_amt_inc_tax,
    :sr_fee,
    :sr_return_ship_cost,
    :sr_refunded_cash,
    :sr_reversed_charge,
    :sr_store_credit,
    :sr_net_loss
)"

