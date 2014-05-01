#!/bin/bash

set -o nounset

. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

echo "DO NOT RUN: this script is still in early development and serves as a guide for manual installation"
echo "Work is in progress to convert to fully automatic execution"
exit 0

if [ $(whoami) != 'root' ]
then
    echo "Running as $(whoami). Script must run as root"
    exit 1
fi

if [ -z "$BENCHMARK_PATH" ]
then
    BENCHMARK_PATH=/opt/benchmark
fi

if [ -z "$BMS_SOURCE_DATA_PATH" ]
then
    BMS_SOURCE_DATA_PATH=/data/benchmark
fi

BMS_USER=bms
if [ $(grep -c "^$BMS_USER:" /etc/passwd) -ne 1 ]
then
    useradd $BMS_USER
    echo 'tdc' | passwd --stdin $BMS_USER
    mkdir /home/$BMS_USER
    chown $BMS_USER:users /home/$BMS_USER
fi

if [ ! -d $BENCHMARK_PATH ]
then
    mkdir $BENCHMARK_PATH
fi
chown -R $BMS_USER:users $BENCHMARK_PATH

if [ ! -d $BMS_SOURCE_DATA_PATH ]
then
    mkdir $BMS_SOURCE_DATA_PATH
fi
chown -R $BMS_USER:users $BMS_SOURCE_DATA_PATH

# Passwordless SSH
#node=10.25.10.169
for node in $CLUSTER_NODES
do
    set -o xtrace
    echo "Configuring passwordless SSH to node $node"
    #ssh root@${node} "useradd bms; mkdir /home/bms; chown bms:root /home/bms"
    ssh root@${node} "chmod a+rx /data; mkdir -p /data/benchmark; chmod 755 /data/benchmark; chown bms:root /data/benchmark"
    ssh-copy-id -i ~/.ssh/id_rsa.pub $BMS_USER@{node}
    #echo -e "tdc\ntdc" | ssh root@${node} "passwd bms"
    #ssh bms@${node} "[[ ! -f ~/.ssh/id_rsa.pub ]] && ssh-keygen"
    #cat ~/.ssh/id_rsa.pub | ssh ${node} 'cat >> ~/.ssh/authorized_keys'
    #ssh ${node} "chmod go-w ~/; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys ~/.ssh/id_rsa; chmod 644 ~/.ssh/id_rsa.pub" # ~/.ssh/known_hosts"
    set +o xtrace 
done

sudo -u hdfs hadoop fs -mkdir /user/bms
sudo -u hdfs hadoop fs -chown bms:hdfs /user/bms

#---------------------

. $BENCHMARK_PATH/exports.sh

set -o nounset 

$BENCHMARK_PATH/sysinfo.sh

$BENCHMARK_PATH/set_security.sh

[[ ! -d ${BENCHMARK_OUTPUT_PATH} ]] && mkdir -p ${BENCHMARK_OUTPUT_PATH} 2>&1

sudo mkdir -p /var/opt/benchmark
sudo chmod 666 /var/opt/benchmark
sudo chown bms:users /var/opt/benchmark

sudo mkdir /data/benchmark/temp
sudo chmod 777 /data/benchmark/temp
sudo chown bms:users /data/benchmark/temp

# HADOOP
sudo -u hdfs hadoop fs -mkdir /user/bms
sudo -u hdfs hadoop fs -chown bms:hdfs /user/bms


