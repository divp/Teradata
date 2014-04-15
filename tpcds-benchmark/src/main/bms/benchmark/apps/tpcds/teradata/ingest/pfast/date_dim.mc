SVRIP=localhost
SVRPORT=34568
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.date_dim
TD_ERROR_TABLE_1=tpcds1000g.date_dim_E1
TD_ERROR_TABLE_2=tpcds1000g.date_dim_E2
TD_LOG_TABLE=tpcds1000g.date_dim_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list date_dim.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
d_date_sk (VARCHAR(100)),
d_date_id (VARCHAR(160)),
d_date (VARCHAR(100)),
d_month_seq (VARCHAR(100)),
d_week_seq (VARCHAR(100)),
d_quarter_seq (VARCHAR(100)),
d_year (VARCHAR(100)),
d_dow (VARCHAR(100)),
d_moy (VARCHAR(100)),
d_dom (VARCHAR(100)),
d_qoy (VARCHAR(100)),
d_fy_year (VARCHAR(100)),
d_fy_quarter_seq (VARCHAR(100)),
d_fy_week_seq (VARCHAR(100)),
d_day_name (VARCHAR(90)),
d_quarter_name (VARCHAR(60)),
d_holiday (VARCHAR(10)),
d_weekend (VARCHAR(10)),
d_following_holiday (VARCHAR(10)),
d_first_dom (VARCHAR(100)),
d_last_dom (VARCHAR(100)),
d_same_day_ly (VARCHAR(100)),
d_same_day_lq (VARCHAR(100)),
d_current_day (VARCHAR(10)),
d_current_week (VARCHAR(10)),
d_current_month (VARCHAR(10)),
d_current_quarter (VARCHAR(10)),
d_current_year (VARCHAR(10))
DEFINE=END
DML="INSERT INTO tpcds1000g.date_dim(
    d_date_sk,
    d_date_id,
    d_date,
    d_month_seq,
    d_week_seq,
    d_quarter_seq,
    d_year,
    d_dow,
    d_moy,
    d_dom,
    d_qoy,
    d_fy_year,
    d_fy_quarter_seq,
    d_fy_week_seq,
    d_day_name,
    d_quarter_name,
    d_holiday,
    d_weekend,
    d_following_holiday,
    d_first_dom,
    d_last_dom,
    d_same_day_ly,
    d_same_day_lq,
    d_current_day,
    d_current_week,
    d_current_month,
    d_current_quarter,
    d_current_year
    )
    VALUES
    (
    :d_date_sk,
    :d_date_id,
    :d_date (format 'yyyy-mm-dd') ,
    :d_month_seq,
    :d_week_seq,
    :d_quarter_seq,
    :d_year,
    :d_dow,
    :d_moy,
    :d_dom,
    :d_qoy,
    :d_fy_year,
    :d_fy_quarter_seq,
    :d_fy_week_seq,
    :d_day_name,
    :d_quarter_name,
    :d_holiday,
    :d_weekend,
    :d_following_holiday,
    :d_first_dom,
    :d_last_dom,
    :d_same_day_ly,
    :d_same_day_lq,
    :d_current_day,
    :d_current_week,
    :d_current_month,
    :d_current_quarter,
    :d_current_year
)"

