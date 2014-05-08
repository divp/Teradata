#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

function print_help {
    echo "Usage: "
    echo "$0 -s SCALE_TAG -q QUERY_TAG -u USER_ID    # for scale- and user- specific queries"
    echo "$0 -q QUERY_TAG                            # for scale- and user- independent queries"
    echo "e.g. $0 -s sf1000 -q Q25-032 -u 3"
    echo "e.g. $0 -q QF-a"
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

# Resolve physical query file from input arguments

if [[ $SCALE_TAG == 'sf20' ]]
then
    log_warning "Rerouting sf20 to sf1!"
    SCALE_TAG=sf1
fi

if [[ -n $SCALE_TAG && -n $QUERY_TAG && -n $USER_ID ]]
then
    query_file=$(dirname $0)/sql/${SCALE_TAG}/user$(printf "%02d" $USER_ID)/${QUERY_TAG}.sql
elif [[ -z $SCALE_TAG && -n $QUERY_TAG && -z $USER_ID ]]; then
    query_file=$(dirname $0)/sql/${QUERY_TAG}.sql
else
    log_error "Invalid arguments: $*"
    print_help >&2
    exit 1
fi



if [ ! -f $query_file ]
then
    log_error "Query file $query_file does not exist"
    exit 1
fi

LOG_FILE=$(get_script_log_name $0.${SCALE_TAG}.user$(printf "%02d" $USER_ID).${QUERY_TAG})
#exec > >(tee -a $LOG_FILE) 2> >(tee -a $LOG_FILE >&2)

echo "Running SQL query from file $query_file (output log: $LOG_FILE):"
# Read query SQL and expand any variable references
# FIX: Currently some SQL syntax, particularly 'SELECT *'
# causes unwanted shell expansion. Variable expansion is
# currently disabled.
# query_text="$(echo "$(eval echo \"$(cat $query_file)\")")"

query_text="$(cat $query_file)"

echo

bteq_output=$(mktemp)

log_info "Logging in as ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID}"

bteq <<EOF 2>&1 >$LOG_FILE 
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    .EXPORT FILE=${bteq_output}
    .SET SEPARATOR '|'
    .SET RETLIMIT 100
    .SET RETCANCEL ON

    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    LOCKING ROW FOR ACCESS
    ${query_text}

    .LOGOFF;
    .EXIT;
EOF
rc=$?

echo "--- Reading BTEQ output from $bteq_output"
cat $bteq_output
#rm $bteq_output

if [ $rc -ne 0 ]
then
  log_error "($0) Runtime error. See $LOG_FILE for details"
  exit $rc
fi

echo $BMS_TOKEN_EXIT_OK
