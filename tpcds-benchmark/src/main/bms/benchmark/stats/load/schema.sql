CREATE SEQUENCE iostat_seq_id
  INCREMENT 1
  MINVALUE 1
  START 51
  CACHE 1;
  
CREATE SEQUENCE perf_test_case_id
  INCREMENT 1
  MINVALUE 1
  START 73124
  CACHE 1;
  
CREATE SEQUENCE sar_seq_id
  INCREMENT 1
  MINVALUE 1
  START 1
  CACHE 1;
  
CREATE SEQUENCE vmstat_seq_id
  INCREMENT 1
  MINVALUE 1
  START 1
  CACHE 1;


DROP TABLE IF EXISTS test_cluster;

CREATE TABLE test_cluster (
	cluster_id INT,
	name VARCHAR(100),
	decription VARCHAR(2048),
	PRIMARY KEY (cluster_id)
);

CREATE TABLE cluster_node (
    node_id INT,
    node_name VARCHAR(200),
    node_ip_address VARCHAR(50),
    ram_mb INT,
	PRIMARY KEY (node_id)
);

DROP VIEW IF EXISTS perf_test_v;

DROP TABLE IF EXISTS perf_test;

CREATE TABLE perf_test (
	run_id BIGINT,
	name VARCHAR(100),
	test_plan VARCHAR(200),
	test_tag VARCHAR(100),
	user_count INT, -- per thread group
	loop_count INT,
	runtime_sec INT,
	ramp_up_sec INT,
	test_desc VARCHAR(1024),
	start_tstamp TIMESTAMP WITH TIME ZONE,
	end_tstamp TIMESTAMP WITH TIME ZONE,
	PRIMARY KEY (run_id)
);

CREATE VIEW perf_test_v AS
SELECT run_id, name, test_plan, test_tag, user_count, loop_count, runtime_sec,
ramp_up_sec, start_tstamp, end_tstamp
FROM perf_test;

DROP VIEW IF EXISTS perf_test_case_v;

DROP TABLE IF EXISTS perf_test_case;
DROP SEQUENCE IF EXISTS perf_test_case_id;
CREATE SEQUENCE perf_test_case_id;
CREATE TABLE perf_test_case (
	run_id BIGINT,
	case_instance_id INT DEFAULT nextval('perf_test_case_id'),
	case_name VARCHAR(100),
    sampler_type VARCHAR(100),
    request_text VARCHAR(2000),
    response_bytes INT,
    response_text VARCHAR(2000),
	thread_id INT,
	thread_group_name VARCHAR(100),
	start_tstamp TIMESTAMP WITH TIME ZONE,
	end_tstamp TIMESTAMP WITH TIME ZONE,
	elapsed_ms BIGINT,
	PRIMARY KEY (run_id, case_instance_id)
);

CREATE VIEW perf_test_case_v AS
SELECT run_id, case_instance_id, case_name, response_bytes thread_id,
thread_group_name, start_tstamp, end_tstamp, elapsed_ms
FROM perf_test_case;

DROP TABLE IF EXISTS iostat;

CREATE TABLE iostat (
run_id BIGINT
,node_id VARCHAR(30)
,tstamp TIMESTAMP WITH TIME ZONE
,device VARCHAR(10)
,rrqms DECIMAL(8,2)
,wrqms DECIMAL(8,2)
,rs DECIMAL(8,2)
,ws DECIMAL(8,2)
,rMBs DECIMAL(8,2)
,wMBs DECIMAL(8,2)
,avgrqsz DECIMAL(8,2)
,avgqusz DECIMAL(8,2)
,await DECIMAL(9,2)
,svctm DECIMAL(9,2)
,util DECIMAL(9,2)
,PRIMARY KEY (run_id,tstamp,node_id,device)
);

DROP TABLE IF EXISTS vmstat;

CREATE TABLE vmstat (
run_id BIGINT
,node_id VARCHAR(30)
,tstamp TIMESTAMP WITH TIME ZONE
,procs_r INTEGER
,procs_b INTEGER
,mem_swpd INTEGER
,mem_free INTEGER
,mem_buff INTEGER
,mem_cache INTEGER
,swap_si INTEGER
,swap_so INTEGER
,io_bi INTEGER
,io_bo INTEGER
,sys_in INTEGER
,sys_cs INTEGER
,cpu_us INTEGER
,cpu_sy INTEGER
,cpu_id INTEGER
,cpu_wa INTEGER
,cpu_st INTEGER
,PRIMARY KEY (run_id,tstamp,node_id)
);

DROP TABLE IF EXISTS sarstat;

CREATE TABLE sarstat (
run_id BIGINT
,node_id VARCHAR(30)
,tstamp TIMESTAMP WITH TIME ZONE
,iface VARCHAR(20)
,rxpcks DECIMAL(9,2)
,txpcks DECIMAL(9,2)
,rxkbs DECIMAL(9,2)
,txkbs DECIMAL(9,2)
,rxcmps DECIMAL(9,2)
,txmcsts DECIMAL(9,2)
,rxmcsts DECIMAL(9,2)
,PRIMARY KEY (run_id,tstamp,node_id)
);

DROP TABLE IF EXISTS stage_iostat;

CREATE TABLE stage_iostat (
    tstamp_epoch BIGINT
    ,x0 INT
    ,node_id VARCHAR(30)
    ,device VARCHAR(10)
    ,rrqms DECIMAL(8,2)
    ,wrqms DECIMAL(8,2)
    ,rs DECIMAL(8,2)
    ,ws DECIMAL(8,2)
    ,rMBs DECIMAL(8,2)
    ,wMBs DECIMAL(8,2)
    ,avgrqsz DECIMAL(8,2)
    ,avgqusz DECIMAL(8,2)
    ,await DECIMAL(9,2)
    ,svctm DECIMAL(9,2)
    ,util DECIMAL(9,2)    
    ,PRIMARY KEY (tstamp_epoch,node_id,device)
);

DROP TABLE IF EXISTS stage_vmstat;

CREATE TABLE stage_vmstat (
    tstamp_epoch BIGINT
    ,x0 INT    
    ,node_id VARCHAR(30)
    ,procs_r INTEGER
    ,procs_b INTEGER
    ,mem_swpd INTEGER
    ,mem_free INTEGER
    ,mem_buff INTEGER
    ,mem_cache INTEGER
    ,swap_si INTEGER
    ,swap_so INTEGER
    ,io_bi INTEGER
    ,io_bo INTEGER
    ,sys_in INTEGER
    ,sys_cs INTEGER
    ,cpu_us INTEGER
    ,cpu_sy INTEGER
    ,cpu_id INTEGER
    ,cpu_wa INTEGER
    ,cpu_st INTEGER
,PRIMARY KEY (tstamp_epoch,node_id)
);

DROP TABLE IF EXISTS stage_sarstat;

CREATE TABLE stage_sarstat (
    tstamp_epoch BIGINT
    ,x0 INT     
    ,node_id VARCHAR(30)
    ,x1 VARCHAR(30)
    ,x2 VARCHAR(30)
    ,iface VARCHAR(20)
    ,rxpcks DECIMAL(9,2)
    ,txpcks DECIMAL(9,2)
    ,rxkbs DECIMAL(9,2)
    ,txkbs DECIMAL(9,2)
    ,rxcmps DECIMAL(9,2)
    ,txmcsts DECIMAL(9,2)
    ,rxmcsts DECIMAL(9,2)
,PRIMARY KEY (tstamp_epoch,node_id)
);

DROP TABLE IF EXISTS stage_sarstat;

CREATE TABLE stage_sarstat (
    tstamp_epoch BIGINT
    ,x0 INT     
    ,node_id VARCHAR(30)
    ,x1 VARCHAR(30)
    ,x2 VARCHAR(30)
    ,iface VARCHAR(20)
    ,rxpcks DECIMAL(9,2)
    ,txpcks DECIMAL(9,2)
    ,rxkbs DECIMAL(9,2)
    ,txkbs DECIMAL(9,2)
    ,rxcmps DECIMAL(9,2)
    ,txmcsts DECIMAL(9,2)
    ,rxmcsts DECIMAL(9,2)
,PRIMARY KEY (tstamp_epoch,node_id)
);

-- BASE INDEXES

DROP INDEX IF EXISTS iostat_tstamp_idx;
CREATE INDEX iostat_tstamp_idx ON iostat (tstamp);
DROP INDEX IF EXISTS iostat_run_id_idx;
CREATE INDEX iostat_run_id_idx ON iostat (run_id);

DROP INDEX IF EXISTS vmstat_tstamp_idx;
CREATE INDEX vmstat_tstamp_idx ON vmstat (tstamp);
DROP INDEX IF EXISTS vmstat_run_id_idx;
CREATE INDEX vmstat_run_id_idx ON vmstat (run_id);

DROP INDEX IF EXISTS sarstat_tstamp_idx;
CREATE INDEX sarstat_tstamp_idx ON sarstat (tstamp);
DROP INDEX IF EXISTS sarstat_run_id_idx;
CREATE INDEX sarstat_run_id_idx ON sarstat (run_id);



DROP TABLE IF EXISTS stage_jmeter_log_summary;

CREATE TABLE stage_jmeter_log_summary (
    tstamp_epoch BIGINT,
    elapsed_ms BIGINT,
    label VARCHAR(2000),
    response_code INT,
    response_message VARCHAR(1000),
    thread_name VARCHAR(100),
    data_type VARCHAR(100),
    success VARCHAR(10),
    bytes INT,
    latency INT
);

DROP TABLE IF EXISTS stage_jmeter_log;

CREATE TABLE stage_jmeter_log (
    tstamp_epoch BIGINT,
    elapsed_ms BIGINT,
    label VARCHAR(2000),
    response_code INT,
    response_message VARCHAR(1000),
    thread_name VARCHAR(100),
    data_type VARCHAR(100),
    success VARCHAR(10),
    bytes INT,
    latency INT
);

DROP VIEW IF EXISTS agg_iostat_v;

CREATE VIEW agg_iostat_v AS
select 
    t1.run_id, t1.case_instance_id, t1.case_name,
    avg(rmbs) rmbs, avg(wmbs) wmbs,  avg(util) util
from
    (select run_id, tstamp, sum(rmbs) rmbs, sum(wmbs) wmbs, avg(util) util
    from iostat group by run_id, tstamp) t0
inner join 
perf_test_case t1
on
	t0.run_id = t1.run_id
and
	t0.tstamp >= t1.start_tstamp
and
	t0.tstamp <= t1.end_tstamp
group by 1,2,3;


DROP VIEW IF EXISTS agg_vmstat_v;

CREATE VIEW agg_vmstat_v as
select 
    t1.run_id, t1.case_instance_id, t1.case_name,
    avg(cpu_id) cpu_id, avg(cpu_sy) cpu_sy, avg(cpu_us) cpu_us, avg(mem_free) mem_free, avg(swap_si) swap_si, avg(swap_so) swap_so
from
    (select run_id, tstamp, sum(cpu_id) cpu_id, sum(cpu_sy) cpu_sy, sum(cpu_us) cpu_us, sum(mem_free) mem_free, sum(swap_si) swap_si, sum(swap_so) swap_so
    from vmstat group by run_id, tstamp) t0
inner join 
perf_test_case t1
on
	t0.run_id = t1.run_id
and
	t0.tstamp >= t1.start_tstamp
and
	t0.tstamp <= t1.end_tstamp
group by 1,2,3;

DROP VIEW IF EXISTS agg_sarstat_v;

CREATE VIEW agg_sarstat_v as
select 
    t1.run_id, t1.case_instance_id, t1.case_name,
    avg(txkbs) txkbs, avg(rxkbs) rxkbs
from
    (select run_id, tstamp, sum(txkbs) txkbs, sum(rxkbs) rxkbs
    from sarstat group by run_id, tstamp) t0
inner join 
    perf_test_case t1
on
	t0.run_id = t1.run_id
and
	t0.tstamp >= t1.start_tstamp
and
	t0.tstamp <= t1.end_tstamp
group by 1,2,3;

DROP VIEW IF EXISTS agg_stat_seq_v;

CREATE VIEW agg_stat_seq_v AS
SELECT ttc.run_id, ttc.case_instance_id, ttc.case_name, ttc.start_tstamp, ttc.end_tstamp, elapsed_ms,
AVG(rmbs) rmbs, AVG(wmbs) wmbs, AVG(util) util, 
AVG(cpu_id)/MAX(tc.node_count) cpu_id, 
AVG(cpu_sy)/MAX(tc.node_count) cpu_sy, 
AVG(cpu_us)/MAX(tc.node_count) cpu_us,
AVG(txkbs)/1024 txMBs, AVG(rxkbs)/1024 rxMBs,
AVG(swap_si) swap_si, AVG(swap_so) swap_so, AVG(mem_free/1024) mem_free_GB, AVG(mem_free/1024) / (48*2+96*6) * 100 mem_free_pct
FROM 
perf_test_case_v ttc
FULL OUTER JOIN
agg_iostat_v tio
ON ttc.case_instance_id  = tio.case_instance_id
FULL OUTER JOIN
agg_vmstat_v tvm
ON ttc.case_instance_id = tvm.case_instance_id
FULL OUTER JOIN
agg_sarstat_v tsar
ON ttc.case_instance_id = tsar.case_instance_id
FULL OUTER JOIN
(SELECT run_id, COUNT(DISTINCT node_id) node_count FROM vmstat GROUP BY run_id) tc
ON ttc.run_id = tc.run_id
GROUP BY 1,2,3,4,5,6;

------------------ CONCURRENCY

SELECT 
        COUNT(t1.case_instance_id) total_jobs,
        AVG(t1.elapsed_ms)/1000 elapsed_sec, 
        AVG(rmbs) rmbs, AVG(wmbs) wmbs,  --AVG(util) util, 
        AVG(cpu_id) cpu_id, AVG(cpu_sy) cpu_sy, AVG(cpu_us) cpu_us,
        AVG(txmbs) txmbs, AVG(rmbs) rmbs,
        AVG(swap_si) swap_si, AVG(swap_so) swap_so,
        AVG(mem_free_gb) mem_free_gb, AVG(mem_free_pct) mem_free_pct
FROM 
perf_test t0
LEFT OUTER JOIN 
perf_test_case t1
ON
t0.run_id = t1.run_id
AND
t0.start_tstamp <= t1.start_tstamp
AND
t0.start_tstamp + INTERVAL '2 hour' >=  t1.start_tstamp
LEFT OUTER JOIN 
agg_stat_seq_v t2
ON t1.run_id = t2.run_id
AND t1.case_instance_id = t2.case_instance_id
WHERE t0.run_id IN (1340726830170) 
