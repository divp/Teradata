#!/bin/bash

set -o nounset

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

log=$(mktemp /tmp/$(basename $0).log.XXXXXXXXXX)
log_info "Full detail log: $log"

cat <<EOF >/dev/null
for every row v in view V
   begin transaction // minimal transaction boundary
       if there is a row d in table D where the business keys of v and d are equal
     get the row d of the dimension table
                      where the value of rec_end_date is NULL
     update rec_end_date of d with current date minus one day
     update rec_start_date of v with current date
   end-if 
   generate next primary key value pkv of D
   insert v into D including pkv as primary key and NULL as rec_end_date
   end transaction
end-for

	s_store_sk	s_store_id	s_rec_start_date	s_rec_end_date	s_closed_date_sk	s_store_name	s_number_employees	s_floor_space	s_hours	s_manager	s_market_id	s_geography_class	s_market_desc	s_market_manager	s_division_id	s_division_name	s_company_id	s_company_name	s_street_number	s_street_name	s_street_type	s_suite_number	s_city	s_county	s_state	s_zip	s_country	s_gmt_offset	s_tax_percentage
1	1,003	AAAAAAAACAAAAAAA	2014-04-15	<NULL>	2,451,189	able                                              	245	5,250,760	8AM-4PM             	William Ward                            	2	Unknown                                                                                             	Impossible, true arms can treat constant, complete w	Charles Bartley                         	1	Unknown	1	Unknown	877	Park Laurel	Road           	Suite T   	Mount Pleasant	Gage County	NE	61933     	United States	-6.00	0.03
EOF


log_info "Loading store table"
bteq_output=$(mktemp)
bteq <<EOF > $bteq_output
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};

    -- Test only: clear and restore store table from backup
    --DELETE FROM store;
    --INSERT INTO store SELECT * FROM _bak_04150923_store;
    
    SELECT 1 FROM dbc.TablesV 
    WHERE databaseName='${BMS_TERADATA_DBNAME_ETL1}' 
    AND tableKind='T'
    AND tableName='storv_tmp';
    .IF activitycount=0 THEN GOTO CREATE_TABLE
    DROP TABLE storv_tmp;
    .LABEL CREATE_TABLE
    
    CREATE TABLE storv_tmp AS (
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
    FROM storv) WITH DATA;
    
    UPDATE store
    SET 
        s_rec_end_date = CURRENT_DATE - 1
    WHERE  s_rec_end_date IS NULL
    AND s_store_id IN (SELECT s_store_id FROM storv);
    
    INSERT INTO store (
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
    )
    SELECT *
    FROM storv_tmp;

    .LOGOFF;
    .EXIT;
EOF


