source impala_env.sh
cmd="impala-shell --impalad=$IMPALA_HOST:21000 --database=$TPCDS_DBNAME"

$cmd -f r1.sql
$cmd -f r2.sql
$cmd -f r3.sql
$cmd -f r4.sql
$cmd -f r5.sql
$cmd -f r6.sql
