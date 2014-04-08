-- Sequential by suite, RUN_ID
SELECT CAST(REGEXP_REPLACE(tio.case_name,'-.*','') AS VARCHAR(30)) case_name,
SUM(elapsed_ms)/1000 elapsed_sec,
AVG(rmbs) rmbs, AVG(wmbs) wmbs, --AVG(util) util, 
AVG(cpu_id)/MAX(tc.node_count) cpu_id, 
AVG(cpu_sy)/MAX(tc.node_count) cpu_sy, 
AVG(cpu_us)/MAX(tc.node_count) cpu_us,
AVG(txkbs)/1024 txMBs, AVG(rxkbs)/1024 rxMBs,
AVG(swap_si) swap_si, AVG(swap_so) swap_so, AVG(mem_free/1024) mem_free_GB,
        AVG(mem_free) / ((48+96*7)*1024) * 100 mem_free_pct
FROM  
perf_test tt
FULL OUTER JOIN
perf_test_case ttc
    ON 
tt.run_id = ttc.run_id
FULL OUTER JOIN
agg_iostat tio
    ON 
tio.run_id = ttc.run_id
    AND 
tio.case_instance_id = ttc.case_instance_id
FULL OUTER JOIN
agg_vmstat tvm
    ON 
tio.run_id = tvm.run_id
    AND 
tio.case_instance_id = tvm.case_instance_id
FULL OUTER JOIN
agg_sarstat tsar
    ON 
tio.run_id = tsar.run_id
    AND 
tio.case_instance_id = tsar.case_instance_id
INNER JOIN (
SELECT run_id, COUNT(DISTINCT node_id) node_count 
FROM  vmstat 
GROUP  BY run_id) tc
    ON 
tio.run_id  = tc.run_id
WHERE tio.run_id IN (1341256444152) 
    AND ttc.case_name LIKE 'WL%'
 GROUP BY 1
ORDER  BY 1
LIMIT 100


select * from sarstat order by tstamp desc;

select * from perf_test order by run_id desc;
select * from perf_test_case where run_id in (select max(run_id) from perf_test) order by start_tstamp desc;

select * from iostat t0
inner join (select * from perf_test_case where run_id in (1340637936653)) t1 -- (select max(run_id) from perf_test) ) t1 --and case_name='S10-Q2') t1
on
t0.run_id = t1.run_id
and
t0.tstamp >= t1.start_tstamp
and
t0.tstamp <= t1.end_tstamp

select 'all', start_tstamp, end_tstamp from perf_test where run_id in (select max(run_id) from perf_test)
union all 
select case_name, start_tstamp, end_tstamp from perf_test_case where run_id in (select max(run_id) from perf_test)
order by 2

select count(*) from sarstat where run_id in (select max(run_id) from perf_test)
select max(run_id),min(tstamp) start_tstamp, max(tstamp) end_tstamp, 
-- device,

select *
from
perf_test t0
inner join
perf_test_case t1
on t0.run_id = t1.run_id
inner join
iostat t2
t1.run_id = t2.run_id
and
t1.tstamp >= t2.start_tstamp
and
t1.tstamp <= t2.end_tstamp


drop view stats_olap_last;
drop view stats_olap;

create view stats_olap as
select t0.run_id, t0.start_tstamp, t0.end_tstamp, t1.case_name, t1.thread_group_name, t1.response_bytes, t1.thread_id, t1.elapsed_ms --t2.device, t4.iface
,avg(t2.rmbs) rmbs, avg(t2.wmbs) wmbs
,avg(t3.procs_r) procs_r, avg(mem_free) mem_free, avg(cpu_us) cpu_us, avg(cpu_sy) cpu_sy, avg(cpu_id) cpu_id
,avg(rxkbs) rxkbs, avg(txkbs) txkbs
from
perf_test t0
inner join
perf_test_case t1
on t0.run_id = t1.run_id
inner join
iostat t2
on
t2.run_id = t1.run_id
and
t2.tstamp >= t1.start_tstamp
and
t2.tstamp <= t1.end_tstamp
inner join
vmstat t3
on
t3.run_id = t1.run_id
and
t3.tstamp >= t1.start_tstamp
and
t3.tstamp <= t1.end_tstamp
inner join
sarstat t4
on
t4.run_id = t1.run_id
and
t4.tstamp >= t1.start_tstamp
and
t4.tstamp <= t1.end_tstamp
where t4.iface='bond0'
group by t0.run_id, t0.start_tstamp, t0.end_tstamp, t1.case_name, t1.thread_group_name, t1.response_bytes, t1.thread_id, t1.elapsed_ms --,t2.device, t4.iface
;

create view stats_olap_last as
select *
from
stats_olap
where run_id in (select max(run_id) from perf_test)
;
