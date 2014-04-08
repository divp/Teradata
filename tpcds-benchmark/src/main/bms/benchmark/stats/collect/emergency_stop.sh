. $BENCHMARK_PATH/exports.sh

for n in $CLUSTER_NODES; do ssh $n "ps -ef | grep -E 'vmstat|iostat|sar' | awk '{print \$2;}' | while read p; do kill \$p; done"; done