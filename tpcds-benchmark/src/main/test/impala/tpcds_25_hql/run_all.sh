source impala_env.sh
cmd="impala-shell --impalad=$IMPALA_HOST:21000 --database=$TPCDS_DBNAME"
echo "Using: $cmd"
$cmd -f impala-sniff.sql

function impala {
    impala-shell --impalad=$IMPALA_HOST:21000 --database=$TPCDS_DBNAME -f q$1.tpl -o o$1.out >> l$1.log 2>> l$1.log && echo "q$1 completed" || echo "q$1 failed" 
    sleep 240 # give time for daemons to reset
}

impala 03
impala 04
impala 10
impala 16
impala 24

impala 29
impala 32
impala 34

impala 42
impala 45

impala 50

impala 62
impala 66
impala 68

impala 82
impala 88
impala 92

exit 0
