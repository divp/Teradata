SELECT t1. run_id, t1. node_id,  
AVG(rmbs ) rmbs, AVG(wmbs ) wmbs,
AVG(cpu_id ) cpu_id, AVG(cpu_sy ) cpu_sy, AVG(cpu_us ) cpu_us,
AVG(txkbs *8)/ 1024.0 txmbs , AVG( rxkbs*8 )/1024.0 rxmbs,
SUM(mem_free_gb ) mem_free_gb,
SUM(mem_free_gb )*1.0/( 48*2+96 *6) * 100 mem_free_pct
FROM (
SELECT run_id, node_id, tstamp, SUM (rmbs) rmbs, SUM (wmbs) wmbs, AVG (avgrqsz) avgrqsz, AVG (avgqusz) avgqusz
FROM iostat
GROUP BY run_id, node_id, tstamp
) t0
FULL OUTER JOIN (
SELECT run_id, node_id, tstamp,
AVG(cpu_id ) cpu_id,
AVG(cpu_sy ) cpu_sy,
AVG(cpu_us ) cpu_us,
SUM(mem_free *(1000/ 1024^3 )) mem_free_gb
FROM vmstat
GROUP BY run_id, node_id, tstamp
) t1
ON
t0.run_id = t1. run_id
AND
t0.tstamp = t1. tstamp
AND
t0.node_id = t1. node_id
FULL OUTER JOIN (
SELECT run_id, node_id, tstamp,
AVG(rxkbs ) rxkbs,
AVG(txkbs ) txkbs
FROM sarstat
WHERE iface= 'byn0'
GROUP BY run_id, node_id, tstamp
) t2
ON
t1.run_id = t2. run_id
AND
t1.tstamp = t2. tstamp
AND
t1.node_id = t2. node_id
GROUP BY 1,2
