#!/bin/sh
#set -o pipefail
set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

for node in $CLUSTER_NODES
do
  echo "Active stats processes on node '$node'"
  for subsys in iostat vmstat sar
  do
    ssh $node "ps -ef | grep $subsys | grep -v grep"
  done
done