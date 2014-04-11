
source impala_env.sh

time impala-shell -i $IMPALA_HOST  --database=$TPCDS_DBNAME -f impala-compute-stats.sql


