
--
-- create a query/view to get most recent row from 'store'
--

DROP TABLE IF EXISTS store_next;
CREATE TABLE store_next LIKE store;

-- EXPLAIN
INSERT INTO TABLE store_next
SELECT  
s_store_sk,
s_store_id,
s_rec_start_date,
s_rec_end_date          ,
s_closed_date_sk        ,
s_store_name            ,
s_number_employees      ,
s_floor_space           ,
s_hours                 ,
s_manager               ,
s_market_id             ,
s_geography_class       ,
s_market_desc           ,
s_market_manager        ,
s_division_id           ,
s_division_name         ,
s_company_id            ,
s_company_name          ,
s_street_number         ,
s_street_name           ,
s_street_type           ,
s_suite_number          ,
s_city                  ,
s_county                ,
s_state                 ,
s_zip                   ,
s_country               ,
s_gmt_offset            ,
s_tax_percentage
from (
SELECT *, ROW_NUMBER() OVER(PARTITION BY s_store_sk ORDER BY tbl DESC)  r_num
FROM
(
        SELECT 3 as tbl, * FROM store_new
          UNION ALL
        SELECT 2 as tbl, * FROM store_upd
          UNION ALL
        SELECT 1 as tbl, * FROM store
) sv 
) x
where x.r_num = 1;
;


-- swap tables
ALTER TABLE store RENAME TO store_prev;
ALTER TABLE store_next RENAME TO store;

SELECT COUNT(*) FROM store;
