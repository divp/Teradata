#!/bin/bash

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh
. $BENCHMARK_PATH/stats/load/lib.sh

function print_help {
    echo "Usage: $0 RUN_ID"
    echo "e.g. $0 1392843882"
}

function parse_log {
    log_name="$1"
    sed -rn -f - <<EOF $log_name
    /Number of AMPs available/ { s/^[^N]+//p };
    /FASTLOAD/ { s/\s+=\s*//g; p };
    /PLATFORM/ { s/\s+=\s*//g; p };
    /Total Records Read/p;
    /Total Error Table/p;
    /Inserts Applied/p;
    /Total Duplicate Rows/p;
    /Total processor time used/ { s/^[^T]+//p };
    /Highest return code encountered/ { s/^[ .]+//p };
EOF
}

if [ $# -lt 1 ]
then
    log "ERROR: ($0) Missing argument. Expecting RUN_ID"
    exit 1
fi

RUN_ID=$1

log_info "Staging statistics for run $RUN_ID"

log_info "Searching locally for previously downloaded logs"
if [ $(ls $BMS_OUTPUT_PATH/{iostat,sarDEV,vmstat}_${RUN_ID}_allnodes.log 2>/dev/null| wc -l) -eq 3 ]
then
    log_info "Complete compiled statistics found locally for run $RUN_ID. Bypassing download from cluster"
else
    log_info "No complete compiled statistics found locally for run $RUN_ID. Starting download from cluster"

    log_info "Connecting to cluster head node ($BMS_TARGET_UID@$BMS_TARGET_HOST)"
    LOG_FILE=$BMS_OUTPUT_PATH/$(basename $0).worker.download.log
    log_info "Compiling worker statistics on head node (detail log at $LOG_FILE)"
    ssh $BMS_TARGET_UID@$BMS_TARGET_HOST "$BENCHMARK_PATH/stats/load/download_stats.sh $RUN_ID" > $LOG_FILE
    rc=$?
    if [ $? -lt 1 ]
    then
        log "ERROR: ($0) Runtime error compiling statistics on head node:"
        tail $LOG_FILE
        exit 1
    fi

    log_info "Downloading compiled statistics from head node"
    scp $BMS_TARGET_UID@$BMS_TARGET_HOST:$BMS_OUTPUT_PATH/bms-${RUN_ID}-ALL.* $BMS_OUTPUT_PATH 
    scp $BMS_TARGET_UID@$BMS_TARGET_HOST:$BMS_OUTPUT_PATH/\*_${RUN_ID}_allnodes.log $BMS_OUTPUT_PATH
fi

INPUT_FILE=$BMS_OUTPUT_PATH/iostat_${RUN_ID}_allnodes.log
LOG_FILE=$BMS_OUTPUT_PATH/stage_stats_teradata.iostat.$RUN_ID.log
log_info "Staging iostat data (detail log at $LOG_FILE)"

fastload 2>&1 > $LOG_FILE <<EOF

.LOGON localhost/dbc,dbc;

DATABASE benchmark;

DROP TABLE stage_iostat;

CREATE TABLE stage_iostat,
    NO FALLBACK ,
    NO BEFORE JOURNAL,
    NO AFTER JOURNAL,
    CHECKSUM = DEFAULT (
    tstamp_epoch BIGINT
    ,x0 INT
    ,node_id VARCHAR(30)
    ,device VARCHAR(10)
    ,rrqms DECIMAL(8,2)
    ,wrqms DECIMAL(8,2)
    ,rs DECIMAL(8,2)
    ,ws DECIMAL(8,2)
    ,rMBs DECIMAL(8,2)
    ,wMBs DECIMAL(8,2)
    ,avgrqsz DECIMAL(8,2)
    ,avgqusz DECIMAL(8,2)
    ,await DECIMAL(9,2)
    ,svctm DECIMAL(9,2)
    ,util DECIMAL(9,2)    
)
UNIQUE PRIMARY INDEX (tstamp_epoch,node_id,device);

.ERRLIMIT 1;

.SET RECORD VARTEXT ',';
DEFINE
    in_tstamp_epoch (VARCHAR(30))
    ,in_x0 (VARCHAR(30))
    ,in_node_id (VARCHAR(30))
    ,in_device (VARCHAR(10))
    ,in_rrqms (VARCHAR(30))
    ,in_wrqms (VARCHAR(30))
    ,in_rs (VARCHAR(30))
    ,in_ws (VARCHAR(30))
    ,in_rMBs (VARCHAR(30))
    ,in_wMBs (VARCHAR(30))
    ,in_avgrqsz (VARCHAR(30))
    ,in_avgqusz (VARCHAR(30))
    ,in_await (VARCHAR(30))
    ,in_svctm (VARCHAR(30))
    ,in_util (VARCHAR(30))
FILE=$INPUT_FILE;

SHOW;

.BEGIN LOADING benchmark.stage_iostat ERRORFILES benchmark.ERR1, benchmark.ERR2;

INSERT INTO benchmark.stage_iostat VALUES (
    :in_tstamp_epoch
    ,:in_x0
    ,:in_node_id
    ,:in_device
    ,:in_rrqms
    ,:in_wrqms
    ,:in_rs
    ,:in_ws
    ,:in_rMBs
    ,:in_wMBs
    ,:in_avgrqsz
    ,:in_avgqusz
    ,:in_await
    ,:in_svctm
    ,:in_util
);

.END LOADING;
.LOGOFF;
EOF

rc=$?

parse_log $LOG_FILE

if [ $rc -ne 0 ]
then
    log "ERROR: unable to stage iostat data (code: $rc)"
    exit 1
fi

INPUT_FILE=$BMS_OUTPUT_PATH/vmstat_${RUN_ID}_allnodes.log
LOG_FILE=$BMS_OUTPUT_PATH/stage_stats_teradata.vmstat.$RUN_ID.log
log_info "Staging vmstat data (detail log at $LOG_FILE)"

fastload 2>&1 > $LOG_FILE <<EOF

LOGON localhost/dbc,dbc;

DATABASE benchmark;

DROP TABLE stage_vmstat;

CREATE TABLE stage_vmstat,
    NO FALLBACK ,
    NO BEFORE JOURNAL,
    NO AFTER JOURNAL,
    CHECKSUM = DEFAULT (
    tstamp_epoch BIGINT
    ,x0 INT    
    ,node_id VARCHAR(30)
    ,procs_r INTEGER
    ,procs_b INTEGER
    ,mem_swpd INTEGER
    ,mem_free INTEGER
    ,mem_buff INTEGER
    ,mem_cache INTEGER
    ,swap_si INTEGER
    ,swap_so INTEGER
    ,io_bi INTEGER
    ,io_bo INTEGER
    ,sys_in INTEGER
    ,sys_cs INTEGER
    ,cpu_us INTEGER
    ,cpu_sy INTEGER
    ,cpu_id INTEGER
    ,cpu_wa INTEGER
    ,cpu_st INTEGER
)
UNIQUE PRIMARY INDEX (tstamp_epoch,node_id);

ERRLIMIT 1;

SET RECORD VARTEXT ',';
DEFINE
    in_tstamp_epoch (VARCHAR(30))
    ,in_x0 (VARCHAR(30))
    ,in_node_id (VARCHAR(30))
    ,in_procs_r (VARCHAR(30))
    ,in_procs_b (VARCHAR(30))
    ,in_mem_swpd (VARCHAR(30))
    ,in_mem_free (VARCHAR(30))
    ,in_mem_buff (VARCHAR(30))
    ,in_mem_cache (VARCHAR(30))
    ,in_swap_si (VARCHAR(30))
    ,in_swap_so (VARCHAR(30))
    ,in_io_bi (VARCHAR(30))
    ,in_io_bo (VARCHAR(30))
    ,in_sys_in (VARCHAR(30))
    ,in_sys_cs (VARCHAR(30))
    ,in_cpu_us (VARCHAR(30))
    ,in_cpu_sy (VARCHAR(30))
    ,in_cpu_id (VARCHAR(30))
    ,in_cpu_wa (VARCHAR(30))
    ,in_cpu_st (VARCHAR(30))
FILE=$INPUT_FILE;

SHOW;

BEGIN LOADING benchmark.stage_vmstat ERRORFILES benchmark.ERR1, benchmark.ERR2;

INSERT INTO benchmark.stage_vmstat VALUES (
    :in_tstamp_epoch
    ,:in_x0
    ,:in_node_id
    ,:in_procs_r
    ,:in_procs_b
    ,:in_mem_swpd
    ,:in_mem_free
    ,:in_mem_buff
    ,:in_mem_cache
    ,:in_swap_si
    ,:in_swap_so
    ,:in_io_bi
    ,:in_io_bo
    ,:in_sys_in
    ,:in_sys_cs
    ,:in_cpu_us
    ,:in_cpu_sy
    ,:in_cpu_id
    ,:in_cpu_wa
    ,:in_cpu_st
);

END LOADING;
LOGOFF;
EOF

rc=$?

parse_log $LOG_FILE

if [ $rc -ne 0 ]
then
    log "ERROR: unable to stage vmstat data"
    exit 1
fi

INPUT_FILE=$BMS_OUTPUT_PATH/sarDEV_${RUN_ID}_allnodes.log
LOG_FILE=$BMS_OUTPUT_PATH/stage_stats_teradata.sar.$RUN_ID.log
log_info "Staging sar data (detail log at $LOG_FILE)"

fastload 2>&1 > $LOG_FILE <<EOF

.LOGON localhost/dbc,dbc;

DATABASE benchmark;

DROP TABLE stage_sarstat;

CREATE TABLE stage_sarstat,
    NO FALLBACK ,
    NO BEFORE JOURNAL,
    NO AFTER JOURNAL,
    CHECKSUM = DEFAULT (
    tstamp_epoch BIGINT
    ,x0 INT     
    ,node_id VARCHAR(30)
    ,x1 VARCHAR(30)
    ,x2 VARCHAR(30)
    ,iface VARCHAR(20)
    ,rxpcks DECIMAL(9,2)
    ,txpcks DECIMAL(9,2)
    ,rxkbs DECIMAL(9,2)
    ,txkbs DECIMAL(9,2)
    ,rxcmps DECIMAL(9,2)
    ,txmcsts DECIMAL(9,2)
    ,rxmcsts DECIMAL(9,2)
)
UNIQUE PRIMARY INDEX (tstamp_epoch,node_id);

ERRLIMIT 1;

.SET RECORD VARTEXT ',';
DEFINE
    in_tstamp_epoch (VARCHAR(30))
    ,in_x0 (VARCHAR(30))    
    ,in_node_id (VARCHAR(30))
    ,in_x1 (VARCHAR(30))
    ,in_x2 (VARCHAR(30))
    ,in_iface (VARCHAR(30))
    ,in_rxpcks (VARCHAR(30))
    ,in_txpcks (VARCHAR(30))
    ,in_rxkbs (VARCHAR(30))
    ,in_txkbs (VARCHAR(30))
    ,in_rxcmps (VARCHAR(30))
    ,in_txmcsts (VARCHAR(30))
    ,in_rxmcsts (VARCHAR(30))
FILE=$INPUT_FILE;

SHOW;

.BEGIN LOADING benchmark.stage_sarstat ERRORFILES benchmark.ERR1, benchmark.ERR2;

INSERT INTO benchmark.stage_sarstat VALUES (
    :in_tstamp_epoch
    ,:in_x0    
    ,:in_node_id
    ,:in_x1
    ,:in_x2
    ,:in_iface
    ,:in_rxpcks
    ,:in_txpcks
    ,:in_rxkbs
    ,:in_txkbs
    ,:in_rxcmps
    ,:in_txmcsts
    ,:in_rxmcsts
);

.END LOADING;
.LOGOFF;
EOF

rc=$?

parse_log $LOG_FILE

if [ $rc -ne 0 ]
then
    log "ERROR: unable to stage sar data"
    exit 1
fi



    
    
