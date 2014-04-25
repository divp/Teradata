use orc_tpcds1000g;

INSERT OVERWRITE TABLE s_purchase
 SELECT * FROM raw_ingest_sf1000.s_purchase
;

INSERT OVERWRITE TABLE s_purchase_lineitem
 SELECT * FROM raw_ingest_sf1000.s_purchase_lineitem
;
