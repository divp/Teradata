hive -v -f create_staging_tables.sql || exit $?
hive -v -f create_etl_views.sql || exit $?
hive -v -f test.hql
