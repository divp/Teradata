-- start query 4 in stream 0 using template q16.tpl and seed 250130126

.set retlimit 100
.set retcancel on
select top 100
   count(distinct cs_order_number) as "order count"
  ,cast(sum(cs_ext_ship_cost) as decimal(18,2)) as "total shipping cost"
  ,cast(sum(cs_net_profit) as decimal(18,2)) as "total net profit"
from
   catalog_sales cs1
  ,date_dim
  ,customer_address
  ,call_center
where
    d_date between cast('2001-02-01' as date) and 
           (cast('2001-02-01' as date) + 60 )
and cs1.cs_ship_date_sk = d_date_sk
and cs1.cs_ship_addr_sk = ca_address_sk
and ca_state = 'IL'
and cs1.cs_call_center_sk = cc_call_center_sk
and cc_county in ('Raleigh County','Daviess County','Williamson County','Dauphin County',
                  'Luce County'
)
and exists (select *
            from catalog_sales cs2
            where cs1.cs_order_number = cs2.cs_order_number
              and cs1.cs_warehouse_sk <> cs2.cs_warehouse_sk)
and not exists(select *
               from catalog_returns cr1
               where cs1.cs_order_number = cr1.cr_order_number)
order by count(distinct cs_order_number)
;

