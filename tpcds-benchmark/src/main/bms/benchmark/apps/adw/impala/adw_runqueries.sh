queries=(
esg7b_2tablejoin
esg7b_3tablejoin
esg7b_4tablejoin
esg7b_localagg
esg7b_globalagg
esg7b_lookup
esg7b_having
)

HIVE_DIR=/home/htester/impala/adw/query

for query in ${queries[@]}
do
	echo "Running $query.hql"
        START=$(date +%s)
	impala-shell -f $HIVE_DIR/$query.impala > $HIVE_DIR/$query.out
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Query $query.hql executed in $DIFF seconds"
done
