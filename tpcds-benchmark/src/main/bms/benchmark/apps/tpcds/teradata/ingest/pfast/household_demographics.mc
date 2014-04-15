SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.household_demographics
TD_ERROR_TABLE_1=tpcds1000g.household_demographics_E1
TD_ERROR_TABLE_2=tpcds1000g.household_demographics_E2
TD_LOG_TABLE=tpcds1000g.household_demographics_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list household_demographics.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
hd_demo_sk (VARCHAR(100)),
hd_income_band_sk (VARCHAR(100)),
hd_buy_potential (VARCHAR(150)),
hd_dep_count (VARCHAR(100)),
hd_vehicle_count (VARCHAR(100))
DEFINE=END
DML="INSERT INTO tpcds1000g.household_demographics(
    hd_demo_sk,
    hd_income_band_sk,
    hd_buy_potential,
    hd_dep_count,
    hd_vehicle_count
    )
    VALUES
    (
    :hd_demo_sk,
    :hd_income_band_sk,
    :hd_buy_potential,
    :hd_dep_count,
    :hd_vehicle_count
)"

