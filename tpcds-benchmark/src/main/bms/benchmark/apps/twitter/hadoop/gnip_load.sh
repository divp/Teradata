#!/bin/bash

set -o nounset
set -o errexit

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

INFILE=$1
MAXPS=5
PID=$$

if [[ ! -e $INFILE ]]; then
    log_error "($0) File $INFILE not found."
    exit 1
fi

SPLIT_FILE=$(basename $INFILE)_split_

log_info "($0) Splitting up ${INFILE} into $BMS_HADOOP_PARM_SA_HDFS_CHUNK_SIZE line chunks with basename ${SPLIT_FILE} in dir ${BMS_TEMP_DATA_PATH}"

split -a 3 -l ${BMS_HADOOP_PARM_SA_HDFS_CHUNK_SIZE} $INFILE ${BMS_TEMP_DATA_PATH}/${SPLIT_FILE} &
SPLIT_PID=$!

# Load split files into HDFS

LOADED_FILE_COUNT=0
# Loop while split process is still running or any files are found in $BMS_TEMP_DATA_PATH
while ((1))
do
    sleep 5
    if [[ $(ps --pid $SPLIT_PID -o pid= | wc -l) -gt 0 ]] 
    then
        log_info "($0) Split process with PID $SPLIT_PID is running"
    else
        log_info "($0) Split process with PID $SPLIT_PID is no longer running" 
        if [[ $(ls ${BMS_TEMP_DATA_PATH}/${SPLIT_FILE}* 2>/dev/null | wc -l) -lt 1 ]]
        then
            log_info "($0) No more files found in output directory $BMS_TEMP_DATA_PATH, exiting $0"
            exit
        fi
    fi
    for FILE in $(ls ${BMS_TEMP_DATA_PATH}/${SPLIT_FILE}* 2>/dev/null)
    do
        PSCNT=$(ps -ef | grep org.apache.hadoop.fs.FsShell | wc -l)
        if [[ $PSCNT -gt $MAXPS ]]
        then
            break
        fi
        LINE_COUNT=$(wc -l $FILE | cut -f1 -d' ')
        # Put file into HDFS if it contains a whole chunk or if split process is no longer running
        if [[ $LINE_COUNT -eq $BMS_HADOOP_PARM_SA_HDFS_CHUNK_SIZE ]] || [[ $(ps --pid $SPLIT_PID -o pid= | wc -l) -eq 0 ]]
        then
            $BENCHMARK_PATH/apps/twitter/hadoop/gnip_put.sh $FILE $BMS_HADOOP_HDFS_ROOT/raw/gnip/twitter &
            if [[ $? -ne 0 ]]
            then
                log_error "($0) Directory $BMS_TEMP_DATA_PATH not found."
                exit 1
            fi
            LOADED_FILE_COUNT=$(expr $LOADED_FILE_COUNT + 1)
        fi
    done
done

if [[ $LOADED_FILE_COUNT -eq 0 ]]
then
    log_error "($0) No output files found in $BMS_TEMP_DATA_PATH. Split operation failed."
    exit 1
fi
log_info "($0) Number of split files loaded into HDFS: $LOADED_FILE_COUNT"
