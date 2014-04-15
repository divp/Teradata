SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.customer_address
TD_ERROR_TABLE_1=tpcds1000g.customer_address_E1
TD_ERROR_TABLE_2=tpcds1000g.customer_address_E2
TD_LOG_TABLE=tpcds1000g.customer_address_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list customer_address.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
ca_address_sk (VARCHAR(100)),
ca_address_id (VARCHAR(160)),
ca_street_number (VARCHAR(100)),
ca_street_name (VARCHAR(600)),
ca_street_type (VARCHAR(150)),
ca_suite_number (VARCHAR(100)),
ca_city (VARCHAR(600)),
ca_county (VARCHAR(300)),
ca_state (VARCHAR(20)),
ca_zip (VARCHAR(100)),
ca_country (VARCHAR(200)),
ca_gmt_offset (VARCHAR(50)),
ca_location_type (VARCHAR(200))
DEFINE=END
DML="INSERT INTO tpcds1000g.customer_address(
    ca_address_sk,
    ca_address_id,
    ca_street_number,
    ca_street_name,
    ca_street_type,
    ca_suite_number,
    ca_city,
    ca_county,
    ca_state,
    ca_zip,
    ca_country,
    ca_gmt_offset,
    ca_location_type
    )
    VALUES
    (
    :ca_address_sk,
    :ca_address_id,
    :ca_street_number,
    :ca_street_name,
    :ca_street_type,
    :ca_suite_number,
    :ca_city,
    :ca_county,
    :ca_state,
    :ca_zip,
    :ca_country,
    :ca_gmt_offset,
    :ca_location_type
)"

