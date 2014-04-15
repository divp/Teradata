SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.reason
TD_ERROR_TABLE_1=tpcds1000g.reason_E1
TD_ERROR_TABLE_2=tpcds1000g.reason_E2
TD_LOG_TABLE=tpcds1000g.reason_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list reason.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
r_reason_sk (VARCHAR(100)),
r_reason_id (VARCHAR(160)),
r_reason_desc (VARCHAR(1000))
DEFINE=END
DML="INSERT INTO tpcds1000g.reason(
    r_reason_sk,
    r_reason_id,
    r_reason_desc
    )
    VALUES
    (
    :r_reason_sk,
    :r_reason_id,
    :r_reason_desc
)"

