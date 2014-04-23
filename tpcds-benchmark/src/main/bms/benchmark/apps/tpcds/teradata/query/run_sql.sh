#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

function print_help {
    echo "Usage: $0 -s SCALE_TAG -q QUERY_TAG -u USER_ID"
    echo "e.g. $0 -s sf1000 -q Q25-032 -u 3"
}

SCALE_TAG=''
QUERY_TAG=''
USER_ID=''
while getopts "s:q:u:" opt
do
    case $opt in
        s) SCALE_TAG=$OPTARG ;;
        q) QUERY_TAG=$OPTARG ;;
        u) USER_ID=$OPTARG ;;
        \?)
            print_help >&2
            exit 1
        ;;
    esac
done

if [[ -z $SCALE_TAG || -z $QUERY_TAG || -z $USER_ID ]]
then
    log_error "Invalid arguments: $*"
    print_help >&2
    exit 1
fi

# Resolve physical query file from input arguments
query_file=$(dirname $0)/sql/${SCALE_TAG}/user$(printf "%02d" $USER_ID)/${QUERY_TAG}.sql

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
echo "$query_text"

bteq_output=$(mktemp)

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
stderr=$(cat $bteq_output)
rm $bteq_output

if [ $rc -ne 0 ]
then
  log_error "($0) Runtime error [$stderr]"
  exit $rc
fi

echo $BMS_TOKEN_EXIT_OK
