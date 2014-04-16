# Run on 4/16/2014 @ 10.25.12.250

cd /data/tpcds/tools


mkdir -p /data/benchmark/tpcds/sf1/00{0,1,2,3,4}
# generate initialization set at 1GB
dsdgen -DIR /data/benchmark/tpcds/sf1/000 -scale 1 -RNGSEED 0
# generate 1GB update batches
dsdgen -DIR /data/benchmark/tpcds/sf1/001 -scale 1 -RNGSEED 0 -UPDATE 1
dsdgen -DIR /data/benchmark/tpcds/sf1/002 -scale 1 -RNGSEED 0 -UPDATE 2
dsdgen -DIR /data/benchmark/tpcds/sf1/003 -scale 1 -RNGSEED 0 -UPDATE 3
dsdgen -DIR /data/benchmark/tpcds/sf1/004 -scale 1 -RNGSEED 0 -UPDATE 4

# soft link existing 1TB initial set
mkdir -p /data/benchmark/tpcds/sf1000
ln -s /data/tpcds/SF1000 /data/benchmark/tpcds/sf1000/000
mkdir -p /data/benchmark/tpcds/sf1000/00{1,2,3,4}
# generate 1TB update batches
dsdgen -DIR /data/benchmark/tpcds/sf1000/001 -scale 1000 -RNGSEED 0 -UPDATE 1
dsdgen -DIR /data/benchmark/tpcds/sf1000/002 -scale 1000 -RNGSEED 0 -UPDATE 2
dsdgen -DIR /data/benchmark/tpcds/sf1000/003 -scale 1000 -RNGSEED 0 -UPDATE 3
dsdgen -DIR /data/benchmark/tpcds/sf1000/004 -scale 1000 -RNGSEED 0 -UPDATE 4

# soft link existing 3TB initial set
mkdir -p /data/benchmark/tpcds/sf3000
ln -s /data/tpcds/SF3000 /data/benchmark/tpcds/sf3000/000
mkdir -p /data/benchmark/tpcds/sf3000/00{1,2,3,4}
# generate 3TB update batches
dsdgen -DIR /data/benchmark/tpcds/sf3000/001 -scale 3000 -RNGSEED 0 -UPDATE 1
dsdgen -DIR /data/benchmark/tpcds/sf3000/002 -scale 3000 -RNGSEED 0 -UPDATE 2
dsdgen -DIR /data/benchmark/tpcds/sf3000/003 -scale 3000 -RNGSEED 0 -UPDATE 3
dsdgen -DIR /data/benchmark/tpcds/sf3000/004 -scale 3000 -RNGSEED 0 -UPDATE 4

# soft link existing 10TB initial set
mkdir -p /data/benchmark/tpcds/sf10000
ln -s /data/tpcds/SF10000 /data/benchmark/tpcds/sf10000/000
mkdir -p /data/benchmark/tpcds/sf10000/00{1,2,3,4}
# generate 3TB update batches
dsdgen -DIR /data/benchmark/tpcds/sf10000/001 -scale 10000 -RNGSEED 0 -UPDATE 1
dsdgen -DIR /data/benchmark/tpcds/sf10000/002 -scale 10000 -RNGSEED 0 -UPDATE 2
dsdgen -DIR /data/benchmark/tpcds/sf10000/003 -scale 10000 -RNGSEED 0 -UPDATE 3
dsdgen -DIR /data/benchmark/tpcds/sf10000/004 -scale 10000 -RNGSEED 0 -UPDATE 4