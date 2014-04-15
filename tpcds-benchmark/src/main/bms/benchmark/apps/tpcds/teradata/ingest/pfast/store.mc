SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.store
TD_ERROR_TABLE_1=tpcds1000g.store_E1
TD_ERROR_TABLE_2=tpcds1000g.store_E2
TD_LOG_TABLE=tpcds1000g.store_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list store.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
s_store_sk (VARCHAR(100)),
s_store_id (VARCHAR(160)),
s_rec_start_date (VARCHAR(100)),
s_rec_end_date (VARCHAR(100)),
s_closed_date_sk (VARCHAR(100)),
s_store_name (VARCHAR(500)),
s_number_employees (VARCHAR(100)),
s_floor_space (VARCHAR(100)),
s_hours (VARCHAR(200)),
s_manager (VARCHAR(400)),
s_market_id (VARCHAR(100)),
s_geography_class (VARCHAR(1000)),
s_market_desc (VARCHAR(1000)),
s_market_manager (VARCHAR(400)),
s_division_id (VARCHAR(100)),
s_division_name (VARCHAR(500)),
s_company_id (VARCHAR(100)),
s_company_name (VARCHAR(500)),
s_street_number (VARCHAR(100)),
s_street_name (VARCHAR(600)),
s_street_type (VARCHAR(150)),
s_suite_number (VARCHAR(100)),
s_city (VARCHAR(600)),
s_county (VARCHAR(300)),
s_state (VARCHAR(20)),
s_zip (VARCHAR(100)),
s_country (VARCHAR(200)),
s_gmt_offset (VARCHAR(50)),
s_tax_precentage (VARCHAR(50))
DEFINE=END
DML="INSERT INTO tpcds1000g.store(
    s_store_sk,
    s_store_id,
    s_rec_start_date,
    s_rec_end_date,
    s_closed_date_sk,
    s_store_name,
    s_number_employees,
    s_floor_space,
    s_hours,
    s_manager,
    s_market_id,
    s_geography_class,
    s_market_desc,
    s_market_manager,
    s_division_id,
    s_division_name,
    s_company_id,
    s_company_name,
    s_street_number,
    s_street_name,
    s_street_type,
    s_suite_number,
    s_city,
    s_county,
    s_state,
    s_zip,
    s_country,
    s_gmt_offset,
    s_tax_precentage
    )
    VALUES
    (
    :s_store_sk,
    :s_store_id,
    :s_rec_start_date (format 'yyyy-mm-dd') ,
    :s_rec_end_date (format 'yyyy-mm-dd') ,
    :s_closed_date_sk,
    :s_store_name,
    :s_number_employees,
    :s_floor_space,
    :s_hours,
    :s_manager,
    :s_market_id,
    :s_geography_class,
    :s_market_desc,
    :s_market_manager,
    :s_division_id,
    :s_division_name,
    :s_company_id,
    :s_company_name,
    :s_street_number,
    :s_street_name,
    :s_street_type,
    :s_suite_number,
    :s_city,
    :s_county,
    :s_state,
    :s_zip,
    :s_country,
    :s_gmt_offset,
    :s_tax_precentage
)"

