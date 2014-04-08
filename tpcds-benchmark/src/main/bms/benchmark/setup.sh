#!/bin/bash

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

sudo -u hdfs hadoop fs -mkdir /user/bms
sudo -u hdfs hadoop fs -chown bms:hdfs /user/bms
