#!/bin/sh
#set -o errexit
#set -o nounset

source config.sh

if [[ $# -ne 1 ]]
then
    echo "ERROR: ($0) Missing parameter. Expecting RUN_ID"
    exit 1
fi


RUN_ID=$1

echo "Hardware statistics collection will be started on $CLUSTER_NODES"
echo "It will run for the next $(( $STATS_MAX_SAMPLES * $STATS_SAMPLE_TIME_SEC )) seconds"
echo
echo "RUN_ID: $RUN_ID, STATS_MAX_SAMPLES: $STATS_MAX_SAMPLES, STATS_SAMPLE_TIME_SEC=$STATS_SAMPLE_TIME_SEC"
for node in $CLUSTER_NODES
do
    if [[ $node != $HOSTNAME ]]
    then
        echo "Pushing slave script to $node:/tmp/start_samplers.sh"
        cat $SCRIPTPATH/exports.sh | ssh $BMS_TARGET_UID@$node "cat > /tmp/start_samplers.sh" 
        cat $SCRIPTPATH/start_samplers.sh | ssh $BMS_TARGET_UID@$node "cat >> /tmp/start_samplers.sh"
        ssh $BMS_TARGET_UID@$node "bash /tmp/start_samplers.sh $RUN_ID $node" 
    fi
done
