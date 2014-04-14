select sum(ss_quantity) as quantity, sum(ss_net_paid) as net_paid, sum(ss_net_profit) as net_profit from store_sales t_s
where ss_item_sk = ${SIS} and ss_store_sk = ${SSK};
