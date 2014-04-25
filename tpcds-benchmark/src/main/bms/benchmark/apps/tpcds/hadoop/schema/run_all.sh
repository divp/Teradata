hive -v -f create_staging_tables.sql
hive -v -f create_etl_views.sql
hive -v -f test.hql
