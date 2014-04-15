SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.ship_mode
TD_ERROR_TABLE_1=tpcds1000g.ship_mode_E1
TD_ERROR_TABLE_2=tpcds1000g.ship_mode_E2
TD_LOG_TABLE=tpcds1000g.ship_mode_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list ship_mode.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
sm_ship_mode_sk (VARCHAR(100)),
sm_ship_mode_id (VARCHAR(160)),
sm_type (VARCHAR(300)),
sm_code (VARCHAR(100)),
sm_carrier (VARCHAR(200)),
sm_contract (VARCHAR(200))
DEFINE=END
DML="INSERT INTO tpcds1000g.ship_mode(
    sm_ship_mode_sk,
    sm_ship_mode_id,
    sm_type,
    sm_code,
    sm_carrier,
    sm_contract
    )
    VALUES
    (
    :sm_ship_mode_sk,
    :sm_ship_mode_id,
    :sm_type,
    :sm_code,
    :sm_carrier,
    :sm_contract
)"

