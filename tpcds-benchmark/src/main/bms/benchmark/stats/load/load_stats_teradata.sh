#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/stats/load/lib.sh
. $BENCHMARK_PATH/lib/teradata_lib.sh

#===========================================

function parse_xml_log {
    JMX_LOG="$1"
    log_info "Processing JMeter output file at $JMX_LOG - output at $JMX_LOG-header.csv, $JMX_LOG-detail.csv"
    # Parse original JMeter XML logs into CSV
    log_info "Parse test header data"
    grep '<sample t=' $JMX_LOG | 
        sed 's/^\s\s*//' | 
        grep -E 'lb="[A-Z]+[0-9]+:.*"' |
        perl -ne 'if (/sample t="([0-9]+)".*ts="([0-9]+)".*lb="([^"]+)".*rc="([^"]+)".*rm="([^"]+)".*tn="([^"]+)".*dt="([^"]*)".*by="([0-9]+)".*/) { print "$2|$1|$3|$4|$5|$6|$7|true|$8|0\n" }' |
        grep -v "^0,0," > $JMX_LOG-header.csv
    rc=$?
    if [ $rc -ne 0 ]
    then
        log "ERROR: unable to parse test header data (code: $rc, ${BASH_SOURCE}:${LINENO})"
        exit 1
    fi

    log_info "Parse detail test data"    
    grep '<sample t=' $JMX_LOG | 
        sed 's/^\s\s*//' | 
        grep -E 'lb="[A-Z]+[0-9]+:.*"' |
        perl -ne 'if (/sample t="([0-9]+)".*ts="([0-9]+)".*lb="([^"]+)".*rc="([^"]*)".*rm="([^"]+)".*tn="([^"]+)".*dt="([^"]*)".*by="([0-9]+)".*/) { print "$2|$1|$3|$4|$5|$6|$7|true|$8|0\n" }' |
        grep -v "^0,0," > $JMX_LOG-detail.csv
    rc=$?
    if [ $rc -ne 0 ]
    then
        log "ERROR: unable to parse test detail data (code: $rc, ${BASH_SOURCE}:${LINENO})"
        exit 1
    fi        
}

function stage_csv_data {
    HEADER_CSV="$1"
    DETAIL_CSV="$2"
    echo "Import CSV test data"
LOG_FILE=$BMS_OUTPUT_PATH/stage_jmeter_log_summary.$RUN_ID.log

log_info "Staging jmeter log summary data (detail log at $LOG_FILE)"

fastload 2>&1 > $LOG_FILE <<EOF

.LOGON ${BMS_STATS_DB_HOST}/${BMS_STATS_DB_UID},${BMS_STATS_DB_PWD};

DATABASE ${BMS_STATS_DB_NAME};

DROP TABLE stage_jmeter_log_summary;

DROP TABLE ERR1;
DROP TABLE ERR2;

CREATE TABLE stage_jmeter_log_summary,
    NO FALLBACK ,
    NO BEFORE JOURNAL,
    NO AFTER JOURNAL,
    CHECKSUM = DEFAULT (
    tstamp_epoch BIGINT,
    elapsed_ms BIGINT,
    label VARCHAR(2000),
    response_code INT,
    response_message VARCHAR(3000),
    thread_name VARCHAR(100),
    data_type VARCHAR(100),
    success VARCHAR(10),
    _bytes INT,
    latency INT
);

.ERRLIMIT 1;

.SET RECORD VARTEXT '|';
DEFINE
    in_tstamp_epoch (VARCHAR(30))
    ,in_elapsed_ms (VARCHAR(30))
    ,in_label (VARCHAR(100))
    ,in_response_code (VARCHAR(50))
    ,in_response_message (VARCHAR(3000))
    ,in_thread_name (VARCHAR(50))
    ,in_data_type (VARCHAR(30))
    ,in_success (VARCHAR(30))
    ,in_bytes (VARCHAR(30))
    ,in_latency (VARCHAR(30))
FILE=$HEADER_CSV;

SHOW;

.BEGIN LOADING benchmark.stage_jmeter_log_summary ERRORFILES benchmark.ERR1, benchmark.ERR2;

INSERT INTO benchmark.stage_jmeter_log_summary VALUES (
    :in_tstamp_epoch
    ,:in_elapsed_ms
    ,:in_label
    ,:in_response_code
    ,:in_response_message
    ,:in_thread_name
    ,:in_data_type
    ,:in_success
    ,:in_bytes
    ,:in_latency
);

.END LOADING;
.LOGOFF;
EOF

rc=$?
if [ $rc -ne 0 ]
then
    log "ERROR: unable to stage jmeter log summary data (code: $rc)"
    exit 1
fi

LOG_FILE=$BMS_OUTPUT_PATH/stage_jmeter_log.$RUN_ID.log

log_info "Staging jmeter log detail data (detail log at $LOG_FILE)"

fastload 2>&1 > $LOG_FILE <<EOF

.LOGON ${BMS_STATS_DB_HOST}/${BMS_STATS_DB_UID},${BMS_STATS_DB_PWD};

DATABASE ${BMS_STATS_DB_NAME};

DROP TABLE ERR1;
DROP TABLE ERR2;

DROP TABLE stage_jmeter_log;
CREATE TABLE stage_jmeter_log,
    NO FALLBACK ,
    NO BEFORE JOURNAL,
    NO AFTER JOURNAL,
    CHECKSUM = DEFAULT (
    tstamp_epoch BIGINT,
    elapsed_ms BIGINT,
    label VARCHAR(2000),
    response_code INT,
    response_message VARCHAR(1000),
    thread_name VARCHAR(100),
    data_type VARCHAR(100),
    success VARCHAR(10),
    _bytes INT,
    latency INT
);

.ERRLIMIT 1;

.SET RECORD VARTEXT '|';
DEFINE
    in_tstamp_epoch (VARCHAR(30))
    ,in_elapsed_ms (VARCHAR(30))
    ,in_label (VARCHAR(30))
    ,in_response_code (VARCHAR(10))
    ,in_response_message (VARCHAR(30))
    ,in_thread_name (VARCHAR(30))
    ,in_data_type (VARCHAR(30))
    ,in_success (VARCHAR(30))
    ,in_bytes (VARCHAR(30))
    ,in_latency (VARCHAR(30))
FILE=$DETAIL_CSV;

SHOW;

.BEGIN LOADING benchmark.stage_jmeter_log ERRORFILES benchmark.ERR1, benchmark.ERR2;

INSERT INTO benchmark.stage_jmeter_log VALUES (
    :in_tstamp_epoch
    ,:in_elapsed_ms
    ,:in_label
    ,:in_response_code
    ,:in_response_message
    ,:in_thread_name
    ,:in_data_type
    ,:in_success
    ,:in_bytes
    ,:in_latency
);

.END LOADING;
.LOGOFF;
EOF

rc=$?
if [ $rc -ne 0 ]
then
    log "ERROR: unable to stage jmeter log data (code: $rc)"
    exit 1
fi

}

function load_test_headers {
    RUN_ID=$1
    echo "Load test definition data for run ID $RUN_ID"

START_EPOCH_EXPR="CAST(DATE '1970-01-01' + (tstamp_epoch / 86400000) AS TIMESTAMP(6))
+ ((tstamp_epoch MOD 86400000/1000) * INTERVAL '00:00:01.000000' HOUR TO SECOND)"
run_sql "DELETE FROM ${BMS_STATS_DB_NAME}.perf_test WHERE run_id=${RUN_ID};" 2>&1 >> $SQL_DETAIL_LOG

run_sql "INSERT INTO ${BMS_STATS_DB_NAME}.perf_test (run_id, name, test_plan, test_tag, start_tstamp, end_tstamp)
SELECT ${RUN_ID}, '$BMS_TEST_TAG','benchmark.jmx', 't_name',
(SELECT $START_EPOCH_EXPR FROM ${BMS_STATS_DB_NAME}.stage_jmeter_log_summary WHERE label LIKE '%--- Log banner:%'), (SELECT $START_EPOCH_EXPR FROM ${BMS_STATS_DB_NAME}.stage_jmeter_log_summary WHERE label LIKE '%EXIT%');" 2>&1 >> $SQL_DETAIL_LOG

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

START_EPOCH_EXPR="CAST(DATE '1970-01-01' + (tstamp_epoch / 86400000) AS TIMESTAMP(6))
+ ((tstamp_epoch MOD 86400000/1000) * INTERVAL '00:00:01.000000' HOUR TO SECOND) AS start_tstamp"
END_EPOCH_EXPR="CAST(DATE '1970-01-01' + ((tstamp_epoch + elapsed_ms) / 86400000) AS TIMESTAMP(6))
+ (((tstamp_epoch + elapsed_ms) MOD 86400000/1000) * INTERVAL '00:00:01.000000' HOUR TO SECOND) AS end_tstamp"

run_sql "DELETE FROM ${BMS_STATS_DB_NAME}.perf_test_case WHERE run_id=${RUN_ID};" 2>&1 >> $SQL_DETAIL_LOG

run_sql "INSERT INTO ${BMS_STATS_DB_NAME}.perf_test_case (run_id, case_name, sampler_type, request_text, response_bytes, response_text, thread_id, thread_group_name, start_tstamp, end_tstamp, elapsed_ms)
SELECT ${RUN_ID} run_id, label, 'SSH sampler', 'TODO', _bytes, 'TODO', -1, thread_name, 
$START_EPOCH_EXPR, $END_EPOCH_EXPR, elapsed_ms
FROM ${BMS_STATS_DB_NAME}.stage_jmeter_log
WHERE label NOT LIKE '%Stop on runtime%';" 2>&1 >> $SQL_DETAIL_LOG

    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "Error loading test detail data , please check the logs is $SQL_DETAIL_LOG"
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

SUMMARY_REPORT="/tmp/load_teradata_summary.log.$(date +%s)"
SQL_DETAIL_LOG="/tmp/load_teradata_sql.log.$(date +%s)"

JMX_LOG_PREFIX='esg_benchmark.jmx_'
JMX_LOG_SUFFIX='-ALL.xml'
echo -e "\n======="
EPOCH_EXPR="CAST(DATE '1970-01-01' + (tstamp_epoch / 86400) AS TIMESTAMP(6))
+ ((tstamp_epoch MOD 86400) * INTERVAL '00:00:01.000000' HOUR TO SECOND) AS tstamp"
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


function print_help {
    echo "Usage: $0 RUN_ID"
    echo "e.g. $0 1392843882"
}

if [ $# -lt 1 ]
then
    log "ERROR: ($0) Missing argument. Expecting RUN_ID"
    exit 1
fi

RUN_ID=$1

log_info "Processing run $RUN_ID. Using Teradata DB host ${BMS_STATS_DB_HOST}, database ${BMS_STATS_DB_NAME}"
SUMMARY_REPORT="/tmp/load_teradata_summary.log.${RUN_ID}.$(date +%s)"

cat <<EOF >> $SUMMARY_REPORT 
{
source:BMS,
type:stats_load,
detail: {
EOF

# ==========================================================================
# =============              IOSTAT
# ==========================================================================

log_info "Loading staged iostat data"
run_sql "DELETE FROM ${BMS_STATS_DB_NAME}.iostat WHERE run_id=${RUN_ID};" 2>&1 >> $SQL_DETAIL_LOG
run_sql "INSERT INTO ${BMS_STATS_DB_NAME}.iostat (run_id, node_id, device, tstamp, rrqms, wrqms, rs, ws, rmbs, wmbs, avgrqsz, avgqusz, await, svctm, util) SELECT ${RUN_ID}, node_id, device, ${EPOCH_EXPR}, rrqms, wrqms, rs, ws, rmbs, wmbs, avgrqsz, avgqusz, await, svctm, util FROM ${BMS_STATS_DB_NAME}.stage_iostat;" 2>&1 >> $SQL_DETAIL_LOG

rc=$?
if [[ $rc -eq 0 ]]
then
    rowcount=$(get_query_result "SELECT COUNT(*) FROM ${BMS_STATS_DB_NAME}.iostat WHERE run_id=$RUN_ID;")
    echo -n "iostat:{status:OK, count:$rowcount}" >> $SUMMARY_REPORT 
else
    log_error "Error loading vmstat data"
    echo -n "iostat {status:ERROR}" >> $SUMMARY_REPORT 
fi

echo "," >> $SUMMARY_REPORT 

# ==========================================================================
# =============              SAR
# ==========================================================================

log_info "Loading staged sar data"
run_sql "DELETE FROM ${BMS_STATS_DB_NAME}.sarstat WHERE run_id=${RUN_ID};" 2>&1 >> $SQL_DETAIL_LOG
run_sql "INSERT INTO ${BMS_STATS_DB_NAME}.sarstat (run_id, node_id, tstamp, iface, rxpcks, txpcks, rxkbs, txkbs, rxcmps, txmcsts, rxmcsts) SELECT ${RUN_ID}, node_id, ${EPOCH_EXPR}, iface, rxpcks, txpcks, rxkbs, txkbs, rxcmps, txmcsts, rxmcsts FROM ${BMS_STATS_DB_NAME}.stage_sarstat;" 2>&1 >> $SQL_DETAIL_LOG

rc=$?
if [[ $rc -eq 0 ]]
then
    rowcount=$(get_query_result "SELECT COUNT(*) FROM ${BMS_STATS_DB_NAME}.sarstat WHERE run_id=$RUN_ID;")
    echo -n "sar:{status:OK, count:$rowcount}" >> $SUMMARY_REPORT 
else
    log_error "Error loading sar data"
    echo -n "sar {status:ERROR}" >> $SUMMARY_REPORT 
fi

echo "," >> $SUMMARY_REPORT

# ==========================================================================
# =============              VMSTAT
# ==========================================================================

log_info "Loading staged vmstat data"
run_sql "DELETE FROM ${BMS_STATS_DB_NAME}.vmstat WHERE run_id=${RUN_ID};" 2>&1 >> $SQL_DETAIL_LOG
run_sql "INSERT INTO ${BMS_STATS_DB_NAME}.vmstat (run_id, node_id, tstamp, procs_r, procs_b, mem_swpd, mem_free, mem_buff, mem_cache, swap_si, swap_so, io_bi, io_bo, sys_in,sys_cs, cpu_us, cpu_sy, cpu_id, cpu_wa, cpu_st) 
    SELECT ${RUN_ID}, node_id, ${EPOCH_EXPR}, procs_r, procs_b, mem_swpd, mem_free, mem_buff, mem_cache, swap_si, swap_so, io_bi, io_bo, sys_in,sys_cs, cpu_us, cpu_sy, cpu_id, cpu_wa, cpu_st
    FROM ${BMS_STATS_DB_NAME}.stage_vmstat;" 2>&1 >> $SQL_DETAIL_LOG

rc=$?
if [[ $rc -eq 0 ]]
then
    rowcount=$(get_query_result "SELECT COUNT(*) FROM ${BMS_STATS_DB_NAME}.vmstat WHERE run_id=$RUN_ID;")
    echo "vmstat:{status:OK, count:$rowcount}" >> $SUMMARY_REPORT 
else
    log_error "Error loading vmstat data"
    echo "vmstat {status:ERROR}" >> $SUMMARY_REPORT 
fi

# ==================================

log_info "Data import completed (summary at $SUMMARY_REPORT)"
log_info "SQL detail log at $SQL_DETAIL_LOG"
echo -----------------------------------------------

echo -e "}\n}" >> $SUMMARY_REPORT
cat $SUMMARY_REPORT #| tr -d '\n' | sed -r 's/\s//g;s/@@/\n/g'

echo
echo -----------------------------------------------
#set -o pipefail


JMX_LOG="$BMS_OUTPUT_PATH/bms-${RUN_ID}-ALL.xml"
parse_xml_log "$JMX_LOG"
stage_csv_data "$JMX_LOG-header.csv" "$JMX_LOG-detail.csv"
load_test_headers $RUN_ID
load_test_detail $RUN_ID
