-- start query 24 in stream 0 using template q95.tpl and seed 1298893997

.set retlimit 100
.set retcancel on
with ws_wh(ws_order_number,wh1,wh2) as
(select ws1.ws_order_number,ws1.ws_warehouse_sk wh1,ws2.ws_warehouse_sk wh2
 from web_sales ws1,web_sales ws2
 where ws1.ws_order_number = ws2.ws_order_number
   and ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
 select  top 100
   count(distinct ws_order_number) as "order count"
  ,cast(sum(ws_ext_ship_cost) as decimal(18,2)) as "total shipping cost"
  ,cast(sum(ws_net_profit) as decimal(18,2)) as "total net profit"
from
   web_sales ws1
  ,date_dim
  ,customer_address
  ,web_site
where
    d_date between '2000-05-01' and 
           (cast('2000-05-01' as date) + 60 )
and ws1.ws_ship_date_sk = d_date_sk
and ws1.ws_ship_addr_sk = ca_address_sk
and ca_state = 'MS'
and ws1.ws_web_site_sk = web_site_sk
and web_company_name = 'pri'
and ws1.ws_order_number in (select ws_order_number
                            from ws_wh)
and ws1.ws_order_number in (select wr_order_number
                            from web_returns,ws_wh
                            where wr_order_number = ws_wh.ws_order_number)
order by count(distinct ws_order_number)
;

