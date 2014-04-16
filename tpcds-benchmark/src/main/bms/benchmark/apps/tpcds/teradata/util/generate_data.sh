# Run on 4/16/2014 @ 10.25.12.250

time (cd /data/tpcds/tools

for scale in 1 1000 3000 10000
do
    mkdir -p /data/benchmark/tpcds/sf${scale}
    # soft link existing data set for initialization batch
    ln -s /data/tpcds/SF${scale} /data/benchmark/tpcds/sf${scale}/000
    # generate update batch data sets
    for batch in 1 2 3 4
    do
        mkdir -p /data/benchmark/tpcds/sf${scale}/00${batch}
        time dsdgen -DIR /data/benchmark/tpcds/sf${scale}/00${batch} -scale ${scale} -RNGSEED 0 -UPDATE 1
    done
done) &
