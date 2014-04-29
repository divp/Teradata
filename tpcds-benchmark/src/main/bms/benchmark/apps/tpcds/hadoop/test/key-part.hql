
DROP TABLE IF EXISTS test_fact;
CREATE TABLE test_fact (
	sk	BIGINT,
	value	STRING
)
CLUSTERED BY(sk) INTO 32 BUCKETS
STORED AS ORC;

set hive.enforce.bucketing = true;

INSERT OVERWRITE TABLE test_fact
select sk, value from (
  select row_number() over () sk, value from raw_data
) x DISTRIBUTE BY sk
;

select * from test_fact
order by sk
limit 100;
