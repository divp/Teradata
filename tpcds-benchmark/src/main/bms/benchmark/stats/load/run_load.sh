#!/bin/bash

. $BENCHMARK_PATH/lib/lib.sh
VERSION="1.0.152"

function print_help {
    script_name=$(basename "$0")
    echo
    echo "BeETLe - Benchmark Management System Log ETL utility (v. $VERSION)"
    echo
    echo "Usage:"
    echo "   $script_name                                  Show this help message and exit"
    echo "   $script_name RUN_ID"
    exit
}

#=============================================================================================
#========================= Parse command line arguments ======================================
#=============================================================================================

log_info "Starting Benchmark Management System statistics data load (Teradata target) (v. $VERSION)"

[[ $# -eq 0 ]] && print_help

while getopts "r:t:n:jsV" opt ; do
    case $opt in
    r) RUN_ID=$OPTARG ; echo "RUN_ID=${RUN_ID}" ;;
    t) HOST=$OPTARG ; echo "HOST=${HOST}" ;;
    n) JMX_NAME=$OPTARG; echo "JMX_NAME=${JMX_NAME}" ;;
    j) JMX_ONLY=1; echo "JMETER LOGS ONLY";;
    s) STATS_ONLY=1 ; echo "STATS ONLY";;
    l) LOCAL=1 ; echo 'LOCAL';;
    V) SKIP_VACUUM=1; echo "SKIP VACUUM";;
    \?)
        echo "Invalid option: -$OPTARG"
        print_help >&2
    ;;
  esac
done

PROPS_FILE=$BENCHMARK_PATH/config/sample/test.properties
log_info "Using properties file $PROPS_FILE"

resolve_exports $PROPS_FILE

. $BENCHMARK_PATH/exports.sh

. $BENCHMARK_PATH/stats/load/lib.sh

if [ $# -lt 1 ]
then
    log "ERROR: ($0) Missing argument. Expecting RUN_ID"
    exit 1
fi

RUN_ID=$1

$BENCHMARK_PATH/stats/load/stage_stats_teradata.sh $RUN_ID
rc=$?
if [ $? -ne 0 ]
then
    log "ERROR: ($0) Runtime error staging statistics"
    exit 1
fi

$BENCHMARK_PATH/stats/load/load_stats_teradata.sh $RUN_ID
rc=$?
if [ $? -ne 0 ]
then
    log "ERROR: ($0) Runtime error loading statistics"
    exit 1
fi
