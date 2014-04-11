source impala_env.sh
cmd="time impala-shell --impalad=$IMPALA_HOST:21000 --database=$TPCDS_DBNAME"
$cmd -f impala-sniff.sql

$cmd -f q03.tpl
$cmd -f q04.tpl
$cmd -f q10.tpl
# temp $cmd -f q16.tpl
# temp $cmd -f q24.tpl
# unsupported $cmd -f q27.tpl
$cmd -f q29.tpl
# temp $cmd -f q32.tpl
$cmd -f q34.tpl
# unsupported $cmd -f q39.tpl
$cmd -f q42.tpl
$cmd -f q45.tpl
# unsupported $cmd -f q49.tpl
$cmd -f q50.tpl
# unsupported $cmd -f q51.tpl
$cmd -f q62.tpl
# temp $cmd -f q66.tpl
$cmd -f q68.tpl
$cmd -f q78.tpl
# unsupported $cmd -f q80.tpl
# temp $cmd -f q82.tpl
$cmd -f q88.tpl
# temp $cmd -f q92.tpl
$cmd -f q95.tpl
$cmd -f q97.tpl

exit 0
