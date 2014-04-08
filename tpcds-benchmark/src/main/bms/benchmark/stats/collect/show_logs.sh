#!/bin/sh
set -u

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

LOG_STEM="$1"

for node in $CLUSTER_NODES
do
    ssh $node "cat $STATS_LOG_DIR/${LOG_STEM}.log"
done
