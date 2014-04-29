#!/bin/bash
SCRIPT_PATH=`pwd`
SCALE_FACTOR=$1
QUERY_PATH=/data/tpcds/GoodScripts/${SCALE_FACTOR}g_rerun/
#QUERY_PATH=/data/tpcds/GoodScripts/tactical
#QUERY_PATH=/data/tpcds/GoodScripts/10000g/user01/rerun
DATABASE=orc_tpcds${SCALE_FACTOR}g
TS=`date +%F_%H%M`
OUTPUT_PATH=$SCRIPT_PATH/output_multi_${DATABASE}_$TS
OPT_CONFIG_PATH=$SCRIPT_PATH/hive_params_opt.sh
OPT2_CONFIG_PATH=$SCRIPT_PATH/hive_params_opt2.sh
OPT3_CONFIG_PATH=$SCRIPT_PATH/hive_params_opt3.sh
HIVE_CONFIG=$SCRIPT_PATH/hive_params.sh
RUN_OPT="true"
COLLECT_STATS="true"
NUM_USERS=$2
mkdir $OUTPUT_PATH
chmod 775 $OUTPUT_PATH

function run_queries(){
	 FIXED_USER_NUM=$1
	 USER_PATH=$2
	 for query in `find $USER_PATH/*.hql`
                do
                        QRY=`basename $query`
                        QUERYNAME=`echo "$QRY" | cut -d'.' -f1`
                        echo "Running $QUERYNAME for User $FIXED_USER_NUM..."
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
                        cat $HIVE_CONFIG > $OUTPUT_PATH/$QUERYNAME.$FIXED_USER_NUM.hql
                        chmod 755 $OUTPUT_PATH/$QUERYNAME.$FIXED_USER_NUM.hql
                        cat $query >> $OUTPUT_PATH/$QUERYNAME.$FIXED_USER_NUM.hql
                        sudo -u hdfs hive --database $DATABASE -f $OUTPUT_PATH/$QUERYNAME.$FIXED_USER_NUM.hql  2> $OUTPUT_PATH/$QUERYNAME.$FIXED_USER_NUM.err > $OUTPUT_PATH/$QUERYNAME.$FIXED_USER_NUM.out
                done

}

if [[ $# -lt 2 ]]
then
	echo "Usage: run_multi.sh <scalefactor> <num_users>"
else
	echo "Running 31 TPC-DS Queries Against Hive"
	

	if [ "$COLLECT_STATS" == "true" ]
	then
		echo "Starting Statistics Collection on Cluster Nodes..."
		$SCRIPT_PATH/start_stats_collection.sh test_$TS
	fi
	
	for user_num in `seq 1 $NUM_USERS`
	do
		FIXED_USER_NUM=`printf "%0*d\n" 2 $user_num`
		USER_PATH=$QUERY_PATH/user$FIXED_USER_NUM
		run_queries $FIXED_USER_NUM $USER_PATH&
	done
	while [ $(jobs -rp | wc -l) -gt 0 ]
	do
	  a=0
	  for job in `jobs -rp`
	  do 
	    a=$[$a + 1]
	  done
	  echo "Waiting for $a users to finish"   
	  
	  sleep 60

	done
	if [ "$COLLECT_STATS" == "true" ]
	then
		echo "Stopping Statistics Collection"
		$SCRIPT_PATH/stop_stats_collection.sh
	fi
fi
