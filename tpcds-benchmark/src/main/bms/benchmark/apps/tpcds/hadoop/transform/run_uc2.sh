
. ../etl_env.sh
hive -v --database=${TARGET_DB} -f update_store.hql
hive -v --database=${TARGET_DB} -f store_view_query.hql
