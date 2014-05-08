
. ../etl_env.sh
hive -v --database=${TARGET_DB} -f store_sales_fact.hql
