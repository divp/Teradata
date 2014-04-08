
# This script (start_samplers.sh) is designed to be injected into cluster slave nodes by a test driver via start_stats_collection.sh
# *** DO NOT *** reference any external scripts as there is no mechanism to inject them along with this source. 
# All environment variables referenced in this source are defined by prepending the contents of exports.sh above this text.
# See start_stats_collection.sh for details

set -o pipefail
set -o nounset

RUN_ID=$1 
NODE=$2

START_MS=$RUN_ID

echo "Starting statistics collection NODE: $NODE, RUN_ID: $RUN_ID, STATS_MAX_SAMPLES: $STATS_MAX_SAMPLES, STATS_SAMPLE_TIME_SEC=$STATS_SAMPLE_TIME_SEC"

# STATS_SAMPLE_TIME_SEC=1; STATS_MAX_SAMPLES=10; START_MS=1340649385
#  start capture scripts
nohup iostat -mtx $STATS_SAMPLE_TIME_SEC $STATS_MAX_SAMPLES | gawk 'BEGIN {t='$START_MS';s=1;h="'$(hostname)'"} /^avg-cpu/&&(NR>7) {t+='$STATS_SAMPLE_TIME_SEC';} NR>7 {if (/sd/) {gsub(/ +/,","); printf("%s,%s,%s,",t,s,h); print $0; fflush() }}' > $BMS_OUTPUT_PATH/iostat_${RUN_ID}.log 2>&1 &
echo $! > $BMS_OUTPUT_PATH/collect.stats.iostat.pid
nohup vmstat -S m -n $STATS_SAMPLE_TIME_SEC $STATS_MAX_SAMPLES | gawk 'BEGIN {t='$START_MS';s=1;h="'$(hostname)'"} NR>2 {gsub(/^ +/,""); gsub(/ +/,","); printf("%s,%s,%s,",t,s,h); print $0; t+='$STATS_SAMPLE_TIME_SEC'; fflush() }' > $BMS_OUTPUT_PATH/vmstat_${RUN_ID}.log 2>&1 &
echo $! > $BMS_OUTPUT_PATH/collect.stats.vmstat.pid
nohup sar -n DEV $STATS_SAMPLE_TIME_SEC $STATS_MAX_SAMPLES | gawk 'BEGIN {t='$START_MS';s=1;h="'$(hostname)'"} (NR>3  && $0 ~ /^[0-9][0-9]/ && $0 !~ /IFACE/) {gsub(/ +/,","); printf("%s,%s,%s,",t,s,h); print $0; t+='$STATS_SAMPLE_TIME_SEC'; fflush() }' > $BMS_OUTPUT_PATH/sarDEV_${RUN_ID}.log 2>&1 &
echo $! > $BMS_OUTPUT_PATH/collect.stats.sar.pid
