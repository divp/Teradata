#  start impala shell for interactive use
source impala_env.sh
impala-shell --impalad=$IMPALA_HOST:21000 --database=$TPCDS_DBNAME
