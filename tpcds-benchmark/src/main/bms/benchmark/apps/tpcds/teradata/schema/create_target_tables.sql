DATABASE tpcds1000g;

CREATE MULTISET TABLE inventory ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      inv_date_sk INTEGER NOT NULL,
      inv_item_sk INTEGER NOT NULL,
      inv_warehouse_sk INTEGER NOT NULL,
      inv_quantity_on_hand INTEGER)
PRIMARY INDEX ( inv_item_sk );


CREATE MULTISET TABLE ship_mode ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      sm_ship_mode_sk INTEGER NOT NULL,
      sm_ship_mode_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NU
LL,
      sm_type CHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      sm_code CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      sm_carrier CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      sm_contract CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( sm_ship_mode_sk );


CREATE MULTISET TABLE time_dim ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      t_time_sk INTEGER NOT NULL,
      t_time_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      t_time INTEGER,
      t_hour INTEGER,
      t_minute INTEGER,
      t_second INTEGER,
      t_am_pm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      t_shift CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      t_sub_shift CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      t_meal_time CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( t_time_sk );


CREATE MULTISET TABLE web_site ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      web_site_sk INTEGER NOT NULL,
      web_site_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      web_rec_start_date DATE FORMAT 'YY/MM/DD',
      web_rec_end_date DATE FORMAT 'YY/MM/DD',
      web_name VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_open_date_sk INTEGER,
      web_close_date_sk INTEGER,
      web_class VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_manager VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_mkt_id INTEGER,
      web_mkt_class VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_mkt_desc VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_market_manager VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,

      web_company_id INTEGER,
      web_company_name CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_street_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_street_name VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_street_type CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_suite_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_city VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_county VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_state CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_zip CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_country VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      web_gmt_offset DECIMAL(5,2),
      web_tax_percentage DECIMAL(5,2))
PRIMARY INDEX ( web_site_sk );


CREATE MULTISET TABLE household_demographics ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      hd_demo_sk INTEGER NOT NULL,
      hd_income_band_sk INTEGER,
      hd_buy_potential CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      hd_dep_count INTEGER,
      hd_vehicle_count INTEGER)
PRIMARY INDEX ( hd_demo_sk );


CREATE MULTISET TABLE store_returns_raw ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      sr_returned_date_sk INTEGER,
      sr_return_time_sk INTEGER,
      sr_item_sk INTEGER NOT NULL,
      sr_customer_sk INTEGER,
      sr_cdemo_sk INTEGER,
      sr_hdemo_sk INTEGER,
      sr_addr_sk INTEGER,
      sr_store_sk INTEGER,
      sr_reason_sk INTEGER,
      sr_ticket_number INTEGER NOT NULL,
      sr_return_quantity INTEGER,
      sr_return_amt DECIMAL(7,2),
      sr_return_tax DECIMAL(7,2),
      sr_return_amt_inc_tax DECIMAL(7,2),
      sr_fee DECIMAL(7,2),
      sr_return_ship_cost DECIMAL(7,2),
      sr_refunded_cash DECIMAL(7,2),
      sr_reversed_charge DECIMAL(7,2),
      sr_store_credit DECIMAL(7,2),
      sr_net_loss DECIMAL(7,2))
PRIMARY INDEX ( sr_item_sk );


CREATE MULTISET TABLE store ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      s_store_sk INTEGER NOT NULL,
      s_store_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      s_rec_start_date DATE FORMAT 'YY/MM/DD',
      s_rec_end_date DATE FORMAT 'YY/MM/DD',
      s_closed_date_sk INTEGER,
      s_store_name VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_number_employees INTEGER,
      s_floor_space INTEGER,
      s_hours CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_manager VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_market_id INTEGER,
      s_geography_class VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,

      s_market_desc VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_market_manager VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_division_id INTEGER,
      s_division_name VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_company_id INTEGER,
      s_company_name VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_street_number VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_street_name VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_street_type CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_suite_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_city VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_county VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_state CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_zip CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_country VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_gmt_offset DECIMAL(5,2),
      s_tax_precentage DECIMAL(5,2))
PRIMARY INDEX ( s_store_sk );


CREATE MULTISET TABLE call_center ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      cc_call_center_sk INTEGER NOT NULL,
      cc_call_center_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT 
NULL,
      cc_rec_start_date DATE FORMAT 'YY/MM/DD',
      cc_rec_end_date DATE FORMAT 'YY/MM/DD',
      cc_closed_date_sk INTEGER,
      cc_open_date_sk INTEGER,
      cc_name VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_class VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_employees INTEGER,
      cc_sq_ft INTEGER,
      cc_hours CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_manager VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_mkt_id INTEGER,
      cc_mkt_class CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_mkt_desc VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_market_manager VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_division INTEGER,
      cc_division_name VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_company INTEGER,
      cc_company_name CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_street_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_street_name VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_street_type CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_suite_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_city VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_county VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_state CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_zip CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_country VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      cc_gmt_offset DECIMAL(5,2),
      cc_tax_percentage DECIMAL(5,2))
UNIQUE PRIMARY INDEX ( cc_call_center_sk );


CREATE MULTISET TABLE warehouse ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      w_warehouse_sk INTEGER NOT NULL,
      w_warehouse_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NUL
L,
      w_warehouse_name VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_warehouse_sq_ft INTEGER,
      w_street_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_street_name VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_street_type CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_suite_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_city VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_county VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_state CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_zip CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_country VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      w_gmt_offset DECIMAL(5,2))
PRIMARY INDEX ( w_warehouse_sk );


CREATE MULTISET TABLE catalog_page ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      cp_catalog_page_sk INTEGER NOT NULL,
      cp_catalog_page_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT
 NULL,
      cp_start_date_sk INTEGER,
      cp_end_date_sk INTEGER,
      cp_department VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      cp_catalog_number INTEGER,
      cp_catalog_page_number INTEGER,
      cp_description VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      cp_type VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( cp_catalog_page_sk );


CREATE MULTISET TABLE item ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      i_item_sk INTEGER NOT NULL,
      i_item_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      i_rec_start_date DATE FORMAT 'YY/MM/DD',
      i_rec_end_date DATE FORMAT 'YY/MM/DD',
      i_item_desc VARCHAR(200) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_current_price DECIMAL(7,2),
      i_wholesale_cost DECIMAL(7,2),
      i_brand_id INTEGER,
      i_brand CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_class_id INTEGER,
      i_class CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_category_id INTEGER,
      i_category CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_manufact_id INTEGER,
      i_manufact CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_size CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_formulation CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_color CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_units CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_container CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_manager_id INTEGER,
      i_product_name CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( i_item_sk );


CREATE MULTISET TABLE web_page ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      wp_web_page_sk INTEGER NOT NULL,
      wp_web_page_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NUL
L,
      wp_rec_start_date DATE FORMAT 'YY/MM/DD',
      wp_rec_end_date DATE FORMAT 'YY/MM/DD',
      wp_creation_date_sk INTEGER,
      wp_access_date_sk INTEGER,
      wp_autogen_flag CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      wp_customer_sk INTEGER,
      wp_url VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      wp_type CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      wp_char_count INTEGER,
      wp_link_count INTEGER,
      wp_image_count INTEGER,
      wp_max_ad_count INTEGER)
PRIMARY INDEX ( wp_web_page_sk );


CREATE MULTISET TABLE catalog_returns ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      cr_returned_date_sk INTEGER,
      cr_returned_time_sk INTEGER,
      cr_item_sk INTEGER NOT NULL,
      cr_refunded_customer_sk INTEGER,
      cr_refunded_cdemo_sk INTEGER,
      cr_refunded_hdemo_sk INTEGER,
      cr_refunded_addr_sk INTEGER,
      cr_returning_customer_sk INTEGER,
      cr_returning_cdemo_sk INTEGER,
      cr_returning_hdemo_sk INTEGER,
      cr_returning_addr_sk INTEGER,
      cr_call_center_sk INTEGER,
      cr_catalog_page_sk INTEGER,
      cr_ship_mode_sk INTEGER,
      cr_warehouse_sk INTEGER,
      cr_reason_sk INTEGER,
      cr_order_number INTEGER NOT NULL,
      cr_return_quantity INTEGER,
      cr_return_amount DECIMAL(7,2),
      cr_return_tax DECIMAL(7,2),
      cr_return_amt_inc_tax DECIMAL(7,2),
      cr_fee DECIMAL(7,2),
      cr_return_ship_cost DECIMAL(7,2),
      cr_refunded_cash DECIMAL(7,2),
      cr_reversed_charge DECIMAL(7,2),
      cr_store_credit DECIMAL(7,2),
      cr_net_loss DECIMAL(7,2))
PRIMARY INDEX ( cr_item_sk ,cr_order_number );


CREATE MULTISET TABLE catalog_sales ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      cs_sold_date_sk INTEGER,
      cs_sold_time_sk INTEGER,
      cs_ship_date_sk INTEGER,
      cs_bill_customer_sk INTEGER,
      cs_bill_cdemo_sk INTEGER,
      cs_bill_hdemo_sk INTEGER,
      cs_bill_addr_sk INTEGER,
      cs_ship_customer_sk INTEGER,
      cs_ship_cdemo_sk INTEGER,
      cs_ship_hdemo_sk INTEGER,
      cs_ship_addr_sk INTEGER,
      cs_call_center_sk INTEGER,
      cs_catalog_page_sk INTEGER,
      cs_ship_mode_sk INTEGER,
      cs_warehouse_sk INTEGER,
      cs_item_sk INTEGER NOT NULL,
      cs_promo_sk INTEGER,
      cs_order_number INTEGER NOT NULL,
      cs_quantity INTEGER,
      cs_wholesale_cost DECIMAL(7,2),
      cs_list_price DECIMAL(7,2),
      cs_sales_price DECIMAL(7,2),
      cs_ext_discount_amt DECIMAL(7,2),
      cs_ext_sales_price DECIMAL(7,2),
      cs_ext_wholesale_cost DECIMAL(7,2),
      cs_ext_list_price DECIMAL(7,2),
      cs_ext_tax DECIMAL(7,2),
      cs_coupon_amt DECIMAL(7,2),
      cs_ext_ship_cost DECIMAL(7,2),
      cs_net_paid DECIMAL(7,2),
      cs_net_paid_inc_tax DECIMAL(7,2),
      cs_net_paid_inc_ship DECIMAL(7,2),
      cs_net_paid_inc_ship_tax DECIMAL(7,2),
      cs_net_profit DECIMAL(7,2))
NO PRIMARY INDEX 
PARTITION BY ( COLUMN ADD 10,RANGE_N(cs_sold_date_sk  BETWEEN 2450815  AND
 2452654  EACH 1 ,
 NO RANGE OR UNKNOWN) );


CREATE MULTISET TABLE customer ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      c_customer_sk INTEGER NOT NULL,
      c_customer_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL
,
      c_current_cdemo_sk INTEGER,
      c_current_hdemo_sk INTEGER,
      c_current_addr_sk INTEGER,
      c_first_shipto_date_sk INTEGER,
      c_first_sales_date_sk INTEGER,
      c_salutation CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      c_first_name CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      c_last_name CHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      c_preferred_cust_flag CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      c_birth_day INTEGER,
      c_birth_month INTEGER,
      c_birth_year INTEGER,
      c_birth_country VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      c_login CHAR(13) CHARACTER SET LATIN NOT CASESPECIFIC,
      c_email_address CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      c_last_review_date CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( c_customer_sk );


CREATE MULTISET TABLE date_dim ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      d_date_sk INTEGER NOT NULL,
      d_date_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      d_date DATE FORMAT 'YY/MM/DD',
      d_month_seq INTEGER,
      d_week_seq INTEGER,
      d_quarter_seq INTEGER,
      d_year INTEGER,
      d_dow INTEGER,
      d_moy INTEGER,
      d_dom INTEGER,
      d_qoy INTEGER,
      d_fy_year INTEGER,
      d_fy_quarter_seq INTEGER,
      d_fy_week_seq INTEGER,
      d_day_name CHAR(9) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_quarter_name CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_holiday CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_weekend CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_following_holiday CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_first_dom INTEGER,
      d_last_dom INTEGER,
      d_same_day_ly INTEGER,
      d_same_day_lq INTEGER,
      d_current_day CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_current_week CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_current_month CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_current_quarter CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      d_current_year CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( d_date_sk );


CREATE MULTISET TABLE income_band ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      ib_income_band_sk INTEGER NOT NULL,
      ib_lower_bound INTEGER,
      ib_upper_bound INTEGER)
PRIMARY INDEX ( ib_income_band_sk );


CREATE MULTISET TABLE store_returns ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      sr_returned_date_sk INTEGER,
      sr_return_time_sk INTEGER,
      sr_item_sk INTEGER NOT NULL,
      sr_customer_sk INTEGER,
      sr_cdemo_sk INTEGER,
      sr_hdemo_sk INTEGER,
      sr_addr_sk INTEGER,
      sr_store_sk INTEGER,
      sr_reason_sk INTEGER,
      sr_ticket_number INTEGER NOT NULL,
      sr_return_quantity INTEGER,
      sr_return_amt DECIMAL(7,2),
      sr_return_tax DECIMAL(7,2),
      sr_return_amt_inc_tax DECIMAL(7,2),
      sr_fee DECIMAL(7,2),
      sr_return_ship_cost DECIMAL(7,2),
      sr_refunded_cash DECIMAL(7,2),
      sr_reversed_charge DECIMAL(7,2),
      sr_store_credit DECIMAL(7,2),
      sr_net_loss DECIMAL(7,2))
PRIMARY INDEX ( sr_item_sk ,sr_ticket_number );


CREATE MULTISET TABLE customer_demographics ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      cd_demo_sk INTEGER NOT NULL,
      cd_gender CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      cd_marital_status CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      cd_education_status CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      cd_purchase_estimate INTEGER,
      cd_credit_rating CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      cd_dep_count INTEGER,
      cd_dep_employed_count INTEGER,
      cd_dep_college_count INTEGER)
PRIMARY INDEX ( cd_demo_sk );


CREATE MULTISET TABLE store_sales_raw ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      ss_sold_date_sk INTEGER,
      ss_sold_time_sk INTEGER,
      ss_item_sk INTEGER NOT NULL,
      ss_customer_sk INTEGER,
      ss_cdemo_sk INTEGER,
      ss_hdemo_sk INTEGER,
      ss_addr_sk INTEGER,
      ss_store_sk INTEGER,
      ss_promo_sk INTEGER,
      ss_ticket_number INTEGER NOT NULL,
      ss_quantity INTEGER,
      ss_wholesale_cost DECIMAL(7,2),
      ss_list_price DECIMAL(7,2),
      ss_sales_price DECIMAL(7,2),
      ss_ext_discount_amt DECIMAL(7,2),
      ss_ext_sales_price DECIMAL(7,2),
      ss_ext_wholesale_cost DECIMAL(7,2),
      ss_ext_list_price DECIMAL(7,2),
      ss_ext_tax DECIMAL(7,2),
      ss_coupon_amt DECIMAL(7,2),
      ss_net_paid DECIMAL(7,2),
      ss_net_paid_inc_tax DECIMAL(7,2),
      ss_net_profit DECIMAL(7,2))
PRIMARY INDEX ( ss_item_sk );


CREATE MULTISET TABLE web_returns ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      wr_returned_date_sk INTEGER,
      wr_returned_time_sk INTEGER,
      wr_item_sk INTEGER NOT NULL,
      wr_refunded_customer_sk INTEGER,
      wr_refunded_cdemo_sk INTEGER,
      wr_refunded_hdemo_sk INTEGER,
      wr_refunded_addr_sk INTEGER,
      wr_returning_customer_sk INTEGER,
      wr_returning_cdemo_sk INTEGER,
      wr_returning_hdemo_sk INTEGER,
      wr_returning_addr_sk INTEGER,
      wr_web_page_sk INTEGER,
      wr_reason_sk INTEGER,
      wr_order_number INTEGER NOT NULL,
      wr_return_quantity INTEGER,
      wr_return_amt DECIMAL(7,2),
      wr_return_tax DECIMAL(7,2),
      wr_return_amt_inc_tax DECIMAL(7,2),
      wr_fee DECIMAL(7,2),
      wr_return_ship_cost DECIMAL(7,2),
      wr_refunded_cash DECIMAL(7,2),
      wr_reversed_charge DECIMAL(7,2),
      wr_account_credit DECIMAL(7,2),
      wr_net_loss DECIMAL(7,2))
PRIMARY INDEX ( wr_item_sk ,wr_order_number );


CREATE MULTISET TABLE customer_address ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      ca_address_sk INTEGER NOT NULL,
      ca_address_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL
,
      ca_street_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_street_name VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_street_type CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_suite_number CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_city VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_county VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_state CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_zip CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_country VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      ca_gmt_offset DECIMAL(5,2),
      ca_location_type CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( ca_address_sk );


CREATE MULTISET TABLE reason ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      r_reason_sk INTEGER NOT NULL,
      r_reason_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      r_reason_desc VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( r_reason_sk );


CREATE MULTISET TABLE store_sales ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      ss_sold_date_sk INTEGER,
      ss_sold_time_sk INTEGER,
      ss_item_sk INTEGER NOT NULL,
      ss_customer_sk INTEGER,
      ss_cdemo_sk INTEGER,
      ss_hdemo_sk INTEGER,
      ss_addr_sk INTEGER,
      ss_store_sk INTEGER,
      ss_promo_sk INTEGER,
      ss_ticket_number INTEGER NOT NULL,
      ss_quantity INTEGER,
      ss_wholesale_cost DECIMAL(7,2),
      ss_list_price DECIMAL(7,2),
      ss_sales_price DECIMAL(7,2),
      ss_ext_discount_amt DECIMAL(7,2),
      ss_ext_sales_price DECIMAL(7,2),
      ss_ext_wholesale_cost DECIMAL(7,2),
      ss_ext_list_price DECIMAL(7,2),
      ss_ext_tax DECIMAL(7,2),
      ss_coupon_amt DECIMAL(7,2),
      ss_net_paid DECIMAL(7,2),
      ss_net_paid_inc_tax DECIMAL(7,2),
      ss_net_profit DECIMAL(7,2), 
FOREIGN KEY ( ss_sold_date_sk ) REFERENCES WITH NO CHECK OPTION tpcds1000g
.date_dim ( d_date_sk ))
NO PRIMARY INDEX 
PARTITION BY ( COLUMN ADD 10,RANGE_N(ss_sold_date_sk  BETWEEN 2450816  AND
 2452642  EACH 1 ,
 NO RANGE OR UNKNOWN) );


CREATE MULTISET TABLE promotion ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      p_promo_sk INTEGER NOT NULL,
      p_promo_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      p_start_date_sk INTEGER,
      p_end_date_sk INTEGER,
      p_item_sk INTEGER,
      p_cost DECIMAL(15,2),
      p_response_target INTEGER,
      p_promo_name CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_dmail CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_email CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_catalog CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_tv CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_radio CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_press CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_event CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_demo CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_channel_details VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,

      p_purpose CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      p_discount_active CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( p_promo_sk );


CREATE MULTISET TABLE web_sales ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      ws_sold_date_sk INTEGER,
      ws_sold_time_sk INTEGER,
      ws_ship_date_sk INTEGER,
      ws_item_sk INTEGER NOT NULL,
      ws_bill_customer_sk INTEGER,
      ws_bill_cdemo_sk INTEGER,
      ws_bill_hdemo_sk INTEGER,
      ws_bill_addr_sk INTEGER,
      ws_ship_customer_sk INTEGER,
      ws_ship_cdemo_sk INTEGER,
      ws_ship_hdemo_sk INTEGER,
      ws_ship_addr_sk INTEGER,
      ws_web_page_sk INTEGER,
      ws_web_site_sk INTEGER,
      ws_ship_mode_sk INTEGER,
      ws_warehouse_sk INTEGER,
      ws_promo_sk INTEGER,
      ws_order_number INTEGER NOT NULL,
      ws_quantity INTEGER,
      ws_wholesale_cost DECIMAL(7,2),
      ws_list_price DECIMAL(7,2),
      ws_sales_price DECIMAL(7,2),
      ws_ext_discount_amt DECIMAL(7,2),
      ws_ext_sales_price DECIMAL(7,2),
      ws_ext_wholesale_cost DECIMAL(7,2),
      ws_ext_list_price DECIMAL(7,2),
      ws_ext_tax DECIMAL(7,2),
      ws_coupon_amt DECIMAL(7,2),
      ws_ext_ship_cost DECIMAL(7,2),
      ws_net_paid DECIMAL(7,2),
      ws_net_paid_inc_tax DECIMAL(7,2),
      ws_net_paid_inc_ship DECIMAL(7,2),
      ws_net_paid_inc_ship_tax DECIMAL(7,2),
      ws_net_profit DECIMAL(7,2))
NO PRIMARY INDEX 
PARTITION BY ( COLUMN ADD 10,RANGE_N(ws_sold_date_sk  BETWEEN 2450816  AND
 2452642  EACH 1 ,
 NO RANGE OR UNKNOWN) );

