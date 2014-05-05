#!/bin/bash

# ALWAYS ensure this library is sourced by another script and not run directly by the shell
# It relies on environment variables defined by exports.sh

#set -o errexit
set -o errtrace
set -o nounset

function error_handler() {
    JOB="$0"              # job name
    LASTLINE="$1"         # line of error occurrence
    LASTERR="$2"          # error code
    echo "ERROR trapped in ${JOB} : line ${LASTLINE} with exit code ${LASTERR}"
    exit 1
}

#trap 'error_handler ${LINENO} $?' ERR

function get_script_log_name {
	script_path="$1"
	stem=$(echo $script_path | sed s:$BENCHMARK_PATH:: | sed 's:\./::' | sed s:/:-:g | sed 's/^-//')
    echo $BMS_OUTPUT_PATH/$stem.$BENCHMARK_RUN_ID.log
}

function log {
	message="$1"
	echo "[BMS driver][$(date +'%Y-%m-%d %H:%M:%S.%3N')] ${message}"
}

function log_info {
	message="$1"
	log "INFO: ${message}"
}

function log_warning {
	message="$1"
	log "WARN: ${message}"
}

function log_error {
	message="$1"
	log "ERROR: ${message}"
}

function log_break {
	log "===================================="
}

function resolve_exports {
    props_file="$1"
    if [ ! -f $props_file ]
    then
        log_error "Properties file $props_file not found"
        exit 1
    fi
    
    BENCHMARK_RUN_ID=$(date +%s)
    
    platform=''
    for p in ASTER HADOOP TERADATA IMPALA
    do
        if [ $(grep -c "^BMS_EXEC_PLATFORM_${p}=true" $props_file) -eq 1 ]
        then
            if [ "$platform" == '' ]
            then
                platform=${p}
            else
                log_error "Found Hadoop platform selector BMS_EXEC_PLATFORM_${p}=true while platform is already set to $platform"
            fi
        fi
    done
    
    echo "" > $BENCHMARK_PATH/exports.sh
    # Write main info header
    echo "# ******************************************" >> $BENCHMARK_PATH/exports.sh
    echo "# DO NOT EDIT THIS FILE"  >> $BENCHMARK_PATH/exports.sh
    echo "# It is generated automatically by the BMS JMeter test harness"  >> $BENCHMARK_PATH/exports.sh
    echo "# If you need to change these settings, use a properties file and"  >> $BENCHMARK_PATH/exports.sh
    echo "# specify it via the -p option when you run this script"  >> $BENCHMARK_PATH/exports.sh
    echo "# Update info: [$(date)][user:$(whoami)][$(pwd)/$0]"  >> $BENCHMARK_PATH/exports.sh
    echo "# ******************************************"  >> $BENCHMARK_PATH/exports.sh
    echo "export BENCHMARK_RUN_ID='$BENCHMARK_RUN_ID'" >> $BENCHMARK_PATH/exports.sh    
    
    log_info "Setting BENCHMARK_RUN_ID=$BENCHMARK_RUN_ID in exports file"
    runtime_props_file=/tmp/$(basename $props_file).${BENCHMARK_RUN_ID}
    
    # Resolve runtime properties
    log_info "Creating runtime properties file at $runtime_props_file"
    cat $props_file > $runtime_props_file
    echo "# Values resolved at runtime from input values in BMS_${platform}_* (see $runtime_props_file)" >> $runtime_props_file
    BMS_TARGET_HOST=$(grep "^BMS_${platform}_HOST=" $props_file | cut -d= -f2)
    echo "BMS_TARGET_HOST=$BMS_TARGET_HOST" >> $runtime_props_file
    BMS_TARGET_UID=$(grep "^BMS_${platform}_UID=" $props_file | cut -d= -f2)
    echo "BMS_TARGET_UID=$BMS_TARGET_UID" >> $runtime_props_file
    BMS_TARGET_PWD=$(grep "^BMS_${platform}_PWD=" $props_file | cut -d= -f2)
    echo "BMS_TARGET_PWD=$BMS_TARGET_PWD" >> $runtime_props_file
    BMS_TARGET_SSH_PORT=$(grep "^BMS_${platform}_SSH_PORT=" $props_file | cut -d= -f2)
    echo "BMS_TARGET_SSH_PORT=$BMS_TARGET_SSH_PORT" >> $runtime_props_file
    
    # Parse and write static properties
    sed -nre "/^#/! {s/^([^=]+)=([^#]*).*$/export \1='\2'/g;p}" < $runtime_props_file | sed -re "s/\s+'$/'/" >> $BENCHMARK_PATH/exports.sh

}