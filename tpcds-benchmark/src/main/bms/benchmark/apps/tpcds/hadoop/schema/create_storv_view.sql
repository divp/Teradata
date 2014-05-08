USE orc_tpcds1000g;

DROP VIEW IF EXISTS storv;

CREATE VIEW storv AS
SELECT 
    -- Get next surrogate key
    MAX(s_store_sk) OVER (ORDER BY 1) + 
        ROW_NUMBER() OVER (ORDER BY 1) s_store_sk
    ,stor_store_id s_store_id
    ,CAST(to_date(FROM_UNIXTIME(UNIX_TIMESTAMP())) as DATE) s_rec_start_date
    ,CAST(NULL as DATE) s_rec_end_date
    ,d1.d_date_sk s_closed_date_sk
    ,s_s.stor_name s_store_name
    ,s_s.stor_employees s_number_employees
    ,s_s.stor_floor_space s_floor_space
    ,s_s.stor_hours s_hours
    ,s_s.stor_store_manager s_manager
    ,s_s.stor_market_id s_market_id
    ,s_s.stor_geography_class s_geography_class
    ,s.s_market_desc
    ,s_s.stor_market_manager s_market_manager
    ,s.s_division_id
    ,s.s_division_name
    ,s.s_company_id
    ,s.s_company_name
    ,s.s_street_number
    ,s.s_street_name
    ,s.s_street_type
    ,s.s_suite_number
    ,s.s_city
    ,s.s_county
    ,s.s_state
    ,s.s_zip
    ,s.s_country
    ,s.s_gmt_offset
    ,s_s.stor_tax_percentage s_tax_percentage
FROM  raw_ingest_sf1000.s_store AS s_s
  LEFT OUTER JOIN store AS s
    ON (s_s.stor_store_id = s.s_store_id 
    AND (s.s_rec_end_date IS NULL ) )
  LEFT OUTER JOIN date_dim d1 
    ON   (s_s.stor_closed_date = d1.d_date AND s_s.stor_closed_date != '')
    ;
