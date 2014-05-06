hive -v -f create_staging_tables.sql || exit $?
hive -v -f create_ssv_view.sql || exit $?
hive -v -f test.hql
