SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.call_center
TD_ERROR_TABLE_1=tpcds1000g.call_center_E1
TD_ERROR_TABLE_2=tpcds1000g.call_center_E2
TD_LOG_TABLE=tpcds1000g.call_center_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list call_center.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
cc_call_center_sk (VARCHAR(100)),
cc_call_center_id (VARCHAR(160)),
cc_rec_start_date (VARCHAR(100)),
cc_rec_end_date (VARCHAR(100)),
cc_closed_date_sk (VARCHAR(100)),
cc_open_date_sk (VARCHAR(100)),
cc_name (VARCHAR(500)),
cc_class (VARCHAR(500)),
cc_employees (VARCHAR(100)),
cc_sq_ft (VARCHAR(100)),
cc_hours (VARCHAR(200)),
cc_manager (VARCHAR(400)),
cc_mkt_id (VARCHAR(100)),
cc_mkt_class (VARCHAR(500)),
cc_mkt_desc (VARCHAR(1000)),
cc_market_manager (VARCHAR(400)),
cc_division (VARCHAR(100)),
cc_division_name (VARCHAR(500)),
cc_company (VARCHAR(100)),
cc_company_name (VARCHAR(500)),
cc_street_number (VARCHAR(100)),
cc_street_name (VARCHAR(600)),
cc_street_type (VARCHAR(150)),
cc_suite_number (VARCHAR(100)),
cc_city (VARCHAR(600)),
cc_county (VARCHAR(300)),
cc_state (VARCHAR(20)),
cc_zip (VARCHAR(100)),
cc_country (VARCHAR(200)),
cc_gmt_offset (VARCHAR(50)),
cc_tax_percentage (VARCHAR(50))
DEFINE=END
DML="INSERT INTO tpcds1000g.call_center(
    cc_call_center_sk,
    cc_call_center_id,
    cc_rec_start_date,
    cc_rec_end_date,
    cc_closed_date_sk,
    cc_open_date_sk,
    cc_name,
    cc_class,
    cc_employees,
    cc_sq_ft,
    cc_hours,
    cc_manager,
    cc_mkt_id,
    cc_mkt_class,
    cc_mkt_desc,
    cc_market_manager,
    cc_division,
    cc_division_name,
    cc_company,
    cc_company_name,
    cc_street_number,
    cc_street_name,
    cc_street_type,
    cc_suite_number,
    cc_city,
    cc_county,
    cc_state,
    cc_zip,
    cc_country,
    cc_gmt_offset,
    cc_tax_percentage
    )
    VALUES
    (
    :cc_call_center_sk,
    :cc_call_center_id,
    :cc_rec_start_date (format 'yyyy-mm-dd') ,
    :cc_rec_end_date (format 'yyyy-mm-dd') ,
    :cc_closed_date_sk,
    :cc_open_date_sk,
    :cc_name,
    :cc_class,
    :cc_employees,
    :cc_sq_ft,
    :cc_hours,
    :cc_manager,
    :cc_mkt_id,
    :cc_mkt_class,
    :cc_mkt_desc,
    :cc_market_manager,
    :cc_division,
    :cc_division_name,
    :cc_company,
    :cc_company_name,
    :cc_street_number,
    :cc_street_name,
    :cc_street_type,
    :cc_suite_number,
    :cc_city,
    :cc_county,
    :cc_state,
    :cc_zip,
    :cc_country,
    :cc_gmt_offset,
    :cc_tax_percentage
)"
