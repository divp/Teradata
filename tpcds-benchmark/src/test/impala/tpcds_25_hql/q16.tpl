-- q16
select
   count(distinct cs1.cs_order_number) as order_count
  ,sum(cs1.cs_ext_ship_cost) as total_shipping_cost
  ,sum(cs1.cs_net_profit) as total_net_profit from
   catalog_sales cs1
   join date_dim d on (cs1.cs_ship_date_sk = d.d_date_sk)
   join customer_address e on (cs1.cs_ship_addr_sk = e.ca_address_sk)
   join call_center f on (cs1.cs_call_center_sk = f.cc_call_center_sk) 
   left semi join (select csa.cs_order_number 
	from catalog_sales csa 
	inner join catalog_sales csb on (csa.cs_order_number = csb.cs_order_number) where csa.cs_warehouse_sk <> csb.cs_warehouse_sk group by csa.cs_order_number) cs2 on (cs1.cs_order_number = cs2.cs_order_number)
   left join (select cr_order_number from catalog_returns group by cr_order_number) cr1 on (cs1.cs_order_number = cr1.cr_order_number) 
where
    d.d_date >= '1999-02-01' and 
         d.d_date <= date_add('1999-02-01',60)
and e.ca_state = 'MS' 
and f.cc_county in ('Williamson County','Williamson County','Williamson County','Williamson County', 'Williamson County')
and cr1.cr_order_number is null
order by order_count
limit 100;
