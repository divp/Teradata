/* TODO:
    - Replace type 'identifier' for actual physical type
    - Add null constraints as specified in TPC-DS spec (see section A.1 "Refresh Data Set DDL")
*/

DATABASE tpcds1000g;

CREATE MULTISET TABLE s_zip_to_gmt,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
    (
        zipg_zip    CHAR(5),
        zipg_gmt_offset INTEGER
    )
NO PRIMARY INDEX;


CREATE MULTISET TABLE s_purchase_lineitem, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO 
     (
        plin_purchase_id identifier
        plin_line_number INTEGER
        plin_item_id CHAR(16)
        plin_promotion_id CHAR(16)
        plin_quantity INTEGER
        plin_sale_price NUMERIC(7,2)
        plin_coupon_amt NUMERIC(7,2)
        plin_comment CHAR(100)
    )
NO PRIMARY INDEX;

CREATE MULTISET TABLE s_customer, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO 
     (
        cust_customer_id identifier
        cust_salutation CHAR(10)
        cust_last_name CHAR(20)
        cust_first_name    CHAR(20)
        cust_preffered_flag   CHAR(1)
        cust_birth_date CHAR(10)
        cust_birth_country CHAR(20)
        cust_login_id CHAR(13)
        cust_email_address  CHAR(50)
        cust_last_login_chg_date  CHAR(10)
        cust_first_shipto_date   CHAR(10)
        cust_first_purchase_date  CHAR(10)
        cust_last_review_date   CHAR(10)
        cust_primary_machine_id  CHAR(15)
        cust_secondary_machine_id  CHAR(15)
        cust_street_number  CHAR(10),
        cust_suite_number    CHAR(10)
        cust_street_name1   CHAR(30)
        cust_street_name2   CHAR(30)
        cust_street_type   CHAR(15)
        cust_city   CHAR(60)
        cust_zip   CHAR(10)
        cust_county  CHAR(30)
        cust_state CHAR(2)
        cust_country CHAR(20)
        cust_loc_type   CHAR(20)
        cust_gender  CHAR(1)
        cust_marital_status   CHAR(1)
        cust_educ_status  CHAR(20)
        cust_credit_rating CHAR(10)
        cust_purch_est NUMERIC(7,2)
        cust_buy_potential CHAR(15)
        cust_depend_cnt   INTEGER
        cust_depend_emp_cnt  INTEGER
        cust_depend_college_cnt  INTEGER
        cust_vehicle_cnt   INTEGER
        cust_annual_income NUMERIC(9,2)
    )
    NO PRIMARY INDEX;
    
CREATE MULTISET TABLE s_purchase, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
     purc_purchase_id identifier
purc_store_id    CHAR(16)
purc_customer_id CHAR(16)
purc_purchase_date  CHAR(10)
purc_purchase_time  INTEGER
purc_register_id    INTEGER
purc_clerk_id    INTEGER
purc_comment  CHAR(100)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_catalog_order, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
     cord_order_id  identifier
cord_bill_customer_id   CHAR(16)
cord_ship_customer_id CHAR(16)
cord_order_date    CHAR(10)
cord_order_time    INTEGER
cord_ship_mode_id   CHAR(16)
cord_call_center_id   CHAR(16)
cord_order_comments  VARCHAR(100)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_web_order, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
     word_order_id  identifier
word_bill_customer_id   CHAR(16)
word_ship_customer_id CHAR(16)
word_order_date   CHAR(10)
word_order_time   INTEGER
word_ship_mode_id  CHAR(16)
word_web_site_id CHAR(16)
word_order_comments  CHAR(100)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_item, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
item_item_id CHAR(16)
item_item_description   CHAR(200)
item_list_price  NUMERIC(7,2)
item_wholesale_cost NUMERIC(7,2)
item_size  CHAR(20)
item_formulation   CHAR(20)
item_color CHAR(20)
item_units CHAR(10)
item_container  CHAR(10)
item_manager_id  INTEGER
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_catalog_order_lineitem, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
clin_order_id identifier
clin_line_number   INTEGER
clin_item_id  CHAR(16)
clin_promotion_id  CHAR(16)
clin_quantity INTEGER
clin_sales_price    NUMERIC(7,2)
clin_coupon_amt   NUMERIC(7,2)
clin_warehouse_id CHAR(16)
clin_ship_date   CHAR(10)
clin_catalog_number INTEGER
clin_catalog_page_number INTEGER
clin_ship_cost   NUMERIC(7,2)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_web_order_lineitem, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
wlin_order_id identifier
wlin_line_number  INTEGER
wlin_item_id  CHAR(16)
wlin_promotion_id CHAR(16)
wlin_quantity INTEGER
wlin_sales_price   NUMERIC(7,2)
wlin_coupon_amt  NUMERIC(7,2)
wlin_warehouse_id    CHAR(16)
wlin_ship_date  CHAR(10)
wlin_ship_cost  NUMERIC(7,2)
wlin_web_page_id CHAR(16)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_store, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
stor_store_id CHAR(16)
stor_closed_date  CHAR(10)
stor_name CHAR(50)
stor_employees INTEGER
stor_floor_space   INTEGER
stor_hours    CHAR(20)
stor_store_manager  CHAR(40)
stor_market_id  INTEGER
stor_geography_class   CHAR(100)
stor_market_manager   CHAR(40)
stor_tax_percentage  NUMERIC(5,2)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_call_center, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
call_center_id   CHAR(16)
call_open_date  CHAR(10)
call_closed_date   CHAR(10)
call_center_name  CHAR(50)
call_center_class  CHAR(50)
call_center_employees  INTEGER
call_center_sq_ft  INTEGER
call_center_hours CHAR(20)
call_center_manager CHAR(40)
call_center_tax_percentage   NUMERIC(7,2)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_web_site, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
wsit_web_site_id   CHAR(16)
wsit_open_date CHAR(10)
wsit_closed_date  CHAR(10)
wsit_site_name CHAR(50)
wsit_site_class CHAR(50)
wsit_site_manager    CHAR(40),
wsit_tax_percentage DECIMAL(5,2)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_warehouse, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
wrhs_warehouse_id  CHAR(16)
wrhs_warehouse_desc  CHAR(200)
wrhs_warehouse_sq_ft  INTEGER
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_web_page, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
wpag_web_page_id   CHAR(16)
wpag_create_date CHAR(10)
wpag_access_date   CHAR(10)
wpag_autogen_flag   CHAR(1)
wpag_url   CHAR(100)
wpag_type CHAR(50)
wpag_char_cnt INTEGER
wpag_link_cnt   INTEGER
wpag_image_cnt   INTEGER
wpag_max_ad_cnt INTEGER
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_promotion, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
prom_promotion_id   CHAR(16)
prom_promotion_name  CHAR(30)
prom_start_date    CHAR(10)
prom_end_date CHAR(10)
prom_cost NUMERIC(7,2)
prom_response_target  CHAR(1)
prom_channel_dmail CHAR(1)
prom_channel_email CHAR(1)
prom_channel_catalog  CHAR(1)
prom_channel_tv   CHAR(1)
prom_channel_radio  CHAR(1)
prom_channel_press CHAR(1)
prom_channel_event CHAR(1)
prom_channel_demo CHAR(1)
prom_channel_details   CHAR(100)
prom_purpose   CHAR(15)
prom_discount_active   CHAR(1)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_store_returns, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
sret_store_id CHAR(16)
sret_purchase_id  CHAR(16)
sret_line_number  INTEGER
sret_item_id  CHAR(16)
sret_customer_id  CHAR(16)
sret_return_date   CHAR(10)
sret_return_time   CHAR(10)
sret_ticket_number   CHAR(20)
sret_return_qty INTEGER
sret_return_amount   NUMERIC(7,2)
sret_return_tax NUMERIC(7,2)
sret_return_fee NUMERIC(7,2)
sret_return_ship_cost   NUMERIC(7,2)
sret_refunded_cash  NUMERIC(7,2)
sret_reversed_charge   NUMERIC(7,2)
sret_store_credit   NUMERIC(7,2)
sret_reason_id  CHAR(16)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_catalog_returns, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
cret_call_center_id    CHAR(16)
cret_order_id INTEGER
cret_line_number  INTEGER
cret_item_id  CHAR(16)
cret_return_customer_id   CHAR(16)
cret_refund_customer_id   CHAR(16)
cret_return_date   CHAR(10)
cret_return_time   CHAR(10)
cret_return_qty INTEGER
cret_return_amt NUMERIC(7,2)
cret_return_tax NUMERIC(7,2)
cret_return_fee NUMERIC(7,2)
cret_return_ship_cost   NUMERIC(7,2)
cret_refunded_cash  NUMERIC(7,2)
cret_reversed_charge   NUMERIC(7,2)
cret_merchant_credit NUMERIC(7,2)
cret_reason_id  CHAR(16)
cret_shipmode_id  CHAR(16)
cret_catalog_page_id CHAR(16)
cret_warehouse_id    CHAR(16)
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_web_returns, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
wret_web_page_id CHAR(16)
wret_order_id    INTEGER
wret_line_number  INTEGER
wret_item_id CHAR(16)
wret_return_customer_id   CHAR(16)
wret_refund_customer_id  CHAR(16)
wret_return_date   CHAR(10)
wret_return_time   CHAR(10)
wret_return_qty INTEGER
wret_return_amt    NUMERIC(7,2)
wret_return_tax NUMERIC(7,2)
wret_return_fee NUMERIC(7,2)
wret_return_ship_cost   NUMERIC(7,2)
wret_refunded_cash  NUMERIC(7,2)
wret_reversed_charge   NUMERIC(7,2)
wret_account_credit  NUMERIC(7,2)
wret_reason_id CHAR(16)
)  NO PRIMARY INDEX;


CREATE MULTISET TABLE s_inventory, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
     invn_warehouse_id   CHAR(16),
invn_item_id CHAR(16),
invn_date  CHAR(10)
invn_qty_on_hand INTEGER
)  NO PRIMARY INDEX;

CREATE MULTISET TABLE s_catalog_page, NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
     cpag_catalog_number  INTEGER
    cpag_catalog_page_number  INTEGER
    cpag_department  CHAR(20)
    cpag_id CHAR(16)
    cpag_start_date    CHAR(10)
    cpag_end_date CHAR(10)
    cpag_description   VARCHAR(100)
    cpag_type VARCHAR(100)
)  NO PRIMARY INDEX;