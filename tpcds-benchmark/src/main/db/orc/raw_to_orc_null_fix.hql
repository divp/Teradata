use tpcds1000g;

insert into table customer_address
select
ca_address_sk,
case when ca_address_id='' then null else ca_address_id end,
case when ca_street_number='' then null else ca_street_number end,
case when ca_street_name='' then null else ca_street_name end,
case when ca_street_type='' then null else ca_street_type end,
case when ca_suite_number='' then null else ca_suite_number end,
case when ca_city='' then null else ca_city end,
case when ca_county='' then null else ca_county end,
case when ca_state='' then null else ca_state end,
case when ca_zip='' then null else ca_zip end,
case when ca_country='' then null else ca_country end,
ca_gmt_offset,
case when ca_location_type='' then null else ca_location_type end
from customer_address_raw;

insert into table customer_demographics
select
cd_demo_sk,
case when cd_gender='' then null else cd_gender end,
case when cd_marital_status='' then null else cd_marital_status end,
case when cd_education_status='' then null else cd_education_status end,
cd_purchase_estimate,
case when cd_credit_rating='' then null else cd_credit_rating end,
cd_dep_count,
cd_dep_employed_count,
cd_dep_college_count
from customer_demographics_raw;

insert into table date_dim
select
d_date_sk,
case when d_date_id='' then null else d_date_id end,
d_date,
d_month_seq,
d_week_seq,
d_quarter_seq,
d_year,
d_dow,
d_moy,
d_dom,
d_qoy,
d_fy_year,
d_fy_quarter_seq,
d_fy_week_seq,
case when d_day_name='' then null else d_day_name end,
case when d_quarter_name='' then null else d_quarter_name end,
case when d_holiday='' then null else d_holiday end,
case when d_weekend='' then null else d_weekend end,
case when d_following_holiday='' then null else d_following_holiday end,
d_first_dom,
d_last_dom,
d_same_day_ly,
d_same_day_lq,
case when d_current_day='' then null else d_current_day end,
case when d_current_week='' then null else d_current_week end,
case when d_current_month='' then null else d_current_month end,
case when d_current_quarter='' then null else d_current_quarter end,
case when d_current_year='' then null else d_current_year end
from date_dim_raw;

insert into table warehouse
select
w_warehouse_sk,
case when w_warehouse_id='' then null else w_warehouse_id end,
case when w_warehouse_name='' then null else w_warehouse_name end,
w_warehouse_sq_ft,
case when w_street_number='' then null else w_street_number end,
case when w_street_name='' then null else w_street_name end,
case when w_street_type='' then null else w_street_type end,
case when w_suite_number='' then null else w_suite_number end,
case when w_city='' then null else w_city end,
case when w_county='' then null else w_county end,
case when w_state='' then null else w_state end,
case when w_zip='' then null else w_zip end,
case when w_country='' then null else w_country end,
w_gmt_offset
from warehouse_raw;

insert into table ship_mode
select
sm_ship_mode_sk,
case when sm_ship_mode_id='' then null else sm_ship_mode_id end,
case when sm_type='' then null else sm_type end,
case when sm_code='' then null else sm_code end,
case when sm_carrier='' then null else sm_carrier end,
case when sm_contract='' then null else sm_contract end
from ship_mode_raw;

insert into table time_dim
select
t_time_sk,
case when t_time_id='' then null else t_time_id end,
t_time,
t_hour,
t_minute,
t_second,
case when t_am_pm='' then null else t_am_pm end,
case when t_shift='' then null else t_shift end,
case when t_sub_shift='' then null else t_sub_shift end,
case when t_meal_time='' then null else t_meal_time end
from time_dim_raw;

insert into table reason
select
r_reason_sk,
case when r_reason_id='' then null else r_reason_id end,
case when r_reason_desc='' then null else r_reason_desc end
from reason_raw;

insert into table income_band
select
ib_income_band_sk,
ib_lower_bound,
ib_upper_bound
from income_band_raw;

insert into table item
select
i_item_sk,
case when i_item_id='' then null else i_item_id end,
i_rec_start_date,
i_rec_end_date,
case when i_item_desc='' then null else i_item_desc end,
i_current_price,
i_wholesale_cost,
i_brand_id,
case when i_brand='' then null else i_brand end,
i_class_id,
case when i_class='' then null else i_class end,
i_category_id,
case when i_category='' then null else i_category end,
i_manufact_id,
case when i_manufact='' then null else i_manufact end,
case when i_size='' then null else i_size end,
case when i_formulation='' then null else i_formulation end,
case when i_color='' then null else i_color end,
case when i_units='' then null else i_units end,
case when i_container='' then null else i_container end,
i_manager_id,
case when i_product_name='' then null else i_product_name end
from item_raw;

insert into table store
select
s_store_sk,
case when s_store_id='' then null else s_store_id end,
s_rec_start_date,
s_rec_end_date,
s_closed_date_sk,
case when s_store_name='' then null else s_store_name end,
s_number_employees,
s_floor_space,
case when s_hours='' then null else s_hours end,
case when s_manager='' then null else s_manager end,
s_market_id,
case when s_geography_class='' then null else s_geography_class end,
case when s_market_desc='' then null else s_market_desc end,
case when s_market_manager='' then null else s_market_manager end,
s_division_id,
case when s_division_name='' then null else s_division_name end,
s_company_id,
case when s_company_name='' then null else s_company_name end,
case when s_street_number='' then null else s_street_number end,
case when s_street_name='' then null else s_street_name end,
case when s_street_type='' then null else s_street_type end,
case when s_suite_number='' then null else s_suite_number end,
case when s_city='' then null else s_city end,
case when s_county='' then null else s_county end,
case when s_state='' then null else s_state end,
case when s_zip='' then null else s_zip end,
case when s_country='' then null else s_country end,
s_gmt_offset,
s_tax_percentage
from store_raw;

insert into table call_center
select
cc_call_center_sk,
case when cc_call_center_id='' then null else cc_call_center_id end,
cc_rec_start_date,
cc_rec_end_date,
cc_closed_date_sk,
cc_open_date_sk,
case when cc_name='' then null else cc_name end,
case when cc_class='' then null else cc_class end,
cc_employees,
cc_sq_ft,
case when cc_hours='' then null else cc_hours end,
case when cc_manager='' then null else cc_manager end,
cc_mkt_id,
case when cc_mkt_class='' then null else cc_mkt_class end,
case when cc_mkt_desc='' then null else cc_mkt_desc end,
case when cc_market_manager='' then null else cc_market_manager end,
cc_division,
case when cc_division_name='' then null else cc_division_name end,
cc_company,
case when cc_company_name='' then null else cc_company_name end,
case when cc_street_number='' then null else cc_street_number end,
case when cc_street_name='' then null else cc_street_name end,
case when cc_street_type='' then null else cc_street_type end,
case when cc_suite_number='' then null else cc_suite_number end,
case when cc_city='' then null else cc_city end,
case when cc_county='' then null else cc_county end,
case when cc_state='' then null else cc_state end,
case when cc_zip='' then null else cc_zip end,
case when cc_country='' then null else cc_country end,
cc_gmt_offset,
cc_tax_percentage
from call_center_raw;


insert into table customer
select c_customer_sk,
case when c_customer_id='' then null else c_customer_id end,
c_current_cdemo_sk,
c_current_hdemo_sk,
c_current_addr_sk,
c_first_shipto_date_sk,
c_first_sales_date_sk,
case when c_salutation='' then null else c_salutation end,
case when c_first_name='' then null else c_first_name end,
case when c_last_name='' then null else c_last_name end,
case when c_preferred_cust_flag='' then null else c_preferred_cust_flag end,
c_birth_day,
c_birth_month,
c_birth_year,
case when c_birth_country='' then null else c_birth_country end,
case when c_login='' then null else c_login end,
case when c_email_address='' then null else c_email_address end,
case when c_last_review_date='' then null else c_last_review_date end
from customer_raw;

insert into table web_site
select
web_site_sk,
case when web_site_id='' then null else web_site_id end,
web_rec_start_date,
web_rec_end_date,
case when web_name='' then null else web_name end,
web_open_date_sk,
web_close_date_sk,
case when web_class='' then null else web_class end,
case when web_manager='' then null else web_manager end,
web_mkt_id,
case when web_mkt_class='' then null else web_mkt_class end,
case when web_mkt_desc='' then null else web_mkt_desc end,
case when web_market_manager='' then null else web_market_manager end,
web_company_id,
case when web_company_name='' then null else web_company_name end,
case when web_street_number='' then null else web_street_number end,
case when web_street_name='' then null else web_street_name end,
case when web_street_type='' then null else web_street_type end,
case when web_suite_number='' then null else web_suite_number end,
case when web_city='' then null else web_city end,
case when web_county='' then null else web_county end,
case when web_state='' then null else web_state end,
case when web_zip='' then null else web_zip end,
case when web_country='' then null else web_country end,
web_gmt_offset,
web_tax_percentage
from web_site_raw;

insert into table store_returns
select
sr_returned_date_sk,
sr_return_time_sk,
sr_item_sk,
sr_customer_sk,
sr_cdemo_sk,
sr_hdemo_sk,
sr_addr_sk,
sr_store_sk,
sr_reason_sk,
sr_ticket_number,
sr_return_quantity,
sr_return_amt,
sr_return_tax,
sr_return_amt_inc_tax,
sr_fee,
sr_return_ship_cost,
sr_refunded_cash,
sr_reversed_charge,
sr_store_credit,
sr_net_loss
from store_returns_raw;

insert into table household_demographics
select
hd_demo_sk,
hd_income_band_sk,
case when hd_buy_potential='' then null else hd_buy_potential end,
hd_dep_count,
hd_vehicle_count
from household_demographics_raw;

insert into table web_page
select
wp_web_page_sk,
case when wp_web_page_id='' then null else wp_web_page_id end,
wp_rec_start_date,
wp_rec_end_date,
wp_creation_date_sk,
wp_access_date_sk,
case when wp_autogen_flag='' then null else wp_autogen_flag end,
wp_customer_sk,
case when wp_url='' then null else wp_url end,
case when wp_type='' then null else wp_type end,
wp_char_count,
wp_link_count,
wp_image_count,
wp_max_ad_count
from web_page_raw;

insert into table promotion
select
p_promo_sk,
case when p_promo_id='' then null else p_promo_id end,
p_start_date_sk,
p_end_date_sk,
p_item_sk,
p_cost,
p_response_target,
case when p_promo_name='' then null else p_promo_name end,
case when p_channel_dmail='' then null else p_channel_dmail end,
case when p_channel_email='' then null else p_channel_email end,
case when p_channel_catalog='' then null else p_channel_catalog end,
case when p_channel_tv='' then null else p_channel_tv end,
case when p_channel_radio='' then null else p_channel_radio end,
case when p_channel_press='' then null else p_channel_press end,
case when p_channel_event='' then null else p_channel_event end,
case when p_channel_demo='' then null else p_channel_demo end,
case when p_channel_details='' then null else p_channel_details end,
case when p_purpose='' then null else p_purpose end,
case when p_discount_active='' then null else p_discount_active end
from promotion_raw;

insert into table catalog_page
select
cp_catalog_page_sk,
case when cp_catalog_page_id='' then null else cp_catalog_page_id end,
cp_start_date_sk,
cp_end_date_sk,
case when cp_department='' then null else cp_department end,
cp_catalog_number,
cp_catalog_page_number,
case when cp_description='' then null else cp_description end,
case when cp_type='' then null else cp_type end
from catalog_page_raw;

insert into table inventory
select
inv_date_sk,
inv_item_sk,
inv_warehouse_sk,
inv_quantity_on_hand
from inventory_raw;

insert into table catalog_returns
select
cr_returned_date_sk,
cr_returned_time_sk,
cr_item_sk,
cr_refunded_customer_sk,
cr_refunded_cdemo_sk,
cr_refunded_hdemo_sk,
cr_refunded_addr_sk,
cr_returning_customer_sk,
cr_returning_cdemo_sk,
cr_returning_hdemo_sk,
cr_returning_addr_sk,
cr_call_center_sk,
cr_catalog_page_sk,
cr_ship_mode_sk,
cr_warehouse_sk,
cr_reason_sk,
cr_order_number,
cr_return_quantity,
cr_return_amount,
cr_return_tax,
cr_return_amt_inc_tax,
cr_fee,
cr_return_ship_cost,
cr_refunded_cash,
cr_reversed_charge,
cr_store_credit,
cr_net_loss
from catalog_returns_raw;

insert into table web_returns
select
wr_returned_date_sk,
wr_returned_time_sk,
wr_item_sk,
wr_refunded_customer_sk,
wr_refunded_cdemo_sk,
wr_refunded_hdemo_sk,
wr_refunded_addr_sk,
wr_returning_customer_sk,
wr_returning_cdemo_sk,
wr_returning_hdemo_sk,
wr_returning_addr_sk,
wr_web_page_sk,
wr_reason_sk,
wr_order_number,
wr_return_quantity,
wr_return_amt,
wr_return_tax,
wr_return_amt_inc_tax,
wr_fee,
wr_return_ship_cost,
wr_refunded_cash,
wr_reversed_charge,
wr_account_credit,
wr_net_loss
from web_returns_raw;

insert into table web_sales
select
ws_sold_date_sk,
ws_sold_time_sk,
ws_ship_date_sk,
ws_item_sk,
ws_bill_customer_sk,
ws_bill_cdemo_sk,
ws_bill_hdemo_sk,
ws_bill_addr_sk,
ws_ship_customer_sk,
ws_ship_cdemo_sk,
ws_ship_hdemo_sk,
ws_ship_addr_sk,
ws_web_page_sk,
ws_web_site_sk,
ws_ship_mode_sk,
ws_warehouse_sk,
ws_promo_sk,
ws_order_number,
ws_quantity,
ws_wholesale_cost,
ws_list_price,
ws_sales_price,
ws_ext_discount_amt,
ws_ext_sales_price,
ws_ext_wholesale_cost,
ws_ext_list_price,
ws_ext_tax,
ws_coupon_amt,
ws_ext_ship_cost,
ws_net_paid,
ws_net_paid_inc_tax,
ws_net_paid_inc_ship,
ws_net_paid_inc_ship_tax,
ws_net_profit
from web_sales_raw;

insert into table catalog_sales
select
cs_sold_date_sk,
cs_sold_time_sk,
cs_ship_date_sk,
cs_bill_customer_sk,
cs_bill_cdemo_sk,
cs_bill_hdemo_sk,
cs_bill_addr_sk,
cs_ship_customer_sk,
cs_ship_cdemo_sk,
cs_ship_hdemo_sk,
cs_ship_addr_sk,
cs_call_center_sk,
cs_catalog_page_sk,
cs_ship_mode_sk,
cs_warehouse_sk,
cs_item_sk,
cs_promo_sk,
cs_order_number,
cs_quantity,
cs_wholesale_cost,
cs_list_price,
cs_sales_price,
cs_ext_discount_amt,
cs_ext_sales_price,
cs_ext_wholesale_cost,
cs_ext_list_price,
cs_ext_tax,
cs_coupon_amt,
cs_ext_ship_cost,
cs_net_paid,
cs_net_paid_inc_tax,
cs_net_paid_inc_ship,
cs_net_paid_inc_ship_tax,
cs_net_profit
from catalog_sales_raw;

insert into table store_sales
select
ss_sold_date_sk,
ss_sold_time_sk,
ss_item_sk,
ss_customer_sk,
ss_cdemo_sk,
ss_hdemo_sk,
ss_addr_sk,
ss_store_sk,
ss_promo_sk,
ss_ticket_number,
ss_quantity,
ss_wholesale_cost,
ss_list_price,
ss_sales_price,
ss_ext_discount_amt,
ss_ext_sales_price,
ss_ext_wholesale_cost,
ss_ext_list_price,
ss_ext_tax,
ss_coupon_amt,
ss_net_paid,
ss_net_paid_inc_tax,
ss_net_profit
from store_sales_raw;


