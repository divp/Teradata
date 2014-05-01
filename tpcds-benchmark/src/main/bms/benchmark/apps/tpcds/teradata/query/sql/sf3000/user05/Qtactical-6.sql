SELECT SUM(ss_quantity) AS quantity, SUM(ss_net_paid) AS net_paid, SUM(ss_net_profit) AS net_profit FROM store_sales t_s INNER JOIN date_dim t_d ON ss_sold_date_sk = d_date_sk INNER JOIN store t_st ON t_s.ss_store_sk = t_st.s_store_sk WHERE ss_item_sk = 298360 AND ss_store_sk = 1177 AND s_state = 'OH' AND d_date='1999-06-22';