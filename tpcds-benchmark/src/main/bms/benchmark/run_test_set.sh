#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

LEFT_TOKEN='<boolProp name="TestPlan.serialize_threadgroups">'
RIGHT_TOKEN='</boolProp>'
BENCHMARK_PATH=/opt/benchmark
BENCHMARK_LOG_PATH=/var/opt/benchmark
JMETER_EXEC=$BENCHMARK_PATH/apache-jmeter-2.7/bin/jmeter.sh

function setSerializeThreadGroups {
    BAK_FILE=esg_benchmark_aster.bak.serialize_set.$(date +%s)
    mv esg_benchmark_aster.jmx $BAK_FILE
    perl -ne "s@(?<=${LEFT_TOKEN})(false|true)(?=${RIGHT_TOKEN})@true@; print" $BAK_FILE > esg_benchmark_aster.jmx
}

function clearSerializeThreadGroups {
    BAK_FILE=esg_benchmark_aster.bak.serialize_clear.$(date +%s)
    mv esg_benchmark_aster.jmx $BAK_FILE
    perl -ne "s@(?<=${LEFT_TOKEN})(false|true)(?=${RIGHT_TOKEN})@false@; print" $BAK_FILE > esg_benchmark_aster.jmx
}

# run sequential isolated tests for 1 and 5 threads uncompressed
TAG=aster5.0_seq_1x_ADWu1-SAu1-WLu1-WPu1
setSerializeThreadGroups
jmeter.sh -n -tesg_benchmark_aster.jmx -JBENCHMARK_USER_COUNT=1 -JBENCHMARK_TEST_TAG=${TAG} -JBENCHMARK_SA_LOOP_COUNT=1 -JBENCHMARK_WL_LOOP_COUNT=1 -JBENCHMARK_WP_LOOP_COUNT=1 JBENCHMARK_ADW_LOOP_COUNT=1
TAG=aster5.0_seq_5x_ADWu1-SAu1-WLu1-WPu1
jmeter.sh -n -tesg_benchmark_aster.jmx -JBENCHMARK_USER_COUNT=5 -JBENCHMARK_TEST_TAG=${TAG} -JBENCHMARK_SA_LOOP_COUNT=1 -JBENCHMARK_WL_LOOP_COUNT=1 -JBENCHMARK_WP_LOOP_COUNT=1 JBENCHMARK_ADW_LOOP_COUNT=1

exit

# reload targets with low compression
# run sequential isolated tests for 1 and 5 threads compressed
TAG=aster5.0_seq_1x_ADWu1-SAc1-WLc1-WPc1
setSerializeThreadGroups
jmeter.sh -n -tesg_benchmark_aster.jmx -JBENCHMARK_USER_COUNT=1 -JBENCHMARK_TEST_TAG=${TAG} -JBENCHMARK_SA_LOOP_COUNT=1 -JBENCHMARK_WL_LOOP_COUNT=1 -JBENCHMARK_WP_LOOP_COUNT=1 JBENCHMARK_ADW_LOOP_COUNT=1
TAG=aster5.0_seq_5x_ADWu1-SAc1-WLc1-WPc1
jmeter.sh -n -tesg_benchmark_aster.jmx -JBENCHMARK_USER_COUNT=5 -JBENCHMARK_TEST_TAG=${TAG} -JBENCHMARK_SA_LOOP_COUNT=1 -JBENCHMARK_WL_LOOP_COUNT=1 -JBENCHMARK_WP_LOOP_COUNT=1 JBENCHMARK_ADW_LOOP_COUNT=1

exit

# reload targets with mixed compression (SA/WP: compressed, WL: uncompressed) and weighted loop counts (SA:2, WL:7, WP:1, ADW:0 [excluded])
# run combined tests for 1 and 5 threads per module (3 and 15 threads total respectively)
TAG=aster5.0_comb_1x_SAc1-WLu7-WPc1
clearSerializeThreadGroups
jmeter.sh -n -tesg_benchmark_aster.jmx -JBENCHMARK_USER_COUNT=1 -JBENCHMARK_TEST_TAG=${TAG} -JBENCHMARK_SA_LOOP_COUNT=2 -JBENCHMARK_WL_LOOP_COUNT=7 -JBENCHMARK_WP_LOOP_COUNT=1 JBENCHMARK_ADW_LOOP_COUNT=0
TAG=aster5.0_comb_5x_SAc1-WLu7-WPc1
jmeter.sh -n -tesg_benchmark_aster.jmx -JBENCHMARK_USER_COUNT=5 -JBENCHMARK_TEST_TAG=${TAG} -JBENCHMARK_SA_LOOP_COUNT=2 -JBENCHMARK_WL_LOOP_COUNT=7 -JBENCHMARK_WP_LOOP_COUNT=1 JBENCHMARK_ADW_LOOP_COUNT=0

 
