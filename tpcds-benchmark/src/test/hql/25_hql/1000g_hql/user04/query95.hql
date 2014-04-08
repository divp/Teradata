-- start HQL
select 
   count(distinct ws_order_number) as order_count
  ,sum(ws_ext_ship_cost) as total_shipping_cost
  ,sum(ws_net_profit) as total_net_profit
from
   web_sales ws1
  join date_dim d on (ws1.ws_ship_date_sk = d.d_date_sk)
  join customer_address ca on (ws1.ws_ship_addr_sk = ca.ca_address_sk)
  join web_site w on (ws1.ws_web_site_sk = w.web_site_sk)
  left semi join (select ws1.ws_order_number,ws1.ws_warehouse_sk wh1,ws2.ws_warehouse_sk wh2 from web_sales ws1 join web_sales ws2 on (ws1.ws_order_number = ws2.ws_order_number) where ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk) ws_wh on (ws1.ws_order_number = ws_wh.ws_order_number)
  left semi join (select wr.wr_order_number from (select ws1.ws_order_number,ws1.ws_warehouse_sk wh1,ws2.ws_warehouse_sk wh2 from web_sales ws1 join web_sales ws2 on (ws1.ws_order_number = ws2.ws_order_number) where ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk) ws_wh join web_returns wr on (wr.wr_order_number = ws_wh.ws_order_number)) in2 on (ws1.ws_order_number = in2.wr_order_number)
where d_date between '2001-04-01' and date_add(cast('2001-04-01' as date), 60 )
and ca_state = 'TX'
and web_company_name = 'pri'
order by order_count
limit 100;

-- end query 24 in stream 0 using template q95.tpl
