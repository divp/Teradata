
#
# Parallel copy from local disk to HDFS
# /data/benchmark/tpcds/sf1000/001 -> /data/benchmark/tpcds/sf1000/001/s_item_1.dat 
#

#inputs
SCALE_FACTOR=1000
BATCH_ID=1

#derived
BATCH=00$BATCH_ID
EXTENSION=_$BATCH_ID.dat
BASE=/data/benchmark/tpcds/sf$SCALE_FACTOR/$BATCH
TARGET=hdfs:///data/benchmark/tpcds/sf$SCALE_FACTOR/$BATCH

#config
MKDIR_PARALLELISM=24
COPY_PARALLELISM=16

echo "starting load for Scale Factor=$SCALE_FACTOR, Batch=$BATCH"

# List all files, rmove file extension to generate table name, using xargs to generate parallelism, use Hadoop fs to move data onto cluster.
echo "Making HDFS directories..."
cd $BASE &&
ls -1 *.dat |
  sed -e 's/_[0-9].dat//g'| 
  xargs --verbose -r --max-args=16 --max-procs=$MKDIR_PARALLELISM -I {} hadoop fs -mkdir -p $TARGET/{} 

# perform the copy
# 1 hadoop command per input, don't run if empty, echo command, parallelism 4
echo "Copying..."
cd $BASE &&
ls -1 *.dat |
  sed -e 's/_[0-9].dat//g'| 
  xargs --verbose -r --max-args=1 --max-procs=$COPY_PARALLELISM -I {} hadoop fs -copyFromLocal -f $BASE/{}$EXTENSION $TARGET/{}/ 

echo "done"

