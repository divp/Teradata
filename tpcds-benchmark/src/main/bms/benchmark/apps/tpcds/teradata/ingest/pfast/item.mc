SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.item
TD_ERROR_TABLE_1=tpcds1000g.item_E1
TD_ERROR_TABLE_2=tpcds1000g.item_E2
TD_LOG_TABLE=tpcds1000g.item_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
AXSMOD=libamrsock.so
INITSTR="-file_list item.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
DEFINE=
i_item_sk (VARCHAR(100)),
i_item_id (VARCHAR(160)),
i_rec_start_date (VARCHAR(100)),
i_rec_end_date (VARCHAR(100)),
i_item_desc (VARCHAR(2000)),
i_current_price (VARCHAR(70)),
i_wholesale_cost (VARCHAR(70)),
i_brand_id (VARCHAR(100)),
i_brand (VARCHAR(500)),
i_class_id (VARCHAR(100)),
i_class (VARCHAR(500)),
i_category_id (VARCHAR(100)),
i_category (VARCHAR(500)),
i_manufact_id (VARCHAR(100)),
i_manufact (VARCHAR(500)),
i_size (VARCHAR(200)),
i_formulation (VARCHAR(200)),
i_color (VARCHAR(200)),
i_units (VARCHAR(100)),
i_container (VARCHAR(100)),
i_manager_id (VARCHAR(100)),
i_product_name (VARCHAR(500))
DEFINE=END
DML="INSERT INTO tpcds1000g.item(
    i_item_sk,
    i_item_id,
    i_rec_start_date,
    i_rec_end_date,
    i_item_desc,
    i_current_price,
    i_wholesale_cost,
    i_brand_id,
    i_brand,
    i_class_id,
    i_class,
    i_category_id,
    i_category,
    i_manufact_id,
    i_manufact,
    i_size,
    i_formulation,
    i_color,
    i_units,
    i_container,
    i_manager_id,
    i_product_name
    )
    VALUES
    (
    :i_item_sk,
    :i_item_id,
    :i_rec_start_date (format 'yyyy-mm-dd') ,
    :i_rec_end_date (format 'yyyy-mm-dd') ,
    :i_item_desc,
    :i_current_price,
    :i_wholesale_cost,
    :i_brand_id,
    :i_brand,
    :i_class_id,
    :i_class,
    :i_category_id,
    :i_category,
    :i_manufact_id,
    :i_manufact,
    :i_size,
    :i_formulation,
    :i_color,
    :i_units,
    :i_container,
    :i_manager_id,
    :i_product_name
)"

