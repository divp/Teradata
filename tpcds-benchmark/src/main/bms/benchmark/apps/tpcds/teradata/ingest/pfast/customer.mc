SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.customer
TD_ERROR_TABLE_1=tpcds1000g.customer_E1
TD_ERROR_TABLE_2=tpcds1000g.customer_E2
TD_LOG_TABLE=tpcds1000g.customer_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list customer_center.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
c_customer_sk (VARCHAR(100)),
c_customer_id (VARCHAR(160)),
c_current_cdemo_sk (VARCHAR(100)),
c_current_hdemo_sk (VARCHAR(100)),
c_current_addr_sk (VARCHAR(100)),
c_first_shipto_date_sk (VARCHAR(100)),
c_first_sales_date_sk (VARCHAR(100)),
c_salutation (VARCHAR(100)),
c_first_name (VARCHAR(200)),
c_last_name (VARCHAR(300)),
c_preferred_cust_flag (VARCHAR(10)),
c_birth_day (VARCHAR(100)),
c_birth_month (VARCHAR(100)),
c_birth_year (VARCHAR(100)),
c_birth_country (VARCHAR(200)),
c_login (VARCHAR(130)),
c_email_address (VARCHAR(500)),
c_last_review_date (VARCHAR(100))
DEFINE=END
DML="INSERT INTO tpcds1000g.customer(
    c_customer_sk,
    c_customer_id,
    c_current_cdemo_sk,
    c_current_hdemo_sk,
    c_current_addr_sk,
    c_first_shipto_date_sk,
    c_first_sales_date_sk,
    c_salutation,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_day,
    c_birth_month,
    c_birth_year,
    c_birth_country,
    c_login,
    c_email_address,
    c_last_review_date
    )
    VALUES
    (
    :c_customer_sk,
    :c_customer_id,
    :c_current_cdemo_sk,
    :c_current_hdemo_sk,
    :c_current_addr_sk,
    :c_first_shipto_date_sk,
    :c_first_sales_date_sk,
    :c_salutation,
    :c_first_name,
    :c_last_name,
    :c_preferred_cust_flag,
    :c_birth_day,
    :c_birth_month,
    :c_birth_year,
    :c_birth_country,
    :c_login,
    :c_email_address,
    :c_last_review_date
)"

