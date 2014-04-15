SVRIP=localhost
SVRPORT=34569
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.promotion
TD_ERROR_TABLE_1=tpcds1000g.promotion_E1
TD_ERROR_TABLE_2=tpcds1000g.promotion_E2
TD_LOG_TABLE=tpcds1000g.promotion_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list promotion.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
p_promo_sk (VARCHAR(100)),
p_promo_id (VARCHAR(160)),
p_start_date_sk (VARCHAR(100)),
p_end_date_sk (VARCHAR(100)),
p_item_sk (VARCHAR(100)),
p_cost (VARCHAR(150)),
p_response_target (VARCHAR(100)),
p_promo_name (VARCHAR(500)),
p_channel_dmail (VARCHAR(10)),
p_channel_email (VARCHAR(10)),
p_channel_catalog (VARCHAR(10)),
p_channel_tv (VARCHAR(10)),
p_channel_radio (VARCHAR(10)),
p_channel_press (VARCHAR(10)),
p_channel_event (VARCHAR(10)),
p_channel_demo (VARCHAR(10)),
p_channel_details (VARCHAR(1000)),
p_purpose (VARCHAR(150)),
p_discount_active (VARCHAR(10))
DEFINE=END
DML="INSERT INTO tpcds1000g.promotion(
    p_promo_sk,
    p_promo_id,
    p_start_date_sk,
    p_end_date_sk,
    p_item_sk,
    p_cost,
    p_response_target,
    p_promo_name,
    p_channel_dmail,
    p_channel_email,
    p_channel_catalog,
    p_channel_tv,
    p_channel_radio,
    p_channel_press,
    p_channel_event,
    p_channel_demo,
    p_channel_details,
    p_purpose,
    p_discount_active
    )
    VALUES
    (
    :p_promo_sk,
    :p_promo_id,
    :p_start_date_sk,
    :p_end_date_sk,
    :p_item_sk,
    :p_cost,
    :p_response_target,
    :p_promo_name,
    :p_channel_dmail,
    :p_channel_email,
    :p_channel_catalog,
    :p_channel_tv,
    :p_channel_radio,
    :p_channel_press,
    :p_channel_event,
    :p_channel_demo,
    :p_channel_details,
    :p_purpose,
    :p_discount_active
)"

