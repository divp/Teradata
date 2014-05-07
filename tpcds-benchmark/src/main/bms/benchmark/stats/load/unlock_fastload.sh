#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/stats/load/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

fastload <<EOF

.LOGON ${BMS_STATS_DB_HOST}/${BMS_STATS_DB_UID},${BMS_STATS_DB_PWD};

DATABASE ${BMS_STATS_DB_NAME};

DROP TABLE ERR1;
DROP TABLE ERR2;

.BEGIN LOADING stage_iostat ERRORFILES ERR1, ERR2;
.END LOADING;
.BEGIN LOADING stage_sarstat ERRORFILES ERR1, ERR2;
.END LOADING;
.BEGIN LOADING stage_vmstat ERRORFILES ERR1, ERR2;
.END LOADING;
.LOGOFF;
.QUIT;
EOF


