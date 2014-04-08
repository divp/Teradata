#!/bin/bash

# This sample script shows the basic structure of a BMS test script
# $BENCHMARK_PATH must be defined to point to benchmark installation directory (e.g. /opt/benchmark) 

set -o nounset
set -o errexit

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

echo "Sample BMS test script"
hadoop fs -ls /

rc=$?
if [$rc -ne 0]
then
	echo "Error #$rc"
	exit 1
fi

# Print success token, read by JMeter assertions for validation
echo $BMS_TOKEN_EXIT_OK
