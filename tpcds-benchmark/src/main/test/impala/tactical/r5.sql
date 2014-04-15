SELECT SUM(ss_quantity) as quantity, SUM(ss_net_paid) as net_paid, SUM(ss_net_profit) AS net_profit
FROM store_sales t_s
WHERE ss_item_sk=15622
AND ss_store_sk=331;
