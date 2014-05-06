#!/bin/bash

set -o nounset
#set -o errexit

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/stats/load/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

function error_handler() {
  echo "Error occurred in script at line: ${1}."
  echo "Line exited with status: ${2}"
}

#trap 'error_handler ${LINENO} $?' ERR

function print_help {
    echo "Usage: $0 RUN_ID"
    echo "e.g. $0 1392843882"
}

if [ $# -lt 1 ]
then
    log "ERROR: ($0) Missing argument. Expecting RUN_ID"
    exit 1
fi

RUN_ID=$1

log_info "Searching locally for previously downloaded logs"
if [ $(ls $BMS_OUTPUT_PATH/{iostat,sarDEV,vmstat}_${RUN_ID}_allnodes.log 2>/dev/null| wc -l) -eq 3 ]
then
    log_info "Complete compiled statistics found locally for run $RUN_ID. Bypassing download from cluster"
else
    log_info "No complete compiled statistics found locally for run $RUN_ID. Starting download from cluster"

    log_info "Connecting to cluster head node ($BMS_TARGET_UID@$BMS_TARGET_HOST)"
    LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).worker.download.log
    log_info "Compiling worker statistics on head node (detail log at $LOG_FILE)"
    #ssh $BMS_TARGET_UID@$BMS_TARGET_HOST "$BENCHMARK_PATH/stats/load/download_stats.sh $RUN_ID" > $LOG_FILE
    $BENCHMARK_PATH/stats/load/download_stats.sh $RUN_ID > $LOG_FILE
    rc=$?
    if [ $rc -ne 0 ]
    then
        log "ERROR: ($0) Runtime error compiling statistics on head node:"
        tail $LOG_FILE
        exit 1
    fi

    log_info "Downloading compiled statistics from head node"
    scp $BMS_TARGET_UID@$BMS_TARGET_HOST:$BMS_OUTPUT_PATH/bms-${RUN_ID}-ALL.* $BMS_OUTPUT_PATH 
    scp $BMS_TARGET_UID@$BMS_TARGET_HOST:$BMS_OUTPUT_PATH/\*_${RUN_ID}_allnodes.log $BMS_OUTPUT_PATH
fi

$BENCHMARK_PATH/stats/load/stage_stats_teradata.sh $RUN_ID
rc=$?
if [ $rc -ne 0 ]
then
    log "ERROR: ($0) Runtime error staging statistics"
    exit 1
fi

$BENCHMARK_PATH/stats/load/load_stats_teradata.sh $RUN_ID
rc=$?
if [ $rc -ne 0 ]
then
    log "ERROR: ($0) Runtime error loading statistics target tables"
    exit 1
fi
