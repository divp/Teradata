SVRIP=localhost
SVRPORT=34591
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.inventory
TD_ERROR_TABLE_1=tpcds1000g.inventory_E1
TD_ERROR_TABLE_2=tpcds1000g.inventory_E2
TD_LOG_TABLE=tpcds1000g.inventory_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list inventory.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
inv_date_sk (VARCHAR(100)),
inv_item_sk (VARCHAR(100)),
inv_warehouse_sk (VARCHAR(100)),
inv_quantity_on_hand (VARCHAR(100))
DEFINE=END
DML="INSERT INTO tpcds1000g.inventory(
    inv_date_sk,
    inv_item_sk,
    inv_warehouse_sk,
    inv_quantity_on_hand
    )
    VALUES
    (
    :inv_date_sk,
    :inv_item_sk,
    :inv_warehouse_sk,
    :inv_quantity_on_hand
)"

