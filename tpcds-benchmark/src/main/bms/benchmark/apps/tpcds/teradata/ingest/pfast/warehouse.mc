SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.warehouse
TD_ERROR_TABLE_1=tpcds1000g.warehouse_E1
TD_ERROR_TABLE_2=tpcds1000g.warehouse_E2
TD_LOG_TABLE=tpcds1000g.warehouse_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list warehouse.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
w_warehouse_sk (VARCHAR(100)),
w_warehouse_id (VARCHAR(160)),
w_warehouse_name (VARCHAR(200)),
w_warehouse_sq_ft (VARCHAR(100)),
w_street_number (VARCHAR(100)),
w_street_name (VARCHAR(600)),
w_street_type (VARCHAR(150)),
w_suite_number (VARCHAR(100)),
w_city (VARCHAR(600)),
w_county (VARCHAR(300)),
w_state (VARCHAR(20)),
w_zip (VARCHAR(100)),
w_country (VARCHAR(200)),
w_gmt_offset (VARCHAR(50))
DEFINE=END
DML="INSERT INTO tpcds1000g.warehouse(
    w_warehouse_sk,
    w_warehouse_id,
    w_warehouse_name,
    w_warehouse_sq_ft,
    w_street_number,
    w_street_name,
    w_street_type,
    w_suite_number,
    w_city,
    w_county,
    w_state,
    w_zip,
    w_country,
    w_gmt_offset
    )
    VALUES
    (
    :w_warehouse_sk,
    :w_warehouse_id,
    :w_warehouse_name,
    :w_warehouse_sq_ft,
    :w_street_number,
    :w_street_name,
    :w_street_type,
    :w_suite_number,
    :w_city,
    :w_county,
    :w_state,
    :w_zip,
    :w_country,
    :w_gmt_offset
)"

