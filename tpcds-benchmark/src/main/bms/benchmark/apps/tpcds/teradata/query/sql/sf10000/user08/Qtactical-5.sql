SELECT SUM(ss_quantity) AS quantity, SUM(ss_net_paid) AS net_paid, SUM(ss_net_profit) AS net_profit FROM store_sales t_s WHERE ss_item_sk = 79094 AND ss_store_sk = 470;
