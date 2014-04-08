#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

ACT_PARMS='-U db_superuser -w db_superuser -d stats'

for subsys in $(get_config_option SUBSYSTEMS)
do
    echo "Loading $subsys"
    act $ACT_PARMS -c "TRUNCATE TABLE ${subsys}stat;"
    cat ${subsys}.out | act $ACT_PARMS --timing -c "COPY ${subsys}stat FROM STDIN WITH DELIMITER ',';"
done
