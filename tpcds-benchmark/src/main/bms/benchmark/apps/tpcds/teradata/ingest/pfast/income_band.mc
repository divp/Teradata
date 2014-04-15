SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.income_band
TD_ERROR_TABLE_1=tpcds1000g.income_band_E1
TD_ERROR_TABLE_2=tpcds1000g.income_band_E2
TD_LOG_TABLE=tpcds1000g.income_band_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list income_band.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
ib_income_band_sk (VARCHAR(100)),
ib_lower_bound (VARCHAR(100)),
ib_upper_bound (VARCHAR(100))
DEFINE=END
DML="INSERT INTO tpcds1000g.income_band(
    ib_income_band_sk,
    ib_lower_bound,
    ib_upper_bound
    )
    VALUES
    (
    :ib_income_band_sk,
    :ib_lower_bound,
    :ib_upper_bound
)"

