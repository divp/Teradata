#!/bin/bash

function error_handler() {
  echo "Error occurred in script at line: ${1}."
  echo "Line exited with status: ${2}"
}

#trap 'error_handler ${LINENO} $?' ERR

# Example command line:
# /opt/benchmark/runtest.sh -j esg_benchmark.jmx -p /opt/benchmark/config/sample/test.properties
#

if [ -z $BENCHMARK_PATH ]
then
    echo "ERROR: Required environment variable BENCHMARK_PATH is undefined."
    echo "Ensure an appropriate export exists before running this script (typically 'export BENCHMARK_PATH=/opt/benchmark' in ~/.bashrc)"
    exit 1
fi

if [ -z $JMETER_HOME ]
then
    echo "ERROR: Required environment variable JMETER_HOME is undefined."
    echo "Ensure an appropriate export exists before running this script (typically 'export JMETER_HOME=/opt/apache-jmeter' in ~/.bashrc)"
    exit 1
fi

. $BENCHMARK_PATH/lib/lib.sh

JMETER_BIN=${JMETER_HOME}/bin/jmeter.sh

VERSION="1.0.152"
log_info "Starting Benchmark Management System test driver (v. $VERSION)"

function print_help {
    echo "Usage: $0 [-s [full|nostats] -j JMETER_TEST_PLAN -p PROPERTIES_FILE"
    echo "e.g. $0 -s full -j mytest.jmx -p myprops.properties"
}

function check_cli_options {
    log_break
    log_info "Checking command line options"
    if [ -z ${BMS_PROPS_FILE-} ]
    then
        log_error "Test properties file (e.g. ${BENCHMARK_PATH}/config/test.properties) was not specified. Must use -p option to provide path"
        exit 1
    fi
    echo "BMS_PROPS_FILE=${BMS_PROPS_FILE}"
    if [ -z ${BMS_JMX_FILE-} ]
    then
        log_error "JMeter test plan file (e.g. ${BENCHMARK_PATH}/esg_benchmark.jmx) was not specified. Must use -j option to provide path"
        exit 1
    fi
    echo "BMS_JMX_FILE=${BMS_JMX_FILE}"
    case $STATS in
        nostats) 
            log_warning "Statistics flag set to '$STATS'. No statistics will be collected"
            echo "Press 'Y' followed by ENTER to continue"
            read stats_confirm
            if [ "$stats_confirm" == 'Y' ]
            then
                log_warning "Statistics collection is disabled"
            else
                log_error "Prompt declined. Test aborted at statistics disabled warning"
                exit 1
            fi
            ;;
        full)
            log_info "Full statistics collection enabled"
            ;;
        *)
            log_error "Invalid statistics collection option (-s $STATS)"
            print_help >&2
        ;;
    esac
    if [ -n "$JMETER_OPTIONS" ]
    then
        log_warning "Found JMeter options '$JMETER_OPTIONS' on command line. They will be passed to JMeter and override values set for any of these variables"
    fi
}

function check_jmeter {
    required_jars=($JMETER_HOME/lib/jsch-0.1.48.jar $JMETER_HOME/lib/ext/jmeter-ssh-sampler-td-0.1.0.jar)
    for jar in $required_jars
    do
        if [ ! -r $jar ]
        then
            log_error "Required JMeter support JAR $jar was not found or does not have read permissions"
            exit 1
        fi
    done
}

function check_app_jars {
    required_jars=( $BENCHMARK_PATH/apps/lib/aster-mr.jar )
    #TODO: write logic to check for all required JARs
}

function check_config {
    log_break
    log_info "Checking test configuration"
    log_info "BENCHMARK_PATH=$BENCHMARK_PATH"
    log_info "BMS_OUTPUT_PATH=$BMS_OUTPUT_PATH"
    log_info "JMETER_BIN=$JMETER_BIN"
    log_info "BMS_JMX_FILE=$BMS_JMX_FILE"
    log_info "BMS_PROPS_FILE=$BMS_PROPS_FILE"
    log_info "BMS_JMETER_LOG=${BMS_JMETER_LOG}"
    log_info "BMS_SAMPLES_LOG=${BMS_SAMPLES_LOG}"
    log_info "BMS_CONSOLE_LOG=${BMS_CONSOLE_LOG}"

    if [ ! -d $BENCHMARK_PATH ]
    then
        log_error "Base BMS directory (\$BENCHMARK_PATH=$BENCHMARK_PATH) not found"
        exit 1
    elif [ ! -d $BMS_OUTPUT_PATH ]
    then
        log_error "BMS output directory (\$BMS_OUTPUT_PATH=$BMS_OUTPUT_PATH) not found"
        exit 1
    elif [ ! -w $BMS_OUTPUT_PATH ]
    then
        log_error "BMS output directory (\$BMS_OUTPUT_PATH=$BMS_OUTPUT_PATH) does not have required write permissions for current user $(whoami)"
        exit 1
    elif [ ! -f $JMETER_BIN ]
    then
        log_error "JMeter executable (\$JMETER_BIN=$JMETER_BIN) not found"
        exit 1
    elif [ ! -x $JMETER_BIN ]
    then
        log_error "JMeter executable (\$JMETER_BIN=$JMETER_BIN) does not have execute permissions for current user $(whoami)"
        exit 1
    elif [ ! -f $BMS_JMX_FILE ]
    then
        log_error "Test plan file (\$BMS_JMX_FILE=$BMS_JMX_FILE) not found"
        exit 1
    elif [ ! -r $BMS_JMX_FILE ]
    then
        log_error "Test plan file (\$BMS_JMX_FILE=$BMS_JMX_FILE) does not have read permissions for current user $(whoami)"
        exit 1
    elif [ ! -f $BMS_PROPS_FILE ]
    then
        log_error "Test configuration file (\$BMS_PROPS_FILE=$BMS_PROPS_FILE) not found"
        exit 1
    elif [ ! -r $BMS_PROPS_FILE ]
    then
        log_error "Test properties file (\$BMS_PROPS_FILE=$BMS_PROPS_FILE) does not have read permissions for current user $(whoami)"
        exit 1
    elif [ ! -d $BMS_SOURCE_DATA_PATH ] || [ ! -r $BMS_SOURCE_DATA_PATH ]
    then
        log_error "Source data directory is inaccessible (\$BMS_SOURCE_DATA_PATH=$BMS_SOURCE_DATA_PATH). It must exist with read permissions for user $(whoami)"
        exit 1
    elif [ ! -d $BMS_TEMP_DATA_PATH ] || [ ! -r $BMS_TEMP_DATA_PATH ]
    then
        log_error "Temporary data directory is inaccessible (\$BMS_TEMP_DATA_PATH=$BMS_TEMP_DATA_PATH). It must exist with read permissions for user $(whoami)"
        exit 1      
    fi
    find $BENCHMARK_PATH -name \*.sh |
        while read f
        do
            if [ ! -x $f ]
            then
                log_warning "Script $f lacks required execute permissions. Granting (u+x)"
                chmod u+x $f
                if [ ! -x $f ]
                then
                    log_error "Unable to grant execute permission on script $f. Please correct security configuration."
                    exit 1
                fi
            fi
        done

    if [ $DEBUG -eq 1 ]
    then
        log_info "Properties file $BMS_PROPS_FILE contents:"
        cat $BMS_PROPS_FILE
    fi
    
    log_break
    
    # TODO: Write platform-specific config checks (HDFS perms, paths, etc)
}

function ssh_passwordless_help {
    cat <<EOF
    Must enable passwordless SSH access from this host to all nodes in the cluster for user $BMS_TARGET_UID.
    Typical procedure:
    # on client:
    # Generate public SSH key
    [[ ! -f ~/.ssh/id_rsa.pub ]] && ssh-keygen

    # then for each node in cluster, copy public key into remote authorized keys file
    for node in \$CLUSTER_NODES
    do
        ssh root@\${node} "id $BMS_TARGET_UID"
        if [ \$? -ne 0 ]
        then
            echo "User $BMS_TARGET_UID does not exist on \${node}"
            ssh root@\${node} "useradd -d /homt/$BMS_TARGET_UID $BMS_TARGET_UID"
            ssh root@\${node} "passw $BMS_TARGET_PWD"
            ssh $BMS_TARGET_PWD@\$node "[[ ! -f ~/.ssh/id_rsa.pub ]] && ssh-keygen"
            #for node in ${CLUSTER_NODES[@]}; do ssh root@${node} 'mkdir -p /data/benchmark; chown bms:root /data/benchmark; chmod 755 /data/benchmark'; done
        fi
        
        cat ~/.ssh/id_rsa.pub | ssh \${node} 'cat >> ~/.ssh/authorized_keys'

        # and adjust permissions. SSH will refuse passwordless connections if these persmissions are
        # not set correctly
        chmod go-w ~/
        chmod 700 ~/.ssh
        chmod 600 ~/.ssh/authorized_keys ~/.ssh/id_rsa
        chmod 644 ~/.ssh/id_rsa.pub ~/.ssh/known_hosts
    done
EOF
}

function test_host {
	host=$1

	ts=$(date +%s)
	ts_echo=$(ssh $BMS_TARGET_UID@$host "echo $ts" 2>&1)
	if [ $? -ne 0 ]
	then
        log_error "SSH echo test failed for host $host. Stopping test."
		exit 1
	fi
}

function update_jmeter_lib_jars {
    ssh_sampler_jar_pattern='jmeter-ssh-sampler-*.jar'
    old_ssh_sampler_jar=$(find $JMETER_HOME/lib/ext -name "$ssh_sampler_jar_pattern")
    if [ -n "$old_ssh_sampler_jar" ]
    then
        log_info "Found JMeter SSH sampler jar at $old_ssh_sampler_jar - removing"
        rm -f $old_ssh_sampler_jar
    else
        log_info "JMeter SSH sampler jar not found"
    fi
    new_ssh_sampler_jar=$(find $BENCHMARK_PATH/lib/jmeter -name "$ssh_sampler_jar_pattern" | sort | tail -1)
    log_info "Copying $new_ssh_sampler_jar to $JMETER_HOME/lib/ext"
    cp $new_ssh_sampler_jar $JMETER_HOME/lib/ext
    
    jsch_jar_pattern='jsch-*.jar'
    old_jsch_jar=$(find $JMETER_HOME/lib -name "$jsch_jar_pattern")
    if [ -n "$old_jsch_jar" ]
    then
        log_info "Found JSch SSH library jar at $old_jsch_jar - removing"
        rm -f $old_jsch_jar
    else
        log_info "JMeter JSch SSH library jar not found"
    fi
    new_jsch_jar=$(find $BENCHMARK_PATH/lib/jmeter -name "$jsch_jar_pattern")
    log_info "Copying $new_jsch_jar to $JMETER_HOME/lib"
    cp $new_jsch_jar $JMETER_HOME/lib
}    

function check_cluster {
	SSH_KEY_FILE=~/.ssh/id_rsa
    log_info "Looking for $SSH_KEY_FILE"
	find $SSH_KEY_FILE 2>&1 >/dev/null
	if [ $? -ne 0 ]
	then
	    log_error "SSH key file $SSH_KEY_FILE does not exist. Stopping test."
	    ssh_passwordless_help
	    exit 1
	fi

    for host in $BMS_TARGET_HOST $CLUSTER_NODES
    do
        log_info "Testing SSH connection to cluster node $host as user $BMS_TARGET_UID"
        test_host $host
        if [ $? -ne 0 ]
        then
            log_error "SSH test failed for host $host ($ts_echo). Stopping test."
           #ssh_passwordless_help
            exit 1
        fi
        if [ $ts != $ts_echo ]
        then
            log_error "SSH test failed for host $host. Token mismatch ($ts <> $ts_echo). Stopping test."
            ssh_passwordless_help
            exit 1
        fi
        log_info "SSH test to host $host OK"
        set -o errexit
        retval=$(ssh $BMS_TARGET_UID@$host "if [ -w $BMS_OUTPUT_PATH ]; then echo yes; fi" 2>/dev/null)
        if [  "$retval" == 'yes' ]
        then
            log_info "Filesystem write check to $host:/$BMS_OUTPUT_PATH OK"
        else
            log_error "Filesystem write test to output directory \$BMS_OUTPUT_PATH=$BMS_OUTPUT_PATH failed on host $host."
            log_info "Check that directory exists and has read+write access for user $BMS_TARGET_UID"
            exit 1
        fi

    done
}

function start_stats {
    $BENCHMARK_PATH/stats/collect/stop_stats_collection.sh
    if [ $? -ne 0 ]
    then
        log_error "Error stopping statistics collection"
        exit 1
    fi
}

function stop_stats {
    $BENCHMARK_PATH/stats/collect/start_stats_collection.sh $BENCHMARK_RUN_ID 
    if [ $? -ne 0 ]
    then
        log_error "Error starting statistics collection"
        exit 1
    fi
}

function run_test {
    log_info "Running test '${BENCHMARK_RUN_ID}'"
    JVM_ARGS="-Xms1024m -Xmx1024m"
    runtime_props_file=/tmp/$(basename $props_file).${BENCHMARK_RUN_ID}
    $JMETER_BIN -n \
        -t $BMS_JMX_FILE -j $BMS_JMETER_LOG -l $BMS_SAMPLES_LOG -q $runtime_props_file \
        -JBENCHMARK_PATH=$BENCHMARK_PATH -JBENCHMARK_RUN_ID=$BENCHMARK_RUN_ID \
    -p $BENCHMARK_PATH/config/jmeter.properties $JMETER_OPTIONS | tee $BMS_CONSOLE_LOG
    rc=$?
    log_info "JMeter exit code: $rc"
    set +x
    log_info "Finished test '${BENCHMARK_RUN_ID}'"
}

function get_node_system_data {
    output_file=$BMS_OUTPUT_PATH/node_config.$BENCHMARK_RUN_ID.dat
    #meminfo: grep MemTotal | sed s/[^0-9]//g'
    #cpuinfo: 'cat /proc/cpuinfo | grep "model name" | uniq | sed "s/^.*:\s//;s/\s\s*/ /g"'
    #version
    for node in $CLUSTER_NODES
    do
        log_info "Downloading node configuration data from $node"
        for sysfile in /proc/{meminfo,cpuinfo,version}
        do
            echo "@@$node:$sysfile|$node@@" >> $output_file
            ssh $BMS_TARGET_UID@$node "cat $sysfile" >> $output_file
        done
        for cmd in df dmesg mount env
        do
            echo "@@$cmd|$node@@" >> $output_file
            ssh $BMS_TARGET_UID@$node "$cmd" >> $output_file
        done
    done
}

# *******************************************************************************
# ********************                   M A I N              *******************
# *******************************************************************************

DEBUG=0
STATS='full'
JMETER_OPTIONS=''
DRY_RUN=0
CHECK_CONFIG=1
while getopts "gj:J:np:s:" opt
do
    case $opt in
        g) DEBUG=1 ;;
        j) BMS_JMX_FILE=$OPTARG ;;
        J) JMETER_OPTIONS=$JMETER_OPTIONS' -J'$OPTARG ;;
        n) CHECK_CONFIG=0 ; STATS='nostats';;
        p) BMS_PROPS_FILE=$OPTARG ;;
        s) STATS=$OPTARG ;;
        \?)
            print_help >&2
            exit 1
        ;;
    esac
done

check_cli_options
rc=$?
if [ $rc -ne 0 ]
then
    log_error "Invalid command line parameters. Stopping test."
    exit 1
fi

log_info "Generating runtime exports"
resolve_exports $BMS_PROPS_FILE
rc=$?
if [ $rc -ne 0 ]
then
    log_error "Error generating exports. Stopping test."
    exit 1
fi

. $BENCHMARK_PATH/exports.sh

BMS_JMETER_LOG=${BMS_OUTPUT_PATH}/jmeter.log
BMS_SAMPLES_LOG=${BMS_OUTPUT_PATH}/log.jtl
BMS_CONSOLE_LOG=${BMS_OUTPUT_PATH}/${BENCHMARK_RUN_ID}.log

if [ $CHECK_CONFIG -eq 1 ]
then
    check_config
    rc=$?
    if [ $rc -eq 0 ]
    then
        log_info "Configuration check OK"
    else
        log_error "Configuration error in test driver host. Stopping test."
        exit 1
    fi

    check_jmeter
    rc=$?
    if [ $rc -eq 0 ]
    then
        log_info "JMeter JAR check OK"
    else
        log_error "JMeter JAR check failed. Stopping test."
        exit 1
    fi

    check_app_jars
    rc=$?
    if [ $rc -eq 0 ]
    then
        log_info "Application JAR check OK"
    else
        log_error "Application JAR check failed. Stopping test."
        exit 1
    fi

    check_cluster
    rc=$?
    if [ $rc -eq 0 ]
    then
        log_info "Cluster check OK"
    else
        log_error "Cluster check failed. Stopping test."
        exit 1
    fi
else
    log_info "BYPASSING statistics and cluster configuration checks"
fi    

if [ $STATS == 'full' ]
then
    get_node_system_data
    rc=$?
    if [ $rc -eq 0 ]
    then
        log_info "Cluster node system data pull OK"
    else
        log_error "Cluster node system data pull failed. Stopping test."
        exit 1
    fi

    stop_stats
    start_stats
    rc=$?
    if [ $rc -eq 0 ]
    then
        log_info "System statistics collection started."
    else
        log_error "Error starting system statistics collection. Stopping test."
        exit 1
    fi
fi

update_jmeter_lib_jars

if [ $DEBUG -eq 1 ]
then
    log_info "Debug option detected"
    #...
    log_info "Terminating test"
    exit
fi
run_test

if [ $STATS == 'full' ]
then
    log_info "Stopping statistics collection started"
    stop_stats
fi

echo "TODO: Build teardown logic"

#cd ${BENCHMARK_OUTPUT_PATH}; ${BENCHMARK_STATS_PATH}/collect/master/get_logs.sh ${__P(BENCHMARK_RUN_ID)}
#jmeter.sh -n -tesg_benchmark_aster.jmx -JBENCHMARK_USER_COUNT=5 -JBENCHMARK_TEST_TAG=${TAG} -JBENCHMARK_SA_LOOP_COUNT=1 -JBENCHMARK_WL_LOOP_COUNT=1 -JBENCHMARK_WP_LOOP_COUNT=1 JBENCHMARK_ADW_LOOP_COUNT=1
#mv ${BENCHMARK_OUTPUT_PATH}/jmeter.log ${BENCHMARK_OUTPUT_PATH}/jmeter.${__P(BENCHMARK_RUN_ID)}.log 2>&1
#cd ${BENCHMARK_OUTPUT_PATH}; tar cvzf output.${__P(BENCHMARK_RUN_ID)}.tgz *${__P(BENCHMARK_RUN_ID)}* 2>&1
# Capture exports.sh and properties file

#TAG=aster5.0_seq_5x_ADWu1-SAu1-WLu1-WPu1
#BENCHMARK_USER_COUNT=5
#BENCHMARK_TEST_TAG=5-thr-seq-hdp1.1-fixedorder-1ADu_1SAu_1WLu_1WPu
#run_test

