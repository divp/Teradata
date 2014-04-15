source impala_env.sh
cmd="impala-shell --impalad=$IMPALA_HOST:21000 --database=$TPCDS_DBNAME"
echo "Using: $cmd"
$cmd -f impala-sniff.sql

$cmd -f q03.tpl || echo "q03 failed"
$cmd -f q04.tpl || echo "q04 failed"
$cmd -f q10.tpl || echo "q10 failed"
$cmd -f q16.tpl || echo "q16 failed"
$cmd -f q24.tpl || echo "q24 failed"
# unsupported $cmd -f q27.tpl
$cmd -f q29.tpl || echo "q29 failed"
$cmd -f q32.tpl || echo "q32 failed"
$cmd -f q34.tpl || echo "q34 failed"
# unsupported $cmd -f q39.tpl
$cmd -f q42.tpl || echo "q42 failed"
$cmd -f q45.tpl || echo "q45 failed"
# unsupported $cmd -f q49.tpl
$cmd -f q50.tpl || echo "q50 failed"
# unsupported $cmd -f q51.tpl
$cmd -f q62.tpl || echo "q62 failed"
$cmd -f q66.tpl || echo "q66 failed"
$cmd -f q68.tpl || echo "q68 failed"
# fails to compute plan >> $cmd -f q78.tpl || echo "q78 failed"
# unsupported $cmd -f q80.tpl
$cmd -f q82.tpl || echo "q82 failed"
$cmd -f q88.tpl || echo "q88 failed"
$cmd -f q92.tpl || echo "q92 failed"
# fails to compute plan >> $cmd -f q95.tpl || echo "q95 failed"
# fails to compute plan >> $cmd -f q97.tpl || echo "q97 failed"

exit 0
