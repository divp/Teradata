

# usage: etl_env.sh [SCALE_FACTOR] [Batch id]
#  e.g.: etl_env.sh 1000 1
#        etl_env.sh 1000 0


#inputs
SCALE_FACTOR=${1:-1000}
BATCH_ID=${2:-1}

#derived
export SOURCE_DB=raw_ingest_sf$SCALE_FACTOR
export TARGET_DB=orc_tpcds$SCALE_FACTORg
export BATCH=00$BATCH_ID
export EXTENSION=*.dat
export BASE=/data/benchmark/tpcds/sf$SCALE_FACTOR/$BATCH
export TARGET=hdfs:///data/benchmark/tpcds/sf$SCALE_FACTOR/$BATCH

