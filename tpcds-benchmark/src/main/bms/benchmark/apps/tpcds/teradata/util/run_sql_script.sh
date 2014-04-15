#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

if [ $# -ne 1 ]
then
    "ERROR: Expecting path to SQL script as single argument"
    exit 1
fi

script_path="$1"

if [ ! -f $script_path ]
then
    log_error "Requested script $script_path is not accessible"
    exit 1
fi

bteq <<EOF
.LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
DATABASE ${BMS_TERADATA_DBNAME_ETL1};

$(cat "$script_path")

.LOGOFF;
.EXIT;
EOF

rc=$?

if [ $rc -ne 0 ]
then
    log_error "Error executing SQL script $script_path (BTEQ return code: $rc)"
    exit 1
fi
