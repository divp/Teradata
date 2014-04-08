
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