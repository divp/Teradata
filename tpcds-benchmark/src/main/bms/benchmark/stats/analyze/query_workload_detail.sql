SELECT  run_id, test_tag, case_name, job_count, EXTRACT(HOUR FROM runtime)*3600  + EXTRACT(MINUTE FROM runtime) * 60 + EXTRACT(seconds FROM runtime) runtime, avg_elapsed_sec, dev_elapsed_sec
FROM (
SELECT t31. run_id, t31.test_tag, t32. case_name, 
MAX(t32.end_tstamp)-MIN(t32.end_tstamp) runtime--, elapsed_ms 
,COUNT(*) job_count, AVG (t32. elapsed_ms/1000.0) avg_elapsed_sec, STDDEV(t32. elapsed_ms)/AVG (t32. elapsed_ms)/1000.0 dev_elapsed_sec
FROM  
perf_test t31
INNER JOIN
perf_test_case t32
    ON t31 .run_id = t32 .run_id
WHERE t31.run_id IN (1344443600250) -- replace with appropriate run ID
GROUP  BY 1,2,3
ORDER  BY 1,2,3
) tx