#!/bin/sh
set -u

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

echo "Showing latest statistics logs by node"
for node in $CLUSTER_NODES
do
    echo "--------- $node"
    ssh $node "ls -ltr $BMS_OUTPUT_PATH/{iostat,vmstat,sar}*.log | tail -3"
done
