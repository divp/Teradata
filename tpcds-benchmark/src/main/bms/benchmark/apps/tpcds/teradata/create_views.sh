#!/bin/bash

set -o nounset
set -o errexit

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

$(dirname $0)/util/run_sql_script.sh $(dirname $0)/schema/create_etl_views.sql