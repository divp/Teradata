queries=(
query1
q7
qa1
qa2
qa3
qj1
qj3
qj5
qj6
qj7
qj8
qj9
qj10
qj11
qj12
qj13
qj14
qj15
)

HIVE_DIR=/home/htester/impala/twitter/query

for query in ${queries[@]}
do
	echo "Running $query.impala"
        START=$(date +%s)
	impala-shell -f $HIVE_DIR/$query.impala > $HIVE_DIR/$query.out
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Query $query.impala executed in $DIFF seconds"
done
