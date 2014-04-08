RUN_ID=1340726830170

SELECT AVG(t3.total_jobs) total_jobs, AVG(t3.avg_elapsed_ms)/1000.0 avg_elapsed_sec, 
AVG(rmbs) rmbs, AVG(wmbs) wmbs, 
AVG(cpu_id) cpu_id, AVG(cpu_sy) cpu_sy, AVG(cpu_us) cpu_us, 
AVG(txkbs*8)/1024.0 txmbs, AVG(rxkbs*8)/1024.0 rxmbs,
SUM(mem_free_gb) mem_free_gb,
SUM(mem_free_gb)*1.0/(48*2+96*6) * 100 mem_free_pct
FROM (
SELECT run_id, tstamp, SUM(rmbs) rmbs, SUM(wmbs) wmbs, AVG(avgrqsz) avgrqsz, AVG(avgqusz) avgqusz 
FROM iostat 
GROUP BY run_id, tstamp
) t0
FULL OUTER JOIN (
SELECT run_id, tstamp,
AVG(cpu_id) cpu_id, 
AVG(cpu_sy) cpu_sy, 
AVG(cpu_us) cpu_us,
SUM(mem_free*(1000/1024^3)) mem_free_gb
FROM vmstat 
GROUP BY run_id, tstamp
) t1
ON
t0.run_id = t1.run_id
AND
t0.tstamp = t1.tstamp
FULL OUTER JOIN (
SELECT run_id, tstamp, 
AVG(rxkbs) rxkbs, 
AVG(txkbs) txkbs
FROM sarstat
WHERE iface='bond0'
GROUP BY run_id, tstamp
) t2
ON
t1.run_id = t2.run_id
AND
t1.tstamp = t2.tstamp
RIGHT OUTER JOIN (
SELECT t31.run_id, t31.start_tstamp, t31.start_tstamp + INTERVAL '2 hour' end_tstamp, COUNT(t32.case_instance_id) total_jobs, AVG(t32.elapsed_ms) avg_elapsed_ms
FROM
perf_test t31
INNER JOIN
perf_test_case t32
ON t31.run_id = t32.run_id
WHERE t32.start_tstamp >= t31.start_tstamp AND t32.end_tstamp <= t31.start_tstamp + INTERVAL '2 hour'
GROUP BY 1,2,3
) t3
ON t3.run_id = t2.run_id
WHERE t0.run_id IN (${RUN_ID})
AND t2.tstamp BETWEEN t3.start_tstamp AND t3.end_tstamp
ORDER BY 1,2