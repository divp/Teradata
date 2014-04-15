SVRIP=localhost
SVRPORT=34589
TD_TDP_ID=1700v3
TD_USER_NAME=tpcds1000g
TD_USER_PASSWORD=tpcds1000g
UTILITY=FASTLOAD
TD_TARGET_TABLE=tpcds1000g.customer_demographics
TD_ERROR_TABLE_1=tpcds1000g.customer_demographics_E1
TD_ERROR_TABLE_2=tpcds1000g.customer_demographics_E2
TD_LOG_TABLE=tpcds1000g.customer_demographics_LOG
MAX_SESSIONS=32
MIN_SESSIONS=32
INDICATORS=Y
INITSTR="-file_list customer_demographics.lst -DELIMITER | -QUOTED_STRINGS x22  -pread n -trim y -INDICDATA y  -TIMEOUT 120"
AXSMOD=libamrsock.so
DEFINE=
cd_demo_sk (VARCHAR(100)),
cd_gender (VARCHAR(10)),
cd_marital_status (VARCHAR(10)),
cd_education_status (VARCHAR(200)),
cd_purchase_estimate (VARCHAR(100)),
cd_credit_rating (VARCHAR(100)),
cd_dep_count (VARCHAR(100)),
cd_dep_employed_count (VARCHAR(100)),
cd_dep_college_count (VARCHAR(100))
DEFINE=END
DML="INSERT INTO tpcds1000g.customer_demographics(
    cd_demo_sk,
    cd_gender,
    cd_marital_status,
    cd_education_status,
    cd_purchase_estimate,
    cd_credit_rating,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
    )
    VALUES
    (
    :cd_demo_sk,
    :cd_gender,
    :cd_marital_status,
    :cd_education_status,
    :cd_purchase_estimate,
    :cd_credit_rating,
    :cd_dep_count,
    :cd_dep_employed_count,
    :cd_dep_college_count
)"

