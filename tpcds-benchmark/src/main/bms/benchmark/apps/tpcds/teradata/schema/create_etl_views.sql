DROP VIEW storv;

CREATE VIEW storv AS
SELECT  NEXT VALUE FOR store_seq s_store_sk
      ,stor_store_id s_store_id
      ,CURRENT_DATE s_rec_start_date
      ,CAST(NULL AS DATE) s_rec_end_date
      ,d1.d_date_sk s_closed_date_sk
      ,stor_name s_store_name
      ,stor_employees s_number_employees
      ,stor_floor_space s_floor_space
      ,stor_hours s_hours
      ,stor_store_manager s_manager
      ,stor_market_id s_market_id
      ,stor_geography_class s_geography_class
      ,s_market_desc
      ,stor_market_manager s_market_manager
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
      ,stor_tax_percentage s_tax_percentage
FROM  s_store
  LEFT OUTER JOIN store
    ON (stor_store_id = s_store_id 
    AND s_rec_end_date IS NULL)
  LEFT OUTER JOIN date_dim d1 
    ON   (CAST(stor_closed_date AS DATE)= d1.d_date);

DROP VIEW itemv;

CREATE VIEW itemv AS
SELECT  
    item_item_id i_item_id
    ,CURRENT_DATE i_rec_start_date
    ,CAST(NULL AS DATE) i_rec_end_date
    ,item_item_description i_item_desc
    ,item_list_price i_current_price
    ,item_wholesale_cost i_wholesalecost
    ,i_brand_id
    ,i_brand
    ,i_class_id
    ,i_class
    ,i_category_id
    ,i_category
    ,i_manufact_id
    ,i_manufact
    ,item_size i_size
    ,item_formulation i_formulation
    ,item_color i_color
    ,item_units i_units
    ,item_container i_container
    ,item_manager_id i_manager
    ,i_product_name
FROM s_item
LEFT OUTER JOIN item 
    ON   (item_item_id = i_item_id 
    AND i_rec_end_date IS NULL);

DROP VIEW cadrv;

CREATE VIEW cadrv AS
SELECT  ca_address_sk
      ,ca_address_id
      ,cust_street_number ca_street_number
      ,rtrim(cust_street_name1) || ' ' || rtrim(cust_street_name2) ca_street_name
      ,cust_street_type ca_street_type
      ,cust_suite_number ca_suite_number
      ,cust_city ca_city
      ,cust_county ca_county
      ,cust_state ca_state
      ,cust_zip ca_zip
      ,cust_country ca_country
      ,zipg_gmt_offset ca_gmt_offset
      ,cust_loc_type ca_location_type
FROM s_customer,
     customer customer,
     customer_address cat,
     s_zip_to_gmt
WHERE  cust_customer_id = c_customer_id
  AND c_current_addr_sk = ca_address_sk
  AND cust_zip = zipg_zip;

DROP VIEW custv;

CREATE VIEW custv AS
SELECT    c_customer_sk
        ,cust_customer_id c_customer_id
        ,cd_demo_sk c_current_cdemo_sk
        ,hd_demo_sk c_current_hdemo_sk
        ,ca_address_sk c_current_addr_sk
        ,d1.d_date_sk c_first_shipto_date_sk
        ,d2.d_date_sk c_first_sales_date_sk
        ,cust_salutation c_salutation
        ,cust_first_name c_first_name
        ,cust_last_name c_last_name
        ,cust_preffered_flag c_preferred_cust_flag
        ,EXTRACT(DAY FROM CAST(cust_birth_date AS DATE)) c_birth_day
        ,EXTRACT(MONTH FROM CAST(cust_birth_date AS DATE)) c_birth_month
        ,EXTRACT(YEAR FROM CAST(cust_birth_date AS DATE)) c_birth_year
        ,cust_birth_country c_birth_country
        ,cust_login_id c_login
        ,cust_email_address c_email_address
        ,cust_last_review_date c_last_review_date
FROM s_customer
LEFT OUTER JOIN customer 
    ON   (c_customer_id=cust_customer_id) 
LEFT OUTER JOIN customer_address 
    ON   (c_current_addr_sk = ca_address_sk)
        ,customer_demographics
        ,household_demographics
        ,income_band ib
        ,date_dim d1
        ,date_dim d2
WHERE    
        cust_gender = cd_gender
        AND cust_marital_status = cd_marital_status
        AND cust_educ_status = cd_education_status
        AND cust_purch_est = cd_purchase_estimate
        AND cust_credit_rating = cd_credit_rating
        AND cust_depend_cnt = cd_dep_count
        AND cust_depend_emp_cnt = cd_dep_employed_count
        AND cust_depend_college_cnt = cd_dep_college_count
        AND round(cust_annual_income, 0) BETWEEN ib.ib_lower_bound AND ib.ib_upper_bound
        AND hd_income_band_sk = ib_income_band_sk
        AND cust_buy_potential = hd_buy_potential
        AND cust_depend_cnt= hd_dep_count
        AND cust_vehicle_cnt = hd_vehicle_count
        AND d1.d_date = cust_first_purchase_date
        AND d2.d_date = cust_first_shipto_date;
        
DROP VIEW wrhsv;

CREATE VIEW wrhsv AS
SELECT  w_warehouse_sk
       ,wrhs_warehouse_id w_warehouse_id
       ,wrhs_warehouse_desc w_warehouse_name
       ,wrhs_warehouse_sq_ft w_warehouse_sq_ft
       ,w_street_number
       ,w_street_name
       ,w_street_type
       ,w_suite_number
       ,w_city
       ,w_county
       ,w_state
       ,w_zip    
       ,w_country
       ,w_gmt_offset
FROM s_warehouse,
        warehouse
WHERE    wrhs_warehouse_id = w_warehouse_id;

DROP VIEW ccv;

CREATE VIEW ccv AS 
SELECT   NEXT VALUE FOR cc_seq cc_call_center_sk
        ,call_center_id cc_call_center_id
        ,CURRENT_DATE cc_rec_start_date
        ,CAST(NULL AS DATE) cc_rec_end_date
        ,d1.d_date_sk cc_closed_date_sk
        ,d2.d_date_sk cc_open_date_sk
        ,call_center_name cc_name
        ,call_center_class cc_class
        ,call_center_employees cc_employees
        ,call_center_sq_ft cc_sq_ft
        ,call_center_hours cc_hours
        ,call_center_manager cc_manager
        ,cc_mkt_id
        ,cc_mkt_class
        ,cc_mkt_desc
        ,cc_market_manager
        ,cc_division
        ,cc_division_name
        ,cc_company
        ,cc_company_name
        ,cc_street_number,cc_street_name,cc_street_type,cc_suite_number,
        cc_city
        ,cc_county,cc_state,cc_zip
        ,cc_country
        ,cc_gmt_offset
        ,call_center_tax_percentage cc_tax_percentage
FROM s_call_center
LEFT OUTER JOIN date_dim d2 
    ON   d2.d_date = CAST(call_closed_date AS DATE)
LEFT OUTER JOIN date_dim d1 
    ON   d1.d_date = CAST(call_open_date AS DATE)
LEFT OUTER JOIN call_center 
    ON   (call_center_id = cc_call_center_id 
    AND cc_rec_end_date IS NULL);

DROP VIEW catv;

CREATE VIEW catv AS
SELECT  cp_catalog_page_sk
      ,scp.cpag_id cp_catalog_page_id
      ,startd.d_date_sk cp_start_date_sk
      ,endd.d_date_sk cp_end_date_sk
      ,cpag_department cp_department
      ,cpag_catalog_number cp_catalog_number
      ,cpag_catalog_page_number cp_catalog_page_number
      ,scp.cpag_description cp_description
      ,scp.cpag_type cp_type   
FROM s_catalog_page scp
INNER JOIN date_dim startd 
    ON   (scp.cpag_start_date = startd.d_date)
INNER JOIN date_dim endd 
    ON   (scp.cpag_end_date = endd.d_date)
INNER JOIN catalog_page cp 
    ON   (scp.cpag_id = cp.cp_catalog_page_id);

DROP VIEW promv;

CREATE VIEW promv AS
SELECT   p_promo_sk
       ,prom_promotion_id p_promo_id
       ,d1.d_date_sk p_start_date_sk
       ,d2.d_date_sk p_end_date_sk
       ,p_item_sk
       ,prom_cost p_cost
       ,prom_response_target p_response_target
       ,prom_promotion_name p_promo_name
       ,prom_channel_dmail p_channel_dmail
       ,prom_channel_email p_channel_email
       ,prom_channel_catalog p_channel_catalog
       ,prom_channel_tv p_channel_tv
       ,prom_channel_radio p_channel_radio
       ,prom_channel_press p_channel_press
       ,prom_channel_event p_channel_event
       ,prom_channel_demo p_channel_demo
       ,prom_channel_details p_channel_details
       ,prom_purpose p_purpose
       ,prom_discount_active p_discount_active
FROM s_promotion
LEFT OUTER JOIN date_dim d1 
    ON   (prom_start_date = d1.d_date)
LEFT OUTER JOIN date_dim d2 
    ON   (prom_end_date = d2.d_date)
LEFT OUTER JOIN promotion 
    ON   (prom_promotion_id = p_promo_id);

DROP VIEW websv;

CREATE VIEW websv AS
SELECT NEXT VALUE FOR web_seq web_site_sk
      ,wsit_web_site_id web_site_id
      ,CURRENT_DATE web_rec_start_date
      ,CAST(NULL AS DATE) web_rec_end_date
      ,wsit_site_name web_name
      ,d1.d_date_sk web_open_date_sk
      ,d2.d_date_sk web_close_date_sk
      ,wsit_site_class web_class
      ,wsit_site_manager web_manager
      ,web_mkt_id 
      ,web_mkt_class
      ,web_mkt_desc
      ,web_market_manager
      ,web_company_id
      ,web_company_name
      ,web_street_number 
      ,web_street_name
      ,web_street_type 
      ,web_suite_number
      ,web_city 
      ,web_county 
      ,web_state
      ,web_zip
      ,web_country 
      ,web_gmt_offset
      ,wsit_tax_percentage web_tax_percentage
FROM  s_web_site
LEFT OUTER JOIN date_dim d1 
    ON   (d1.d_date = CAST(wsit_open_date AS DATE))
LEFT OUTER JOIN date_dim d2 
    ON   (d2.d_date = CAST(wsit_closed_date AS DATE))
LEFT OUTER JOIN web_site 
    ON   (web_site_id = wsit_web_site_id 
    AND web_rec_end_date IS NULL);

DROP VIEW webv;

CREATE VIEW webv AS
SELECT  NEXT VALUE FOR wp_seq wp_web_page_sk
      ,wpag_web_page_id wp_web_page_id
      ,CURRENT_DATE wp_rec_start_date
      ,CAST(NULL AS DATE) wp_rec_end_date
      ,d1.d_date_sk wp_creation_date_sk
      ,d2.d_date_sk wp_access_date_sk
      ,wpag_autogen_flag wp_autogen_flag
      ,wp_customer_sk
      ,wpag_url wp_url
      ,wpag_type wp_type 
      ,wpag_char_cnt wp_char_count
      ,wpag_link_cnt wp_link_count
      ,wpag_image_cnt wp_image_count  
      ,wpag_max_ad_cnt wp_max_ad_count
FROM  s_web_page 
LEFT OUTER JOIN date_dim d1 
    ON   CAST(wpag_create_date AS DATE) = d1.d_date
LEFT OUTER JOIN date_dim d2 
    ON   CAST(wpag_access_date AS DATE) = d2.d_date
LEFT OUTER JOIN web_page 
    ON   (wpag_web_page_id = wp_web_page_id 
    AND wp_rec_end_date IS NULL);

DROP VIEW ssv;

CREATE VIEW ssv AS
SELECT   d_date_sk ss_sold_date_sk, 
        t_time_sk ss_sold_time_sk, 
        i_item_sk ss_item_sk, 
        c_customer_sk ss_customer_sk, 
        c_current_cdemo_sk ss_cdemo_sk, 
        c_current_hdemo_sk ss_hdemo_sk,
        c_current_addr_sk ss_addr_sk,
        s_store_sk ss_store_sk, 
        p_promo_sk ss_promo_sk,
        purc_purchase_id ss_ticket_number, 
        plin_quantity ss_quantity, 
        i_wholesale_cost ss_wholesale_cost, 
        i_current_price ss_list_price,
        plin_sale_price ss_sales_price,
        (i_current_price-plin_sale_price)*plin_quantity ss_ext_discount_amt,
        plin_sale_price * plin_quantity ss_ext_sales_price,
        i_wholesale_cost * plin_quantity ss_ext_wholesale_cost, 
        i_current_price * plin_quantity ss_ext_list_price, 
        i_current_price * s_tax_precentage ss_ext_tax, 
        plin_coupon_amt ss_coupon_amt,
        (plin_sale_price * plin_quantity)-plin_coupon_amt ss_net_paid,
        ((plin_sale_price * plin_quantity)-plin_coupon_amt)*(1+s_tax_precentage) ss_net_paid_inc_tax,
        ((plin_sale_price * plin_quantity)-plin_coupon_amt)-(plin_quantity*i_wholesale_cost) ss_net_profit
FROM s_purchase 
LEFT OUTER JOIN customer 
    ON   (purc_customer_id = c_customer_id) 
LEFT OUTER JOIN store 
    ON   (purc_store_id = s_store_id)
LEFT OUTER JOIN date_dim 
    ON   (CAST(purc_purchase_date AS DATE) = d_date)
LEFT OUTER JOIN time_dim 
    ON   (PURC_PURCHASE_TIME = t_time)
JOIN s_purchase_lineitem 
    ON   (purc_purchase_id = plin_purchase_id)
LEFT OUTER JOIN promotion 
    ON   plin_promotion_id = p_promo_id
LEFT OUTER JOIN item 
    ON   plin_item_id = i_item_id
WHERE    purc_purchase_id = plin_purchase_id
    AND i_rec_end_date IS NULL
    AND s_rec_end_date IS NULL;

DROP VIEW srv;

CREATE VIEW srv AS
SELECT  d_date_sk sr_returned_date_sk
      ,t_time_sk sr_return_time_sk
      ,i_item_sk sr_item_sk
      ,c_customer_sk sr_customer_sk
      ,c_current_cdemo_sk sr_cdemo_sk
      ,c_current_hdemo_sk sr_hdemo_sk
      ,c_current_addr_sk sr_addr_sk
      ,s_store_sk sr_store_sk
      ,r_reason_sk sr_reason_sk
      ,sret_ticket_number sr_ticket_number
      ,sret_return_qty sr_return_quantity
      ,sret_return_amt sr_return_amt
      ,sret_return_tax sr_return_tax
      ,sret_return_amt + sret_return_tax sr_return_amt_inc_tax
      ,sret_return_fee sr_fee
      ,sret_return_ship_cost sr_return_ship_cost
      ,sret_refunded_cash sr_refunded_cash
      ,sret_reversed_charge sr_reversed_charge
      ,sret_store_credit sr_store_credit
      ,sret_return_amt+sret_return_tax+sret_return_fee
       -sret_refunded_cash-sret_reversed_charge-sret_store_credit sr_net_loss
FROM s_store_returns 
LEFT OUTER JOIN date_dim 
  ON (CAST(sret_return_date AS DATE) = d_date)
LEFT OUTER JOIN time_dim 
  ON (( CAST(SUBSTR(sret_return_time,1,2) AS INTEGER)*3600
       +CAST(SUBSTR(sret_return_time,4,2) AS INTEGER)*60
       +CAST(SUBSTR(sret_return_time,7,2) AS INTEGER)) = t_time)
LEFT OUTER JOIN item 
    ON   (sret_item_id = i_item_id)
LEFT OUTER JOIN customer 
    ON   (sret_customer_id = c_customer_id)
LEFT OUTER JOIN store 
    ON   (sret_store_id = s_store_id)
LEFT OUTER JOIN reason 
    ON   (sret_reason_id = r_reason_id)
WHERE  i_rec_end_date IS NULL
  AND s_rec_end_date IS NULL;

DROP VIEW wsv;

CREATE VIEW wsv AS
SELECT   d1.d_date_sk ws_sold_date_sk, 
        t_time_sk ws_sold_time_sk, 
        d2.d_date_sk ws_ship_date_sk,
        i_item_sk ws_item_sk, 
        c1.c_customer_sk ws_bill_customer_sk, 
        c1.c_current_cdemo_sk ws_bill_cdemo_sk, 
        c1.c_current_hdemo_sk ws_bill_hdemo_sk,
        c1.c_current_addr_sk ws_bill_addr_sk,
        c2.c_customer_sk ws_ship_customer_sk,
        c2.c_current_cdemo_sk ws_ship_cdemo_sk,
        c2.c_current_hdemo_sk ws_ship_hdemo_sk,
        c2.c_current_addr_sk ws_ship_addr_sk,
        wp_web_page_sk ws_web_page_sk,
        web_site_sk ws_web_site_sk,
        sm_ship_mode_sk ws_ship_mode_sk,
        w_warehouse_sk ws_warehouse_sk,
        p_promo_sk ws_promo_sk,
        word_order_id ws_order_number, 
        wlin_quantity ws_quantity, 
        i_wholesale_cost ws_wholesale_cost, 
        i_current_price ws_list_price,
        wlin_sales_price ws_sales_price,
        (i_current_price-wlin_sales_price)*wlin_quantity ws_ext_discount_amt,
        wlin_sales_price * wlin_quantity ws_ext_sales_price,
        i_wholesale_cost * wlin_quantity ws_ext_wholesale_cost, 
        i_current_price * wlin_quantity ws_ext_list_price, 
        i_current_price * web_tax_percentage ws_ext_tax,  
        wlin_coupon_amt ws_coupon_amt,
        wlin_ship_cost * wlin_quantity WS_EXT_SHIP_COST,
        (wlin_sales_price * wlin_quantity)-wlin_coupon_amt ws_net_paid,
        ((wlin_sales_price * wlin_quantity)-wlin_coupon_amt)*(1+web_tax_percentage) ws_net_paid_inc_tax,
        ((wlin_sales_price * wlin_quantity)-wlin_coupon_amt)-(wlin_quantity*i_wholesale_cost) WS_NET_PAID_INC_SHIP,
        (wlin_sales_price * wlin_quantity)-wlin_coupon_amt + (wlin_ship_cost * wlin_quantity)
        + i_current_price * web_tax_percentage WS_NET_PAID_INC_SHIP_TAX,
        ((wlin_sales_price * wlin_quantity)-wlin_coupon_amt)-(i_wholesale_cost * wlin_quantity) WS_NET_PROFIT
FROM s_web_order 
LEFT OUTER JOIN date_dim d1 
    ON   (CAST(word_order_date AS DATE) = d1.d_date)
LEFT OUTER JOIN time_dim 
    ON   (word_order_time = t_time)
LEFT OUTER JOIN customer c1 
    ON   (word_bill_customer_id = c1.c_customer_id)
LEFT OUTER JOIN customer c2 
    ON   (word_ship_customer_id = c2.c_customer_id)
LEFT OUTER JOIN web_site 
    ON   (word_web_site_id = web_site_id 
    AND web_rec_end_date IS NULL)
LEFT OUTER JOIN ship_mode 
    ON   (word_ship_mode_id = sm_ship_mode_id)
JOIN s_web_order_lineitem 
    ON   (word_order_id = wlin_order_id)
LEFT OUTER JOIN date_dim d2 
    ON   (CAST(wlin_ship_date AS DATE) = d2.d_date)
LEFT OUTER JOIN item 
    ON   (wlin_item_id = i_item_id 
    AND i_rec_end_date IS NULL)
LEFT OUTER JOIN web_page 
    ON   (wlin_web_page_id = wp_web_page_id 
    AND wp_rec_end_date IS NULL)
LEFT OUTER JOIN warehouse 
    ON   (wlin_warehouse_id = w_warehouse_id)
LEFT OUTER JOIN promotion 
    ON   (wlin_promotion_id = p_promo_id);

DROP VIEW wrv;

CREATE VIEW wrv AS
SELECT  d_date_sk wr_return_date_sk
      ,t_time_sk wr_return_time_sk
      ,i_item_sk wr_item_sk
      ,c1.c_customer_sk wr_refunded_customer_sk
      ,c1.c_current_cdemo_sk wr_refunded_cdemo_sk
      ,c1.c_current_hdemo_sk wr_refunded_hdemo_sk
      ,c1.c_current_addr_sk wr_refunded_addr_sk
      ,c2.c_customer_sk wr_returning_customer_sk
      ,c2.c_current_cdemo_sk wr_returning_cdemo_sk
      ,c2.c_current_hdemo_sk wr_returning_hdemo_sk
      ,c2.c_current_addr_sk wr_returing_addr_sk
      ,wp_web_page_sk wr_web_page_sk 
      ,r_reason_sk wr_reason_sk
      ,wret_order_id wr_order_number
      ,wret_return_qty wr_return_quantity
      ,wret_return_amt wr_return_amt
      ,wret_return_tax wr_return_tax
      ,wret_return_amt + wret_return_tax AS wr_return_amt_inc_tax
      ,wret_return_fee wr_fee
      ,wret_return_ship_cost wr_return_ship_cost
      ,wret_refunded_cash wr_refunded_cash
      ,wret_reversed_charge wr_reversed_charge
      ,wret_account_credit wr_account_credit
      ,wret_return_amt+wret_return_tax+wret_return_fee
       -wret_refunded_cash-wret_reversed_charge-wret_account_credit wr_net_loss
FROM s_web_returns LEFT OUTER JOIN date_dim 
    ON   (CAST(wret_return_date AS DATE) = d_date)
LEFT OUTER JOIN time_dim 
    ON   ((CAST(SUBSTR(wret_return_time,1,2) AS INTEGER)*3600
+CAST(SUBSTR(wret_return_time,4,2) AS INTEGER)*60+CAST(SUBSTR(wret_return_time,7,2) AS INTEGER))=t_time)
LEFT OUTER JOIN item 
    ON   (wret_item_id = i_item_id)
LEFT OUTER JOIN customer c1 
    ON   (wret_return_customer_id = c1.c_customer_id)
LEFT OUTER JOIN customer c2 
    ON   (wret_refund_customer_id = c2.c_customer_id)
LEFT OUTER JOIN reason 
    ON   (wret_reason_id = r_reason_id)
LEFT OUTER JOIN web_page 
    ON   (wret_web_page_id = WP_WEB_PAGE_id)
WHERE  i_rec_end_date IS NULL 
    AND wp_rec_end_date IS NULL;

DROP VIEW csv;

CREATE VIEW csv AS
SELECT  d1.d_date_sk cs_sold_date_sk 
      ,t_time_sk cs_sold_time_sk 
      ,d2.d_date_sk cs_ship_date_sk
      ,c1.c_customer_sk cs_bill_customer_sk
      ,c1.c_current_cdemo_sk cs_bill_cdemo_sk 
      ,c1.c_current_hdemo_sk cs_bill_hdemo_sk
      ,c1.c_current_addr_sk cs_bill_addr_sk
      ,c2.c_customer_sk cs_ship_customer_sk
      ,c2.c_current_cdemo_sk cs_ship_cdemo_sk
      ,c2.c_current_hdemo_sk cs_ship_hdemo_sk
      ,c2.c_current_addr_sk cs_ship_addr_sk
      ,cc_call_center_sk cs_call_center_sk
      ,cp_catalog_page_sk cs_catalog_page_sk
      ,sm_ship_mode_sk cs_ship_mode_sk
      ,w_warehouse_sk cs_warehouse_sk
      ,i_item_sk cs_item_sk
      ,p_promo_sk cs_promo_sk
      ,cord_order_id cs_order_number
      ,clin_quantity cs_quantity
      ,i_wholesale_cost cs_wholesale_cost
      ,i_current_price cs_list_price
      ,clin_sales_price cs_sales_price
      ,(i_current_price-clin_sales_price)*clin_quantity cs_ext_discount_amt
      ,clin_sales_price * clin_quantity cs_ext_sales_price
      ,i_wholesale_cost * clin_quantity cs_ext_wholesale_cost 
      ,i_current_price * clin_quantity CS_EXT_LIST_PRICE
      ,i_current_price * cc_tax_percentage CS_EXT_TAX
      ,clin_coupon_amt cs_coupon_amt
      ,clin_ship_cost * clin_quantity CS_EXT_SHIP_COST
      ,(clin_sales_price * clin_quantity)-clin_coupon_amt cs_net_paid
      ,((clin_sales_price * clin_quantity)-clin_coupon_amt)*(1+cc_tax_percentage) cs_net_paid_inc_tax
      ,(clin_sales_price * clin_quantity)-clin_coupon_amt + (clin_ship_cost * clin_quantity) CS_NET_PAID_INC_SHIP
      ,(clin_sales_price * clin_quantity)-clin_coupon_amt + (clin_ship_cost * clin_quantity) 
       + i_current_price * cc_tax_percentage CS_NET_PAID_INC_SHIP_TAX
      ,((clin_sales_price * clin_quantity)-clin_coupon_amt)-(clin_quantity*i_wholesale_cost) cs_net_profit
FROM s_catalog_order 
LEFT OUTER JOIN date_dim d1 
    ON   
  (CAST(cord_order_date AS DATE) = d1.d_date)
LEFT OUTER JOIN time_dim 
    ON   (cord_order_time = t_time)
    LEFT OUTER JOIN customer c1 
    ON   (cord_bill_customer_id = c1.c_customer_id)
LEFT OUTER JOIN customer c2 
    ON   (cord_ship_customer_id = c2.c_customer_id)
LEFT OUTER JOIN call_center 
    ON   (cord_call_center_id = cc_call_center_id 
    AND cc_rec_end_date IS NULL)
LEFT OUTER JOIN ship_mode 
    ON   (cord_ship_mode_id = sm_ship_mode_id)
JOIN s_catalog_order_lineitem 
    ON   (cord_order_id = clin_order_id)
LEFT OUTER JOIN date_dim d2 
    ON   
  (CAST(clin_ship_date AS DATE) = d2.d_date)
LEFT OUTER JOIN catalog_page 
    ON   
  (clin_catalog_page_number = cp_catalog_page_number 
    AND clin_catalog_number = cp_catalog_number)
LEFT OUTER JOIN warehouse 
    ON   (clin_warehouse_id = w_warehouse_id)
LEFT OUTER JOIN item 
    ON   (clin_item_id = i_item_id 
    AND i_rec_end_date IS NULL)
LEFT OUTER JOIN promotion 
    ON   (clin_promotion_id = p_promo_id);

DROP VIEW crv;

CREATE VIEW crv AS
SELECT  d_date_sk cr_return_date_sk
      ,t_time_sk cr_return_time_sk
      ,i_item_sk cr_item_sk
      ,c1.c_customer_sk cr_refunded_customer_sk
      ,c1.c_current_cdemo_sk cr_refunded_cdemo_sk
      ,c1.c_current_hdemo_sk cr_refunded_hdemo_sk
      ,c1.c_current_addr_sk cr_refunded_addr_sk
      ,c2.c_customer_sk cr_returning_customer_sk
      ,c2.c_current_cdemo_sk cr_returning_cdemo_sk
      ,c2.c_current_hdemo_sk cr_returning_hdemo_sk
      ,c2.c_current_addr_sk cr_returing_addr_sk
      ,cc_call_center_sk cr_call_center_sk
      ,cp_catalog_page_sk CR_CATALOG_PAGE_SK
      ,sm_ship_mode_sk CR_SHIP_MODE_SK
      ,w_warehouse_sk CR_WAREHOUSE_SK
      ,r_reason_sk cr_reason_sk
      ,cret_order_id cr_order_number
      ,cret_return_qty cr_return_quantity
      ,cret_return_amt cr_return_amt
      ,cret_return_tax cr_return_tax
      ,cret_return_amt + cret_return_tax AS cr_return_amt_inc_tax
      ,cret_return_fee cr_fee    
      ,cret_return_ship_cost cr_return_ship_cost
      ,cret_refunded_cash cr_refunded_cash
      ,cret_reversed_charge cr_reversed_charge
      ,cret_merchant_credit cr_merchant_credit
      ,cret_return_amt+cret_return_tax+cret_return_fee
         -cret_refunded_cash-cret_reversed_charge-cret_merchant_credit cr_net_loss
FROM s_catalog_returns 
LEFT OUTER JOIN date_dim 
  ON (CAST(cret_return_date AS DATE) = d_date)
LEFT OUTER JOIN time_dim 
    ON       
  ((CAST(SUBSTR(cret_return_time,1,2) AS INTEGER)*3600
   +CAST(SUBSTR(cret_return_time,4,2) AS INTEGER)*60
   +CAST(SUBSTR(cret_return_time,7,2) AS INTEGER)) = t_time)
LEFT OUTER JOIN item 
    ON   (cret_item_id = i_item_id)
LEFT OUTER JOIN customer c1 
    ON   (cret_return_customer_id = c1.c_customer_id)
LEFT OUTER JOIN customer c2 
    ON   (cret_refund_customer_id = c2.c_customer_id)
LEFT OUTER JOIN reason 
    ON   (cret_reason_id = r_reason_id)
LEFT OUTER JOIN call_center 
    ON   (cret_call_center_id = cc_call_center_id)
LEFT OUTER JOIN catalog_page 
    ON   (cret_catalog_page_id = cp_catalog_page_id)
LEFT OUTER JOIN ship_mode 
    ON   (cret_shipmode_id = sm_ship_mode_id)
LEFT OUTER JOIN warehouse 
    ON   (cret_warehouse_id = w_warehouse_id)
WHERE  i_rec_end_date IS NULL 
    AND cc_rec_end_date IS NULL;

DROP VIEW iv;

CREATE VIEW iv AS
SELECT  d_date_sk inv_date_sk,
       i_item_sk inv_item_sk,
       w_warehouse_sk inv_warehouse_sk,
       invn_qty_on_hand inv_quantity_on_hand
FROM s_inventory
LEFT OUTER JOIN warehouse 
    ON   (invn_warehouse_id=w_warehouse_id)
LEFT OUTER JOIN item 
    ON   (invn_item_id=i_item_id 
    AND i_rec_end_date IS NULL)
LEFT OUTER JOIN date_dim 
    ON   (d_date=invn_date);

