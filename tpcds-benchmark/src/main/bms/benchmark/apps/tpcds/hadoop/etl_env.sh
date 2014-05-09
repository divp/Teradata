
export TARGET_DB=orc_tpcds1000g
export SOURCE_DB=raw_ingest_sf1000


#inputs
SCALE_FACTOR=1000
BATCH_ID=1

#derived
BATCH=00$BATCH_ID
EXTENSION=_$BATCH_ID.dat
BASE=/data/benchmark/tpcds/sf$SCALE_FACTOR/$BATCH
TARGET=hdfs:///data/benchmark/tpcds/sf$SCALE_FACTOR/$BATCH

