define YEAR = random(1999, 2002, uniform);
define MONTH = random(2,5,uniform);
define STATE = dist(fips_county,3,1);   
define COUNTYNUMBER = ulist(random(1, rowcount("active_counties", "call_center"), uniform), 5);
define COUNTY_A = distmember(fips_county, [COUNTYNUMBER.1], 2);
define COUNTY_B = distmember(fips_county, [COUNTYNUMBER.2], 2);
define COUNTY_C = distmember(fips_county, [COUNTYNUMBER.3], 2);
define COUNTY_D = distmember(fips_county, [COUNTYNUMBER.4], 2);
define COUNTY_E = distmember(fips_county, [COUNTYNUMBER.5], 2);
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

select [_LIMITA]
   count(distinct cs_order_number) as "order count"
  ,cast(sum(cs_ext_ship_cost) as decimal(18,2)) as "total shipping cost"
  ,cast(sum(cs_net_profit) as decimal(18,2)) as "total net profit"
from
   catalog_sales cs1
  ,date_dim
  ,customer_address
  ,call_center
where
    d_date between cast('[YEAR]-0[MONTH]-01' as date) and 
           (cast('[YEAR]-0[MONTH]-01' as date) + 60 )
and cs1.cs_ship_date_sk = d_date_sk
and cs1.cs_ship_addr_sk = ca_address_sk
and ca_state = '[STATE]'
and cs1.cs_call_center_sk = cc_call_center_sk
and cc_county in ('[COUNTY_A]','[COUNTY_B]','[COUNTY_C]','[COUNTY_D]',
                  '[COUNTY_E]'
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

 [AGGG]
 [AGGH]
 [AGGI]


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
    d.d_date >= '[YEAR]-0[MONTH]-01' and 
         d.d_date <= date_add('[YEAR]-0[MONTH]-01',60)
and e.ca_state = '[STATE]' 
and f.cc_county in ('[COUNTY_A]','[COUNTY_B]','[COUNTY_C]','[COUNTY_D]', '[COUNTY_E]')
and cr1.cr_order_number is null
order by order_count
[_LIMITC];
