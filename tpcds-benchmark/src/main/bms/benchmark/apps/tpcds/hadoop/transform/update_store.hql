 
DROP TABLE IF EXISTS store_new;
CREATE TABLE store_new LIKE store;

INSERT INTO TABLE store_new
    -- Save ETL view data in temporary table (required to preserve state before update step below)
    SELECT 
        s_store_sk
        ,s_store_id
        ,s_rec_start_date
        ,s_rec_end_date
        ,s_closed_date_sk
        ,s_store_name
        ,s_number_employees
        ,s_floor_space
        ,s_hours
        ,s_manager
        ,s_market_id
        ,s_geography_class
        ,s_market_desc
        ,s_market_manager
        ,s_division_id
        ,s_division_name
        ,s_company_id
        ,s_company_name
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
        ,s_country
        ,s_gmt_offset
        ,s_tax_percentage
    FROM storv ;


-- update update date
DROP TABLE IF EXISTS store_upd;
CREATE TABLE store_upd LIKE store;

-- EXPLAIN
INSERT INTO TABLE store_upd
    -- update end-date
    SELECT 
         s.s_store_sk
        ,s.s_store_id
        ,s.s_rec_start_date
        ,CAST(to_date(FROM_UNIXTIME(UNIX_TIMESTAMP()-1*24*60*60)) as DATE) AS s_rec_end_date
        ,s.s_closed_date_sk
        ,s.s_store_name
        ,s.s_number_employees
        ,s.s_floor_space
        ,s.s_hours
        ,s.s_manager
        ,s.s_market_id
        ,s.s_geography_class
        ,s.s_market_desc
        ,s.s_market_manager
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
        ,s.s_tax_percentage
    FROM store AS s
    LEFT SEMI JOIN storv AS sv ON ( s.s_store_id = sv.s_store_id )
    WHERE 
      s.s_rec_end_date IS NULL
