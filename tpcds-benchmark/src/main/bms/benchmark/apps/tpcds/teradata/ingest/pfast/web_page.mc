SVRIP=localhost
SVRPORT=34571
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.web_page
TD_ERROR_TABLE_1=tpcds1000g.web_page_E1
TD_ERROR_TABLE_2=tpcds1000g.web_page_E2
TD_LOG_TABLE=tpcds1000g.web_page_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list web_page.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
wp_web_page_sk (VARCHAR(100)),
wp_web_page_id (VARCHAR(160)),
wp_rec_start_date (VARCHAR(100)),
wp_rec_end_date (VARCHAR(100)),
wp_creation_date_sk (VARCHAR(100)),
wp_access_date_sk (VARCHAR(100)),
wp_autogen_flag (VARCHAR(10)),
wp_customer_sk (VARCHAR(100)),
wp_url (VARCHAR(1000)),
wp_type (VARCHAR(500)),
wp_char_count (VARCHAR(100)),
wp_link_count (VARCHAR(100)),
wp_image_count (VARCHAR(100)),
wp_max_ad_count (VARCHAR(100))
DEFINE=END
DML="INSERT INTO tpcds1000g.web_page(
    wp_web_page_sk,
    wp_web_page_id,
    wp_rec_start_date,
    wp_rec_end_date,
    wp_creation_date_sk,
    wp_access_date_sk,
    wp_autogen_flag,
    wp_customer_sk,
    wp_url,
    wp_type,
    wp_char_count,
    wp_link_count,
    wp_image_count,
    wp_max_ad_count
    )
    VALUES
    (
    :wp_web_page_sk,
    :wp_web_page_id,
    :wp_rec_start_date (format 'yyyy-mm-dd') ,
    :wp_rec_end_date (format 'yyyy-mm-dd') ,
    :wp_creation_date_sk,
    :wp_access_date_sk,
    :wp_autogen_flag,
    :wp_customer_sk,
    :wp_url,
    :wp_type,
    :wp_char_count,
    :wp_link_count,
    :wp_image_count,
    :wp_max_ad_count
)"

