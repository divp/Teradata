#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

if [ $# -lt 1 ]
then
    log_error "Expecting query tag as required first argument"
    exit 1
fi

query_name=$1
query_file=$(dirname $0)/sql/${query_name}.sql

if [ ! -f $query_file ]
then
    log_error "Query file $query_file does not exist"
    exit 1
fi

LOG_FILE=$(get_script_log_name $0.${query_name})
exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

echo "Running SQL query from file $query_file (output log: $LOG_FILE):"
# Read query SQL and expand any variable references
# FIX: Currently some SQL syntax, particularly 'SELECT *'
# causes unwanted shell expansion. Variable expansion is
# currently disabled.
# query_text="$(echo "$(eval echo \"$(cat $query_file)\")")"

query_text="$(cat $query_file)"

stderr_file=$(mktemp)

bteq <<EOF >/dev/null
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    .EXPORT FILE=${bteq_output}
    .SET SEPARATOR '|'
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    ${query_text}

    .LOGOFF;
    .EXIT;
EOF

rc=$?
stderr=$(cat $stderr_file)
rm $stderr_file

if [ $rc -ne 0 ]
then
  log_error "($0) Runtime error [$stderr]"
  exit $rc
fi

echo $BMS_TOKEN_EXIT_OK
