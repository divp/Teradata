USE orc_tpcds1000g;

DROP VIEW IF EXISTS ssv;

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
        i_current_price * s.s_tax_percentage ss_ext_tax,
        plin_coupon_amt ss_coupon_amt,
        (plin_sale_price * plin_quantity)-plin_coupon_amt ss_net_paid,
        ((plin_sale_price * plin_quantity)-plin_coupon_amt)*(1+s.s_tax_percentage) ss_net_paid_inc_tax,
        ((plin_sale_price * plin_quantity)-plin_coupon_amt)-(plin_quantity*i_wholesale_cost) ss_net_profit
FROM s_purchase p
LEFT OUTER JOIN customer c ON   (p.purc_customer_id = c.c_customer_id)
LEFT OUTER JOIN store    s ON   (p.purc_store_id = s.s_store_id)
LEFT OUTER JOIN date_dim d ON   (p.purc_purchase_date = d.d_date)
LEFT OUTER JOIN time_dim t ON   (p.PURC_PURCHASE_TIME = t.t_time)
JOIN s_purchase_lineitem pl ON  (p.purc_purchase_id = pl.plin_purchase_id)
LEFT OUTER JOIN promotion pr ON (pl.plin_promotion_id = pr.p_promo_id)
LEFT OUTER JOIN item i     ON   (pl.plin_item_id = i.i_item_id)
WHERE    p.purc_purchase_id = pl.plin_purchase_id
    AND i_rec_end_date IS NULL
    AND s_rec_end_date IS NULL;
/*
FAILED: SemanticException [Error 10004]: Line 25:63 Invalid table alias or column reference 's_tax_percentage': (possible column names are: d.d_date_sk, d.d_date_id, d.d_date, d.d_month_seq, d.d_week_seq, d.d_quarter_seq, d.d_year, d.d_dow, d.d_moy, d.d_dom, d.d_qoy, d.d_fy_year, d.d_fy_quarter_seq, d.d_fy_week_seq, d.d_day_name, d.d_quarter_name, d.d_holiday, d.d_weekend, d.d_following_holiday, d.d_first_dom, d.d_last_dom, d.d_same_day_ly, d.d_same_day_lq, d.d_current_day, d.d_current_week, d.d_current_month, d.d_current_quarter, d.d_current_year, t.t_time_sk, t.t_time_id, t.t_time, t.t_hour, t.t_minute, t.t_second, t.t_am_pm, t.t_shift, t.t_sub_shift, t.t_meal_time, s.s_store_sk, s.s_store_id, s.s_rec_start_date, s.s_rec_end_date, s.s_closed_date_sk, s.s_store_name, s.s_number_employees, s.s_floor_space, s.s_hours, s.s_manager, s.s_market_id, s.s_geography_class, s.s_market_desc, s.s_market_manager, s.s_division_id, s.s_division_name, s.s_company_id, s.s_company_name, s.s_street_number, s.s_street_name, s.s_street_type, s.s_suite_number, s.s_city, s.s_county, s.s_state, s.s_zip, s.s_country, s.s_gmt_offset, s.s_tax_precentage, c.c_customer_sk, c.c_customer_id, c.c_current_cdemo_sk, c.c_current_hdemo_sk, c.c_current_addr_sk, c.c_first_shipto_date_sk, c.c_first_sales_date_sk, c.c_salutation, c.c_first_name, c.c_last_name, c.c_preferred_cust_flag, c.c_birth_day, c.c_birth_month, c.c_birth_year, c.c_birth_country, c.c_login, c.c_email_address, c.c_last_review_date, p.purc_purchase_id, p.purc_store_id, p.purc_customer_id, p.purc_purchase_date, p.purc_purchase_time, p.purc_register_id, p.purc_clerk_id, p.purc_comment, pl.plin_purchase_id, pl.plin_line_number, pl.plin_item_id, pl.plin_promotion_id, pl.plin_quantity, pl.plin_sale_price, pl.plin_coupon_amt, pl.plin_comment, pr.p_promo_sk, pr.p_promo_id, pr.p_start_date_sk, pr.p_end_date_sk, pr.p_item_sk, pr.p_cost, pr.p_response_target, pr.p_promo_name, pr.p_channel_dmail, pr.p_channel_email, pr.p_channel_catalog, pr.p_channel_tv, pr.p_channel_radio, pr.p_channel_press, pr.p_channel_event, pr.p_channel_demo, pr.p_channel_details, pr.p_purpose, pr.p_discount_active, i.i_item_sk, i.i_item_id, i.i_rec_start_date, i.i_rec_end_date, i.i_item_desc, i.i_current_price, i.i_wholesale_cost, i.i_brand_id, i.i_brand, i.i_class_id, i.i_class, i.i_category_id, i.i_category, i.i_manufact_id, i.i_manufact, i.i_size, i.i_formulation, i.i_color, i.i_units, i.i_container, i.i_manager_id, i.i_product_name)
*/
