# Run on 4/16/2014 @ 10.25.12.250

cd /data/tpcds/tools

# Generate base 1GB set
mkdir -p /data/benchmark/tpcds/sf1/00{0,1,2,3,4}
dsdgen -DIR /data/benchmark/tpcds/sf1/000 -scale 1 -RNGSEED 0
dsdgen -DIR /data/benchmark/tpcds/sf1/001 -scale 1 -RNGSEED 0 -UPDATE 1
dsdgen -DIR /data/benchmark/tpcds/sf1/002 -scale 1 -RNGSEED 0 -UPDATE 2
dsdgen -DIR /data/benchmark/tpcds/sf1/003 -scale 1 -RNGSEED 0 -UPDATE 3
dsdgen -DIR /data/benchmark/tpcds/sf1/004 -scale 1 -RNGSEED 0 -UPDATE 4

mkdir -p /data/benchmark/tpcds/sf1000/00{1,2,3,4}
dsdgen -DIR /data/benchmark/tpcds/sf1000/000 -scale 1000 -RNGSEED 0
dsdgen -DIR /data/benchmark/tpcds/sf1000/001 -scale 1000 -RNGSEED 0 -UPDATE 1
dsdgen -DIR /data/benchmark/tpcds/sf1000/002 -scale 1000 -RNGSEED 0 -UPDATE 2
dsdgen -DIR /data/benchmark/tpcds/sf1000/003 -scale 1000 -RNGSEED 0 -UPDATE 3
dsdgen -DIR /data/benchmark/tpcds/sf1000/004 -scale 1000 -RNGSEED 0 -UPDATE 4

mkdir -p /data/benchmark/tpcds/sf3000/00{1,2,3,4}
dsdgen -DIR /data/benchmark/tpcds/sf3000/000 -scale 3000 -RNGSEED 0
dsdgen -DIR /data/benchmark/tpcds/sf3000/001 -scale 3000 -RNGSEED 0 -UPDATE 1
dsdgen -DIR /data/benchmark/tpcds/sf3000/002 -scale 3000 -RNGSEED 0 -UPDATE 2
dsdgen -DIR /data/benchmark/tpcds/sf3000/003 -scale 3000 -RNGSEED 0 -UPDATE 3
dsdgen -DIR /data/benchmark/tpcds/sf3000/004 -scale 3000 -RNGSEED 0 -UPDATE 4