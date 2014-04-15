SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.web_site
TD_ERROR_TABLE_1=tpcds1000g.web_site_E1
TD_ERROR_TABLE_2=tpcds1000g.web_site_E2
TD_LOG_TABLE=tpcds1000g.web_site_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list web_site.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
web_site_sk (VARCHAR(100)),
web_site_id (VARCHAR(160)),
web_rec_start_date (VARCHAR(100)),
web_rec_end_date (VARCHAR(100)),
web_name (VARCHAR(500)),
web_open_date_sk (VARCHAR(100)),
web_close_date_sk (VARCHAR(100)),
web_class (VARCHAR(500)),
web_manager (VARCHAR(400)),
web_mkt_id (VARCHAR(100)),
web_mkt_class (VARCHAR(500)),
web_mkt_desc (VARCHAR(1000)),
web_market_manager (VARCHAR(400)),
web_company_id (VARCHAR(100)),
web_company_name (VARCHAR(500)),
web_street_number (VARCHAR(100)),
web_street_name (VARCHAR(600)),
web_street_type (VARCHAR(150)),
web_suite_number (VARCHAR(100)),
web_city (VARCHAR(600)),
web_county (VARCHAR(300)),
web_state (VARCHAR(20)),
web_zip (VARCHAR(100)),
web_country (VARCHAR(200)),
web_gmt_offset (VARCHAR(50)),
web_tax_percentage (VARCHAR(50))
DEFINE=END
DML="INSERT INTO tpcds1000g.web_site(
    web_site_sk,
    web_site_id,
    web_rec_start_date,
    web_rec_end_date,
    web_name,
    web_open_date_sk,
    web_close_date_sk,
    web_class,
    web_manager,
    web_mkt_id,
    web_mkt_class,
    web_mkt_desc,
    web_market_manager,
    web_company_id,
    web_company_name,
    web_street_number,
    web_street_name,
    web_street_type,
    web_suite_number,
    web_city,
    web_county,
    web_state,
    web_zip,
    web_country,
    web_gmt_offset,
    web_tax_percentage
    )
    VALUES
    (
    :web_site_sk,
    :web_site_id,
    :web_rec_start_date (format 'yyyy-mm-dd') ,
    :web_rec_end_date (format 'yyyy-mm-dd') ,
    :web_name,
    :web_open_date_sk,
    :web_close_date_sk,
    :web_class,
    :web_manager,
    :web_mkt_id,
    :web_mkt_class,
    :web_mkt_desc,
    :web_market_manager,
    :web_company_id,
    :web_company_name,
    :web_street_number,
    :web_street_name,
    :web_street_type,
    :web_suite_number,
    :web_city,
    :web_county,
    :web_state,
    :web_zip,
    :web_country,
    :web_gmt_offset,
    :web_tax_percentage
)"

