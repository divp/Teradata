SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.catalog_page
TD_ERROR_TABLE_1=tpcds1000g.catalog_page_E1
TD_ERROR_TABLE_2=tpcds1000g.catalog_page_E2
TD_LOG_TABLE=tpcds1000g.catalog_page_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list catalog_page.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
cp_catalog_page_sk (VARCHAR(100)),
cp_catalog_page_id (VARCHAR(160)),
cp_start_date_sk (VARCHAR(100)),
cp_end_date_sk (VARCHAR(100)),
cp_department (VARCHAR(500)),
cp_catalog_number (VARCHAR(100)),
cp_catalog_page_number (VARCHAR(100)),
cp_description (VARCHAR(1000)),
cp_type (VARCHAR(1000))
DEFINE=END
DML="INSERT INTO tpcds1000g.catalog_page(
    cp_catalog_page_sk,
    cp_catalog_page_id,
    cp_start_date_sk,
    cp_end_date_sk,
    cp_department,
    cp_catalog_number,
    cp_catalog_page_number,
    cp_description,
    cp_type
    )
    VALUES
    (
    :cp_catalog_page_sk,
    :cp_catalog_page_id,
    :cp_start_date_sk,
    :cp_end_date_sk,
    :cp_department,
    :cp_catalog_number,
    :cp_catalog_page_number,
    :cp_description,
    :cp_type
)"

