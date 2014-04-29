DROP TABLE IF EXISTS test_bucket_fact;

CREATE TABLE test_bucket_fact (
	sk	BIGINT,
	value	STRING
)
CLUSTERED BY(sk) INTO 32 BUCKETS
STORED AS ORC;

set hive.enforce.bucketing = true;
set mapred.reduce.tasks = 32;

INSERT OVERWRITE TABLE test_bucket_fact
select bk*1000000 + sk, value from (
  select abs(hash(value)%32 bk, rank() over (distribute by abs(hash(value)%32 sort by value) sk, value from raw_data
) x DISTRIBUTE BY sk
;

select * from test_bucket_fact
order by sk
limit 100;
