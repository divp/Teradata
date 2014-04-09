source impala_env.sh

impala-shell -i $IMPALA_HOST  --database=$TPCDS_DBNAME -f source_table_qa.sql > "$TPCDS_DBNAME"_qa.txt
