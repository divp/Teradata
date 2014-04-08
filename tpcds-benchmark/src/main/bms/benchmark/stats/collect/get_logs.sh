#!/bin/sh
set -u

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

RUN_ID="$1"

for sys in iostat vmstat sarDEV
do
    if [[ -f {sys}_${RUN_ID}.log ]]
    then
        echo "ABORT: attempting to overwrite ${sys}_${RUN_ID}.log. Possible loss of statistics data. Relocate or remove the target file and try again"
        exit -1
    fi
done

for node in $CLUSTER_NODES
do
    for sys in iostat vmstat sarDEV
    do
        echo "Retrieving $sys from $node"
        ssh $node "cat $BMS_OUTPUT_PATH/${sys}_${RUN_ID}.log" >> ${sys}_${RUN_ID}.log
    done
done