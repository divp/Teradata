#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/stats/load/lib.sh

BENCHMARK_OUTPUT_DIR='/var/opt/benchmark'
SUMMARY_REPORT="/tmp/load_pg_summary.log.$(date +%s)"
export PGPASSWORD=tdc
export PGUSER=postgres
export PGDATABASE=perf_stats
DB_CLI="psql"

LOCAL_LOG_DIR='/var/opt/benchmark'
JMX_LOG_PREFIX='esg_benchmark.jmx_'
JMX_LOG_SUFFIX='-ALL.xml'
echo -e "\n======="
EPOCH_EXPR="TIMESTAMP WITH TIME ZONE 'epoch' + ( 
    CASE 
    WHEN LOG(tstamp_epoch)<12 THEN tstamp_epoch 
    WHEN LOG(tstamp_epoch)>12 THEN tstamp_epoch/1000
    ELSE tstamp_epoch/0
    END) * INTERVAL '1 second'"
RUN_ID=''
HOST=''
JMX_NAME=''
STATS_ONLY=0
JMX_ONLY=0
STATS_ONLY=0
SYNC_STATS=0
SKIP_VACUUM=0

IOSTAT_FIELD_COUNT=15
VMSTAT_FIELD_COUNT=20
SAR_FIELD_COUNT=13

# define constants for fixed point error rate calculations
ERROR_RATE_MULTIPLIER=1000000 # 1 million (rate thus expressed in failures per million rows)
MAX_ERROR_RATE=10000 # 10 thousand (max error rate is thus 10K errors per million rows = 0.01 = 1%)

#=============================================================================================
#=============================================================================================
#=============================================================================================

function print_help {
    script_name=$(basename "$0")
    echo
    echo "BeETLe - Benchmark Management System Log ETL utility 1.4.1 (12/19/2012)"
    echo
    echo "Usage:"
    echo "   $script_name                                  Show this help message and exit"
    echo "   $script_name -s NODE                          Load active test result from node"
    echo "   $script_name -s NODE -r RUN_ID [-j] [-S] [-V] Load finished test result by known ID from node"
    echo "   $script_name -r RUN_ID                        Load test result set from local filesystem inbox ($LOCAL_LOG_DIR)"
    echo 
    echo "Download, extract and load result sets from cluster benchmark tests driven by from BMS performance test framework. Data is persisted in local RDBMS ($DB_CLI)"
    echo
    echo "Arguments:"
    echo "-r    Test run ID assigned by BMS - must match run ID assigned in JMeter output log"
    echo "-t    Hostname of test cluster head node. If ommited, test results are read from local filesystem inbox"
    echo "-j    Load only JMeter logs (no performance statistics)"
    echo "-s    Get stats only (do not import JMeter logs). For use in interrupted or correction runs"
    echo "-n    Change default dmx file name/log prefix"
    echo "-V    Skip postgres VACUUM optimization"
    exit
}

function get_run_id {
    echo "Connecting to $HOST to retrieve names of latest logs" >&2
    LOG_FILES=( echo $(ssh root@$HOST "cd ${BENCHMARK_OUTPUT_DIR}; ls -tr ${JMX_LOG_PREFIX}* iostat*.log vmstat*.log sarDEV*.log jmeter*.log | tail -6") )
    echo "File names returned by $HOST: ${LOG_FILES}" >&2
    if [[ "${LOG_FILES[@]}" =~ '\s*(jmeter\.log)\s*' ]]
    then 
        echo "jmeter.log found" >&2
        PREV_RUN_ID=''
    else
        if [[ "${LOG_FILES[@]}" =~ '\s*jmeter\.([0-9]*)\.log\s*' ]]
        then
            PREV_RUN_ID=${BASH_REMATCH[1]}
            RUN_ID=${PREV_RUN_ID}
            echo "jmeter.${RUN_ID}.log found" >&2
        else
            echo "No jmeter.log found" >&2
            return -1
        fi
    fi
    
    for prefix in iostat vmstat sarDEV
    do
        if [[ "${LOG_FILES[@]}" =~ '\s*'${prefix}'_([0-9]*)\.log' ]]
        then
            RUN_ID=${BASH_REMATCH[1]}
            echo "Found ${prefix} log with run ID=$RUN_ID" >&2
            if [[ -z $RUN_ID ]]
            then
                PREV_RUN_ID=$RUN_ID
            else
                if [[ $PREV_RUN_ID=='' || $RUN_ID == $PREV_RUN_ID ]]
                then
                    PREV_RUN_ID=$RUN_ID
                else
                    echo "Run ID mismatch" >&2
                    return -1
                fi
            fi
        else
            echo "No match for ${prefix}" >&2
            return -1
        fi
    done
    echo $RUN_ID
    return
}

function download_files {
    echo "Downloading files: $*"
    FILES=( $* )
    cat <<EOF | sftp root@${HOST}
        cd ${BENCHMARK_OUTPUT_DIR} 
        $(for f in $FILES; do echo "get $f"; done)
        bye
EOF
}

function download_stats {
    HOST=$1
    RUN_ID=$2
    mkdir -p ${LOCAL_LOG_DIR}
    cd $LOCAL_LOG_DIR
    if [[ 1 -eq $(ssh root@$HOST "cd ${BENCHMARK_OUTPUT_DIR}; ls -tr ${BENCHMARK_OUTPUT_DIR}/output.${RUN_ID}.tgz 2>/dev/null | wc -l ") ]]
    then
        echo "Found output archive, downloading"
        download_files output.${RUN_ID}.tgz
        echo "Uncompressing result set archive"
        tar xzvf output.${RUN_ID}.tgz | sed 's/^/   /'
        rc=$?
        if [[ $rc -ne 0 ]]
        then
            echo "Error uncompressing output.${RUN_ID}.tgz via tar"
            return $rc
        fi
    else    
        echo "Output archive not found, assuming active run, downloading..."
        echo "Transferring JMeter logs to local system [$LOCAL_LOG_DIR]"
        FILES="${JMX_LOG_PREFIX}${RUN_ID}-ALL.xml ${JMX_LOG_PREFIX}${RUN_ID}-ALL.csv jmeter.log jmeter.${RUN_ID}.log"
        download_files $FILES
        rc=$?
        if [[ $rc -ne 0 ]]
        then
            echo "Error retrieving ${FILES} via SFTP"
            return $rc
        fi 
        echo "Files ${FILES} retrieved"
        if [[ $JMX_ONLY -eq 0 ]]
        then
            FILES="${JMX_LOG_PREFIX}${RUN_ID}-ALL.xml ${JMX_LOG_PREFIX}${RUN_ID}-ALL.csv jmeter.log jmeter.${RUN_ID}.log"
            download_files $FILES
            rc=$?
            if [[ $rc -ne 0 ]]
            then
                echo "Error retrieving ${FILES} via SFTP"
                return $rc
            fi 
            echo "Files ${FILES} retrieved"
        fi
    fi
}


#----------------------------------------------------------------------------------------------------------

function load_stats {
    RUN_ID=$1
    # ---- iostat
    echo "Loading performance statistics for run ID $RUN_ID"
    echo "-------------------------------------------------"
    echo "Truncating statistics staging tables"
    "$DB_CLI" -e <<EOF
    \set ON_ERROR_STOP
    TRUNCATE TABLE stage_iostat;
    TRUNCATE TABLE stage_vmstat;
    TRUNCATE TABLE stage_sarstat;
EOF
    
    echo "RUN_ID=$RUN_ID" >> $SUMMARY_REPORT
    echo "|FILE=iostat_${RUN_ID}.log" >> $SUMMARY_REPORT
    echo "Processing IOSTAT"
    if [[ -f "${LOCAL_LOG_DIR}/iostat_${RUN_ID}.log" ]]
    then
        normalize "${LOCAL_LOG_DIR}/iostat_${RUN_ID}.log" $IOSTAT_FIELD_COUNT
        rc=$?
        if [[ $rc -eq 0 ]]; then
            echo "Loading iostat"
            "$DB_CLI" -e <<EOF
            \set ON_ERROR_STOP
            COPY stage_iostat FROM '${LOCAL_LOG_DIR}/iostat_${RUN_ID}.log' WITH (DELIMITER ',');

            DELETE FROM iostat WHERE run_id=${RUN_ID};

            INSERT INTO iostat (run_id, node_id, device, tstamp, rrqms, wrqms, rs, ws, rmbs, wmbs, avgrqsz, avgqusz, await, svctm, util) 
            SELECT ${RUN_ID}, node_id, device, ${EPOCH_EXPR}, rrqms, wrqms, rs, ws, rmbs, wmbs, avgrqsz, avgqusz, await, svctm, util
            FROM stage_iostat;
EOF
            rc=$?
            if [[ $rc -ne 0 ]]; then
                echo "Error loading iostat data -- skipping import"
                echo "{IOSTAT=LOAD_ERROR}" >> $SUMMARY_REPORT 
            fi
        else
            echo "Normalization of iostat data set failed -- skipping import"
            echo "{IOSTAT=NORM_ERROR}" >> $SUMMARY_REPORT 
        fi
    else
        echo "File ${LOCAL_LOG_DIR}/iostat_${RUN_ID}.log does not exist"
        echo "{IOSTAT=NO_FILE}" >> $SUMMARY_REPORT 
    fi
    echo '|IOSTAT='$("$DB_CLI" -tc 'SELECT COUNT(*) FROM stage_iostat;') >> $SUMMARY_REPORT
    echo "@@" >> $SUMMARY_REPORT
    
    echo "-------------------------------------------------"
    echo "Processing VMSTAT"
    echo "RUN_ID=$RUN_ID" >> $SUMMARY_REPORT
    echo "|FILE=vmstat_${RUN_ID}.log" >> $SUMMARY_REPORT
    if [[ -f "${LOCAL_LOG_DIR}/vmstat_${RUN_ID}.log" ]]
    then
        normalize "${LOCAL_LOG_DIR}/vmstat_${RUN_ID}.log" $VMSTAT_FIELD_COUNT
        rc=$?
        if [[ $rc -eq 0 ]]; then
            echo "Loading vmstat"
            "$DB_CLI" -e <<EOF
            \set ON_ERROR_STOP    
            COPY stage_vmstat FROM '${LOCAL_LOG_DIR}/vmstat_${RUN_ID}.log' WITH (DELIMITER ',');

            DELETE FROM vmstat WHERE run_id=${RUN_ID};

            INSERT INTO vmstat (run_id, node_id, tstamp, procs_r, procs_b, mem_swpd, mem_free, mem_buff, mem_cache, swap_si, swap_so, io_bi, io_bo, sys_in,sys_cs, cpu_us, cpu_sy, cpu_id, cpu_wa, cpu_st) 
            SELECT ${RUN_ID}, node_id, ${EPOCH_EXPR}, procs_r, procs_b, mem_swpd, mem_free, mem_buff, mem_cache, swap_si, swap_so, io_bi, io_bo, sys_in,sys_cs, cpu_us, cpu_sy, cpu_id, cpu_wa, cpu_st
            FROM stage_vmstat;
EOF
            rc=$?
            if [[ $rc -ne 0 ]]; then
                echo "Error loading vmstat data"
                echo "{VMSTAT=LOAD_ERROR}" >> $SUMMARY_REPORT 
            fi
        else
            echo "Normalization of vmstat data set failed -- skipping import"
            echo "{VMSTAT=NORM_ERROR}" >> $SUMMARY_REPORT
        fi
    else
        echo "File ${LOCAL_LOG_DIR}/vmstat_${RUN_ID}.log does not exist"
        echo "{VMSTAT=NO_FILE}" >> $SUMMARY_REPORT 
    fi
    echo 'VMSTAT='$("$DB_CLI" -tc 'SELECT COUNT(*) FROM stage_vmstat;') >> $SUMMARY_REPORT
    echo "@@" >> $SUMMARY_REPORT
    
    echo "-------------------------------------------------"
    echo "Processing SAR"
    echo "RUN_ID=$RUN_ID" >> $SUMMARY_REPORT
    echo "|FILE=sarDEV_${RUN_ID}.log" >> $SUMMARY_REPORT
    if [[ -f "${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log" ]]
    then        
        normalize "${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log" $SAR_FIELD_COUNT
        rc=$?
        if [[ $rc -eq 0 ]]; then
            echo "Loading sar"
            "$DB_CLI" -e <<EOF
            \set ON_ERROR_STOP
            COPY stage_sarstat FROM '${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log' WITH (DELIMITER ',');

            DELETE FROM sarstat WHERE run_id=${RUN_ID};

            INSERT INTO sarstat (run_id, node_id, tstamp, iface, rxpcks, txpcks, rxkbs, txkbs, rxcmps, txmcsts, rxmcsts) 
            SELECT ${RUN_ID}, node_id, ${EPOCH_EXPR}, iface, rxpcks, txpcks, rxkbs, txkbs, rxcmps, txmcsts, rxmcsts
            FROM stage_sarstat;
EOF
            rc=$?
            if [[ $rc -ne 0 ]]; then
                echo "Error loading sar data"
                echo "{SAR=LOAD_ERROR}" >> $SUMMARY_REPORT
            fi
        else
            echo "Normalization of sar data set failed -- skipping import"
            echo "{SARSTAT=NORM_ERROR}" >> $SUMMARY_REPORT
        fi
    else
        echo "File ${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log does not exist"
        echo "{SAR=NO_FILE}" >> $SUMMARY_REPORT  
    fi
    
    echo 'SAR='$("$DB_CLI" -tc 'SELECT COUNT(*) FROM stage_sarstat;') >> $SUMMARY_REPORT
    echo "@@" >> $SUMMARY_REPORT
    
    echo
    echo "Statistics for RUN_ID=${RUN_ID} have been processed"
    echo 
}

function vacuum_stats {
    echo "-------------------------------------------------"
    echo "Optimizing performance logs"
    "$DB_CLI" -e <<EOF
    \set ON_ERROR_STOP
    \c perf_stats

    VACUUM ANALYZE iostat;
    VACUUM ANALYZE vmstat;
    VACUUM ANALYZE sarstat;
EOF

    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "Error loading sar data"
        return $rc
    fi

    echo "Finished performance logs optimization"
}

function parse_xml_log {
    JMX_LOG="$1"
    echo "Processing JMeter output file at $JMX_LOG"
    # Parse original JMeter XML logs into CSV
    echo "Parse header test data"
    grep '<sample t=' $JMX_LOG | 
        sed 's/^\s\s*//' | 
        grep -vE 'lb="(S|WL|WP|R)(([0-9][0-9]")|(00:[^"]+"))' | 
        perl -ne 'if (/sample t="([0-9]+)".*ts="([0-9]+)".*lb="([^"]+)".*rc="([^"]+)".*rm="([^"]+)".*tn="([^"]+)".*dt="([^"]*)".*by="([0-9]+)".*/) { print "$2,$1,\"$3\",$4,\"$5\",\"$6\",\"$7\",\"true\",$8,0\n" }' |
        grep -v "^0,0," > $JMX_LOG-header.csv

    echo "Parse detail test data"    
    grep '<sample t=' $JMX_LOG | 
        sed 's/^\s\s*//' | 
        grep -E 'lb="(S|WL|WP|R)(([0-9][0-9]")|(00:[^"]+"))' | 
        perl -ne 'if (/sample t="([0-9]+)".*ts="([0-9]+)".*lb="([^"]+)".*rc="([^"]*)".*rm="([^"]+)".*tn="([^"]+)".*dt="([^"]*)".*by="([0-9]+)".*/) { print "$2,$1,\"$3\",$4,\"$5\",\"$6\",\"$7\",\"true\",$8,0\n" }' |
        grep -v "^0,0," 2>&1 > $JMX_LOG-detail.csv
}

function stage_csv_data {
    HEADER_CSV="$1"
    DETAIL_CSV="$2"
    echo "Import CSV test data"
    "$DB_CLI" -e <<EOF
\set ON_ERROR_STOP
TRUNCATE TABLE stage_jmeter_log_summary;
TRUNCATE TABLE stage_jmeter_log;
COPY stage_jmeter_log_summary FROM '$HEADER_CSV' WITH DELIMITER ',' CSV;
COPY stage_jmeter_log FROM '$DETAIL_CSV' WITH DELIMITER ',' CSV;
EOF
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "Error importing CSV data"
        return $rc
    fi
    echo "Loaded CSV test data"
}

function load_test_headers {
    RUN_ID=$1
    echo "Load test definition data for run ID $RUN_ID"
    "$DB_CLI" -e <<EOF
\set ON_ERROR_STOP
DELETE FROM perf_test WHERE run_id=${RUN_ID};

INSERT INTO perf_test (run_id, name, test_plan, test_tag, start_tstamp)
SELECT ${RUN_ID}, 
(SELECT (REGEXP_MATCHES(label,'.*BENCHMARK_TEST_NAME="([^"]*)".*'))[1] FROM stage_jmeter_log_summary WHERE label LIKE 'Setup suite (BENCHMARK_TEST_TAG=%'),
'aster_hadoop.jmx',
(SELECT (REGEXP_MATCHES(label,'.*BENCHMARK_TEST_TAG=([^,]*), '))[1] FROM stage_jmeter_log_summary WHERE label LIKE 'Setup suite (BENCHMARK_TEST_TAG=%'),
TIMESTAMP WITH TIME ZONE 'epoch' + (${RUN_ID} / 1000) * INTERVAL '1 second'
;

UPDATE perf_test SET 
user_count=CAST((SELECT (REGEXP_MATCHES(label,'.*USER_COUNT=([^,]*)'))[1] FROM stage_jmeter_log_summary WHERE label LIKE 'Setup suite (RUN_ID=%') AS INT),
loop_count=-1, -- *** TODO: normalize loop counts
runtime_sec=CAST((SELECT (REGEXP_MATCHES(label,'.*RUNTIME=([^,]*)'))[1] FROM stage_jmeter_log_summary WHERE label LIKE 'Setup suite (RUN_ID=%') AS INT),
ramp_up_sec=CAST((SELECT (REGEXP_MATCHES(label,'.*RAMP_UP_SEC=([^,)]*)'))[1] FROM stage_jmeter_log_summary WHERE label LIKE 'Setup suite (RUN_ID=%') AS INT),
test_desc='DESC!',
end_tstamp=(start_tstamp + 2 * INTERVAL '1 hour')
WHERE run_id=${RUN_ID};

EOF

    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "Error loading test header data"
        return $rc
    fi
    echo "Loaded test header data"
}

function load_test_detail {
    RUN_ID=$1
    echo "Load test detail data"
    "$DB_CLI" -e <<EOF
\set ON_ERROR_STOP
DELETE FROM perf_test_case WHERE run_id=${RUN_ID};

INSERT INTO perf_test_case (run_id, case_name, sampler_type, request_text, response_bytes, response_text, thread_id, thread_group_name, start_tstamp, end_tstamp, elapsed_ms)
SELECT ${RUN_ID} run_id, label, 'SSH sampler', 'TODO', bytes, 'TODO', -1, thread_name, 
TIMESTAMP WITH TIME ZONE 'epoch' + (tstamp_epoch * INTERVAL '1 millisecond') start_tstamp,
TIMESTAMP WITH TIME ZONE 'epoch' + (tstamp_epoch * INTERVAL '1 millisecond') + (elapsed_ms * INTERVAL '1 millisecond') end_tstamp,
elapsed_ms
FROM stage_jmeter_log
WHERE label NOT LIKE 'Stop on runtime%'

EOF

    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "Error loading test detail data"
        return $rc
    fi
    echo "Loaded test detail data"
}

function sync_stats {
    run_ids=$("$DB_CLI" -t <<EOF
        select distinct t0.run_id --, t1.run_id, tio.run_id, tvm.run_id, tsar.run_id
        FROM perf_test t0
        full outer join
        perf_test_case t1
        on t0.run_id = t1.run_id
        full outer join 
        agg_iostat tio
        ON 
        t1.case_instance_id = tio.case_instance_id
        full outer join 
        agg_vmstat tvm
        ON 
        coalesce(t1.case_instance_id,tio.case_instance_id) = tvm.case_instance_id
        full outer join 
        agg_sarstat tsar
        ON 
        coalesce(t1.case_instance_id,tio.case_instance_id, tvm.case_instance_id) = tsar.case_instance_id
        where t0.run_id is not null and t1.run_id is not null and tio.run_id is null
        and t0.start_tstamp > '2012-12-01'
        order by 1;
EOF
    )

    for run_id in $run_ids
    do
        echo "--------------------------------------------------------------------------------------------------"
        echo "sync_stats: run_id=$run_id has header test information but no detail statistics, attempting import"
        load_stats $run_id
    done
}

#=============================================================================================
#========================= Parse command line arguments ======================================
#=============================================================================================


[[ $# -eq 0 ]] && print_help

while getopts "r:t:n:jsV" opt ; do
    case $opt in
    r) RUN_ID=$OPTARG ; echo "RUN_ID=${RUN_ID}" ;;
    t) HOST=$OPTARG ; echo "HOST=${HOST}" ;;
    n) JMX_NAME=$OPTARG; echo "JMX_NAME=${JMX_NAME}" ;;
    j) JMX_ONLY=1; echo "JMETER LOGS ONLY";;
    s) STATS_ONLY=1 ; echo "STATS ONLY";;
    l) LOCAL=1 ; echo 'LOCAL';;
    V) SKIP_VACUUM=1; echo "SKIP VACUUM";;
    \?)
        echo "Invalid option: -$OPTARG"
        print_help >&2
    ;;
  esac
done

#=============================================================================================
#========================= Locate, download data set == ======================================
#=============================================================================================
echo "Logging summary output to $SUMMARY_REPORT"

if [[ $JMX_NAME != '' ]]
	then 
	JMX_LOG_PREFIX="$JMX_NAME.jmx_"
fi

if [[ $HOST == '' ]]
then
    echo "No host provided, loading from local log cache (bypass download)"
    if [[ $RUN_ID == '' ]]
    then
        echo "No run ID or host provided -- performing statistics synchronization run. Load routine will attempt to load local statistics for existing tests"
        SYNC_STATS=1
    else
        echo "Loading run ID(s) ${RUN_ID} from local log cache"
    fi
else echo "Downloading statistics from host ${HOST}"
    if [[ $RUN_ID == '' ]]
    then
        echo "No run ID(s) provided, assuming active run"
        RUN_ID=$(get_run_id)
        if [[ $RUN_ID -eq -1 ]]
        then
            echo "ERROR: Unable to verify run ID for log set"
            exit 1
        fi
    fi
    echo "Log set verified for run ID $RUN_ID"
    cd $LOCAL_LOG_DIR
    download_stats $HOST $RUN_ID
fi

if [[ $STATS_ONLY -ne 1 ]]
then
    JMX_LOG="${LOCAL_LOG_DIR}/${JMX_LOG_PREFIX}${RUN_ID}${JMX_LOG_SUFFIX}"
    parse_xml_log "$JMX_LOG"
    if [[ $? -ne 0 ]]; then
        echo "Error parsing XML log"
        exit 1
    fi
    stage_csv_data "$JMX_LOG-header.csv" "$JMX_LOG-detail.csv"
    if [[ $? -ne 0 ]]; then
        echo "Error staging CSV data"
        exit 1
    fi
    load_test_headers $RUN_ID
    if [[ $? -ne 0 ]]; then
        echo "Error loading test headers"
        exit 1
    fi
    load_test_detail $RUN_ID
    if [[ $? -ne 0 ]]; then
        echo "Error loading test detail"
        exit 1
    fi
fi
if [[ $JMX_ONLY -ne 1 ]]
then
    if [[ $SYNC_STATS -eq 1 ]]
    then
        sync_stats
    else
        load_stats $RUN_ID
    fi
    if [[ $SKIP_VACUUM -ne 1 ]]
    then
        vacuum_stats
    fi
fi




echo "Data import completed (summary at $SUMMARY_REPORT)"
echo -----------------------------------------------

cat $SUMMARY_REPORT | tr -d '\n' | sed -r 's/\s//g;s/@@/\n/g'

echo -----------------------------------------------
#set -o pipefail

