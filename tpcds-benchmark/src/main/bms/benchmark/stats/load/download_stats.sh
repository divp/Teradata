#!/bin/sh

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

function usage() {
cat << EOF
    usage: $0 <RUN_ID> ...

Download statistics logs from registered nodes (see $BENCHMARK_PATH/exports.sh) for a given test run.
EOF
}

if [ $# -lt 1 ]
then
    log "ERROR: ($0) Missing argument. Expecting RUN_ID"
    exit 1
fi

if [ $# -gt 2 ]
then
    log "ERROR: ($0) Invalid arguments. Expecting RUN_ID or RUN_ID SSH_USER"
    exit 1
fi

RUN_ID=$1

SSH_USER=$(whoami)
if [ $# -eq 2 ]
then
	SSH_USER=$2
fi

echo "Downloading system statistics for RUN_ID=$RUN_ID from $CLUSTER_NODES as user $SSH_USER"

for subsys in iostat vmstat sar # back up existing outputs if found
do
    if [[ -f ${subsys}.out ]] 
    then
        mv ${subsys}.out ${subsys}.out.$(date +%Y%m%d%H%M%S)
    fi
done

# check presence of all requested files in all nodes
if [ $# -gt 0 ]
then
    echo "Getting statistics from nodes $CLUSTER_NODES"
    for node in $CLUSTER_NODES
    do
	    logs=$(ssh $SSH_USER@$node "find $BMS_OUTPUT_PATH/ -maxdepth 1 -regextype posix-extended -regex '.*/(sarDEV|iostat|vmstat).*_${RUN_ID}\.log'")
	    logs_count=$(echo $logs | wc -w)
	    if [ $logs_count -eq 3 ]
	    then
	        echo "Log file validation for run ID ${RUN_ID} on node $node: OK ($logs_count files)"
	    else
	        echo -e "Validation error on node $node: expecting 3 (sar, iostat, vmstat} matching logs for run ID ${RUN_ID}, found $logs_count:\n${logs}"
	        exit 1
	    fi
    done
else
    usage
    exit 1
fi

for subsys in iostat vmstat sarDEV
do
    [ -e $BMS_OUTPUT_PATH/${subsys}_${RUN_ID}_allnodes.log ] && rm $BMS_OUTPUT_PATH/${subsys}_${RUN_ID}_allnodes.log
done
for node in $CLUSTER_NODES
do
    for subsys in iostat vmstat sarDEV
    do
        echo "Compiling log files $BMS_OUTPUT_PATH/${subsys}_${RUN_ID}*.log"
echo $(echo "Downloading stats from node $node"; [ -n "$RUN_ID" ] && echo " with run ID '$RUN_ID'")
ssh $SSH_USER@$node "cat $BMS_OUTPUT_PATH/${subsys}_${RUN_ID}*.log" >> $BMS_OUTPUT_PATH/${subsys}_${RUN_ID}_allnodes.log
    done
done

