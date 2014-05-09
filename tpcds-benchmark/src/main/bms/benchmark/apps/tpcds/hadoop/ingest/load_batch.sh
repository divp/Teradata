
#
# Parallel copy from local disk to HDFS
# /data/benchmark/tpcds/sf1000/001 -> /data/benchmark/tpcds/sf1000/001/s_item_1.dat 
#

. ../etl_env.sh $1 $2

#config
MKDIR_PARALLELISM=24
COPY_PARALLELISM=16
SED_PATTERN='s/.dat//g;s/_[1-9]//g'
EXTENSION=.dat

echo "starting load for Scale Factor=$SCALE_FACTOR, Batch=$BATCH"

# List all files, rmove file extension to generate table name, using xargs to generate parallelism, use Hadoop fs to move data onto cluster.
echo "Making HDFS directories..."
cd $BASE &&
ls -1 *.dat |
  sed -e $SED_PATTERN | 
  xargs --verbose -r --max-args=16 --max-procs=$MKDIR_PARALLELISM -I {} hadoop fs -mkdir -p $TARGET/{} 

# perform the copy
# 1 hadoop command per input, don't run if empty, echo command, parallelism 4
echo "Copying..."
cd $BASE &&
ls -1 *.dat |
  sed -e  $SED_PATTERN | 
  xargs --verbose -r --max-args=1 --max-procs=$COPY_PARALLELISM -I {} hadoop fs -copyFromLocal -f $BASE/{}$EXTENSION $TARGET/{}/ 

echo "done"

