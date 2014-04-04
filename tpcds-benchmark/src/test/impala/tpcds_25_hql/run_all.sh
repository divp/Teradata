cmd="impala-shell --impalad=10.25.12.43:21000 --database=raw_tpcds1000g"
$cmd -f impala-sniff.sql
# $cmd -f q95.tpl; 
# $cmd -f q80.tpl; 
# $cmd -f q51.tpl; 
# $cmd -f q10.tpl; 
# $cmd -f q68.tpl; 
# $cmd -f q78.tpl; 
# $cmd -f q88.tpl; 

exit 0
