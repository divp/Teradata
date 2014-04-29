OUTPUT_PATH=$1

cd $OUTPUT_PATH

grep -i "time taken" *.err | grep -v "local task" | awk '{ sum[$1]+=$3 }{rowcnt[$1]+=$6 } END {for (i in sum) { print i","sum[i]","rowcnt[i]}}' | sed "s/.err:Time//g"

