#!/bin/bash
SCRIPT_PATH=`pwd`
#QUERY_PATH=/data/tpcds/GoodScripts/3000g/user01
#QUERY_PATH=/data/tpcds/GoodScripts/tactical
#QUERY_PATH=/data/tpcds/GoodScripts/10000g/user01/rerun
QUERY_PATH=/data/tpcds/cloudera_tpcds/queries
DATABASE=orc_tpcds1000g
TS=`date +%F_%H%M`
OUTPUT_PATH=$SCRIPT_PATH/output_${DATABASE}_$TS
OPT_CONFIG_PATH=$SCRIPT_PATH/hive_params_opt.sh
OPT2_CONFIG_PATH=$SCRIPT_PATH/hive_params_opt2.sh
OPT3_CONFIG_PATH=$SCRIPT_PATH/hive_params_opt3.sh
HIVE_CONFIG=$SCRIPT_PATH/hive_params.sh
RUN_OPT="true"
COLLECT_STATS="true"
EXPLAIN_ONLY="false"
mkdir $OUTPUT_PATH
chmod 775 $OUTPUT_PATH

echo "Running 31 TPC-DS Queries Against Hive"

if [ "$COLLECT_STATS" == "true" ]
then
	echo "Starting Statistics Collection on Cluster Nodes..."
	$SCRIPT_PATH/start_stats_collection.sh test_$TS
fi

for query in `find $QUERY_PATH/*.hql`
do
	QRY=`basename $query`
	QUERYNAME=`echo "$QRY" | cut -d'.' -f1`
	echo "Running $QUERYNAME..."
	#cat $query | sed "s/\${hiveconf:db}/$DATABASE/g" > $OUTPUT_PATH/$QUERYNAME.hql
	if [ "$RUN_OPT" == "true" ]
	then
		case "$QUERYNAME" in
			"query82")
				HIVE_CONFIG=$OPT3_CONFIG_PATH
			;;
			"query51" | "query04" | "query24" | "query34" | "query45" | "query68")
				HIVE_CONFIG=$OPT2_CONFIG_PATH
			;;
			*)
				HIVE_CONFIG=$OPT_CONFIG_PATH
			;;
		esac
	fi
	cat $HIVE_CONFIG > $OUTPUT_PATH/$QUERYNAME.hql
	chmod 755 $OUTPUT_PATH/$QUERYNAME.hql
	if [ "$EXPLAIN_ONLY" == "true" ]
	then
		echo "explain " >> $OUTPUT_PATH/$QUERYNAME.hql
		cat $query >> $OUTPUT_PATH/$QUERYNAME.hql
	        #sudo -u hdfs hive --database $DATABASE -f $OUTPUT_PATH/$QUERYNAME.hql  2> $OUTPUT_PATH/$QUERYNAME.explain.err > $OUTPUT_PATH/$QUERYNAME.explain.out
	else
		cat $query >> $OUTPUT_PATH/$QUERYNAME.hql
	        sudo -u hdfs hive --database $DATABASE -f $OUTPUT_PATH/$QUERYNAME.hql  2> $OUTPUT_PATH/$QUERYNAME.err > $OUTPUT_PATH/$QUERYNAME.out
	fi
done

if [ "$COLLECT_STATS" == "true" ]
then
	echo "Stopping Statistics Collection"
	$SCRIPT_PATH/stop_stats_collection.sh
fi
