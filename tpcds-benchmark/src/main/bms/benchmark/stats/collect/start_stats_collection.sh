#!/bin/sh
set -o errexit
set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

if [[ $# -ne 1 ]]
then
    log "ERROR: ($0) Missing parameter. Expecting RUN_ID"
    exit 1
fi


RUN_ID=$1

echo "Hardware statistics collection will be started on $CLUSTER_NODES"
echo "Collection will terminate automatically after $(( $STATS_MAX_SAMPLES * $STATS_SAMPLE_TIME_SEC )) seconds"
echo
echo "Local statistics output path on each node: $BMS_OUTPUT_PATH"
echo "RUN_ID: $RUN_ID, STATS_MAX_SAMPLES: $STATS_MAX_SAMPLES, STATS_SAMPLE_TIME_SEC=$STATS_SAMPLE_TIME_SEC"
for node in $CLUSTER_NODES
do
    if [[ $node != $HOSTNAME ]]
    then
        echo "Pushing slave script to $node:/tmp/start_samplers.sh"
        cat $BENCHMARK_PATH/exports.sh | ssh $BMS_TARGET_UID@$node "cat > /tmp/start_samplers.sh" 
        cat $BENCHMARK_PATH/stats/collect/start_samplers.sh | ssh $BMS_TARGET_UID@$node "cat >> /tmp/start_samplers.sh"
        ssh $BMS_TARGET_UID@$node "bash /tmp/start_samplers.sh $RUN_ID $node" 
    fi
done

