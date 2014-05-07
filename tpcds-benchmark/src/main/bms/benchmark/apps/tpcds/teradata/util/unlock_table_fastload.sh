#!/bin/bash

# Unlock interrupted fastload for a given table

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

table_name="$1"

bteq <<EOF
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};        
    
    CREATE TABLE ${table_name}_bak AS (
        SELECT * FROM ${table_name}
    ) WITH NO DATA;
    
    DROP TABLE ${table_name};
    
    RENAME TABLE ${table_name}_bak to ${table_name};
    
    LOGOFF;
EOF

