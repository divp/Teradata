#!/bin/sh
set -o errexit
#set -o pipefail
set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

NODES=$CLUSTER_NODES
echo "System statistics data collection will be stopped on $NODES"
for node in $NODES; 
do
  echo $node
  for subsys in iostat vmstat sar
  do
    script=$(echo "
    pid_file=$BMS_OUTPUT_PATH/collect.stats.${subsys}.pid;
    if [ -f \$pid_file ];
    then
        pid=\$(cat \$pid_file);
        echo 'Found ${subsys} pid file '\$pid;
        ps \$pid >/dev/null;
        rc=\$?;
        if [ \$rc -eq 0  ];
        then
            kill \$pid;
            echo 'Sent kill signal to PID '\$pid;
        else
            echo 'Process '\$pid'is no longer running';
        fi;
        rm \$pid_file;
    fi
    ")
    ssh $BMS_TARGET_UID@$node $script
    done
done


