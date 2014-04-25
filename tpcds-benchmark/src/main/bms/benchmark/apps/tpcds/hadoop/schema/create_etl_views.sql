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
LEFT OUTER JOIN customer c ON   (p.purc_customer_id = c.c_customer_id AND p.purc_customer_id IS NOT NULL AND c.c_customer_id IS NOT NULL)
LEFT OUTER JOIN store    s ON   (p.purc_store_id = s.s_store_id AND p.purc_store_id IS NOT NULL AND s.s_store_id IS NOT NULL)
LEFT OUTER JOIN date_dim d ON   (p.purc_purchase_date = d.d_date AND p.purc_purchase_date IS NOT NULL)
LEFT OUTER JOIN time_dim t ON   (p.purc_purchase_time = t.t_time AND p.purc_purchase_time IS NOT NULL)
JOIN s_purchase_lineitem pl ON  (p.purc_purchase_id = pl.plin_purchase_id AND p.purc_purchase_id IS NOT NULL AND pl.plin_purchase_id IS NOT NULL)
LEFT OUTER JOIN promotion pr ON (pl.plin_promotion_id = pr.p_promo_id AND pl.plin_promotion_id IS NOT NULL AND pl.plin_promotion_id IS NOT NULL)
LEFT OUTER JOIN item i     ON   (pl.plin_item_id = i.i_item_id AND pl.plin_item_id IS NOT NULL AND i.i_item_id IS NOT NULL)
WHERE    
        i_rec_end_date IS NULL
    AND s_rec_end_date IS NULL;
