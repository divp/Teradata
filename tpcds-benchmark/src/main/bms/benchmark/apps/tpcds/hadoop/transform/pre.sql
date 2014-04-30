--  Enable map join but set default size (cluster was 1GB)
SET hive.auto.convert.join=true;
SET hive.auto.convert.join.noconditionaltask=true;
SET hive.auto.convert.join.noconditionaltask.size=100000000;

-- Enable/Disable local mode which tends to run out of memory
SET hive.exec.mode.local.auto=true;

-- compress output stages
SET hive.exec.compress.output=true;
SET io.seqfile.compression.type=BLOCK;
SET mapreduce.output.fileoutputformat.compress=true;
SET mapreduce.output.fileoutputformat.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;

-- force bucketing on tables that define bucketing
SET hive.enforce.bucketing=true;

-- Compress intermediate outputs
SET hive.exec.compress.intermediate=true;
SET mapreduce.map.output.compress=true;
SET mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;

-- Start Reducers after 80%completion of maps
SET mapreduce.job.reduce.slowstart.completedmaps=0.5;

--Reuse JVM for upto 10 tasks
SET mapreduce.job.jvm.numtasks=10;

SET hive.mapjoin.localtask.max.memory.usage=0.99;
