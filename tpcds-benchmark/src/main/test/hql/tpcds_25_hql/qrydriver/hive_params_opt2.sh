set hive.optimize.ppd=true;
set hive.exec.parallel=true;
set hive.vectorized.execution.enabled=true;
set hive.optimize.reducededuplication.min.reduce=1;
set io.sort.mb=512;
set hive.exec.reducers.bytes.per.reducer=4194304;
set hive.exec.reducers.max=660;
set mapreduce.job.reduce.slowstart.completedmaps=0.5;
set hive.mapjoin.localtask.max.memory.usage=0.99;

