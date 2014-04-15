SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.time_dim
TD_ERROR_TABLE_1=tpcds1000g.time_dim_E1
TD_ERROR_TABLE_2=tpcds1000g.time_dim_E2
TD_LOG_TABLE=tpcds1000g.time_dim_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list time_dim.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
t_time_sk (VARCHAR(100)),
t_time_id (VARCHAR(160)),
t_time (VARCHAR(100)),
t_hour (VARCHAR(100)),
t_minute (VARCHAR(100)),
t_second (VARCHAR(100)),
t_am_pm (VARCHAR(20)),
t_shift (VARCHAR(200)),
t_sub_shift (VARCHAR(200)),
t_meal_time (VARCHAR(200))
DEFINE=END
DML="INSERT INTO tpcds1000g.time_dim(
    t_time_sk,
    t_time_id,
    t_time,
    t_hour,
    t_minute,
    t_second,
    t_am_pm,
    t_shift,
    t_sub_shift,
    t_meal_time
    )
    VALUES
    (
    :t_time_sk,
    :t_time_id,
    :t_time,
    :t_hour,
    :t_minute,
    :t_second,
    :t_am_pm,
    :t_shift,
    :t_sub_shift,
    :t_meal_time
)"

