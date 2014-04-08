-- start HQL
select
   count(distinct cs1.cs_order_number) as order_count
  ,cast(sum(cs1.cs_ext_ship_cost) as decimal(18,2)) as total_shipping_cost
  ,cast(sum(cs1.cs_net_profit) as decimal(18,2)) as total_net_profit from
   catalog_sales cs1
   join date_dim d on (cs1.cs_ship_date_sk = d.d_date_sk)
   join customer_address e on (cs1.cs_ship_addr_sk = e.ca_address_sk)
   join call_center f on (cs1.cs_call_center_sk = f.cc_call_center_sk) 
   left semi join (select csa.cs_order_number from catalog_sales csa inner join catalog_sales csb on (csa.cs_order_number = csb.cs_order_number) where csa.cs_warehouse_sk <> csb.cs_warehouse_sk group by csa.cs_order_number) cs2 on (cs1.cs_order_number = cs2.cs_order_number)
   left join (select cr_order_number from catalog_returns group by cr_order_number) cr1 on (cs1.cs_order_number = cr1.cr_order_number) 
where
    d.d_date >= '1999-04-01' and 
         d.d_date <= date_add('1999-04-01',60)
and e.ca_state = 'KY' 
and f.cc_county in ('Marshall County','Walker County','Mobile County','San Miguel County', 'Ziebach County')
and cr1.cr_order_number is null
order by order_count
limit 100;

-- end query 4 in stream 0 using template q16.tpl
