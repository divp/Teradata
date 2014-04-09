
define YEAR = random(1999, 2002, uniform);
define MONTH = random(2,5,uniform);
define STATE = dist(fips_county,3,1);    -- qualification: az
define _LIMIT=100;
 define AGGD= text({".set retlimit 100",1});
 define AGGE= text({".set retcancel on",1});
 define AGGF= text({"",1});
 define AGGG= text({"",1});
 define AGGH= text({"-- start HQL",1});
 define AGGI= text({"",1});

 [AGGD]
 [AGGE]
 [AGGF]

with ws_wh(ws_order_number,wh1,wh2) as
(select ws1.ws_order_number,ws1.ws_warehouse_sk wh1,ws2.ws_warehouse_sk wh2
 from web_sales ws1,web_sales ws2
 where ws1.ws_order_number = ws2.ws_order_number
   and ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
 select  [_LIMITA]
   count(distinct ws_order_number) as "order count"
  ,cast(sum(ws_ext_ship_cost) as decimal(18,2)) as "total shipping cost"
  ,cast(sum(ws_net_profit) as decimal(18,2)) as "total net profit"
from
   web_sales ws1
  ,date_dim
  ,customer_address
  ,web_site
where
    d_date between '[YEAR]-0[MONTH]-01' and 
           (cast('[YEAR]-0[MONTH]-01' as date) + 60 )
and ws1.ws_ship_date_sk = d_date_sk
and ws1.ws_ship_addr_sk = ca_address_sk
and ca_state = '[STATE]'
and ws1.ws_web_site_sk = web_site_sk
and web_company_name = 'pri'
and ws1.ws_order_number in (select ws_order_number
                            from ws_wh)
and ws1.ws_order_number in (select wr_order_number
                            from web_returns,ws_wh
                            where wr_order_number = ws_wh.ws_order_number)
order by count(distinct ws_order_number)
;

 [AGGG]
 [AGGH]
 [AGGI]

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
where d_date between '[YEAR]-0[MONTH]-01' and date_add(cast('[YEAR]-0[MONTH]-01' as date), 60 )
and ca_state = '[STATE]'
and web_company_name = 'pri'
order by order_count
[_LIMITC];
