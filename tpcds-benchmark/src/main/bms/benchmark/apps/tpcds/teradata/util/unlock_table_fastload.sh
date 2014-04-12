#!/bin/bash

# Unlock interrupted fastload for a given table

set -o nounset
set -o errexit

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

table_name="$1"
fastload <<EOF
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};        
    BEGIN LOADING ${table_name} ERRORFILES FASTLOAD_ERR1, FASTLOAD_ERR2;
    END LOADING;
    LOGOFF;
EOF

