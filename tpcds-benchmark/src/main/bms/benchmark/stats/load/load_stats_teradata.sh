#!/bin/bash

set -o nounset
set -o errexit

. $BENCHMARK_PATH/lib/lib.sh

#===========================================

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

. $BENCHMARK_PATH/exports.sh

. $BENCHMARK_PATH/stats/load/lib.sh

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
run_sql "INSERT INTO ${BMS_STATS_DB_NAME}.iostat (run_id, node_id, device, tstamp, rrqms, wrqms, rs, ws, rmbs, wmbs, avgrqsz, avgqusz, await, svctm, util) SELECT ${RUN_ID}, node_id, device, ${EPOCH_EXPR}, rrqms, wrqms, rs, ws, rmbs, wmbs, avgrqsz, avgqusz, await, svctm, util FROM stage_iostat;" 2>&1 >> $SQL_DETAIL_LOG

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
run_sql "INSERT INTO sarstat (run_id, node_id, tstamp, iface, rxpcks, txpcks, rxkbs, txkbs, rxcmps, txmcsts, rxmcsts) SELECT ${RUN_ID}, node_id, ${EPOCH_EXPR}, iface, rxpcks, txpcks, rxkbs, txkbs, rxcmps, txmcsts, rxmcsts FROM stage_sarstat;" 2>&1 >> $SQL_DETAIL_LOG

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
run_sql "DELETE FROM vmstat WHERE run_id=${RUN_ID};" 2>&1 >> $SQL_DETAIL_LOG
run_sql "INSERT INTO vmstat (run_id, node_id, tstamp, procs_r, procs_b, mem_swpd, mem_free, mem_buff, mem_cache, swap_si, swap_so, io_bi, io_bo, sys_in,sys_cs, cpu_us, cpu_sy, cpu_id, cpu_wa, cpu_st) 
    SELECT ${RUN_ID}, node_id, ${EPOCH_EXPR}, procs_r, procs_b, mem_swpd, mem_free, mem_buff, mem_cache, swap_si, swap_so, io_bi, io_bo, sys_in,sys_cs, cpu_us, cpu_sy, cpu_id, cpu_wa, cpu_st
    FROM stage_vmstat;" 2>&1 >> $SQL_DETAIL_LOG

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




    
