#!/bin/bash

set -o nounset
set -o errexit

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

if [ $# -ne 1 ]
then
    "ERROR: Expecting SQL query as single argument"
    exit 1
fi    

sql="$1"

bteq <<EOF
.LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
DATABASE ${BMS_TERADATA_DBNAME_ETL1};

${sql}

.LOGOFF;
.EXIT;
EOF
