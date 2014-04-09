 define DEPCNT=random(0,9,uniform);
 define YEAR = random(1998,2000,uniform);
 define VEHCNT=random(-1,4,uniform);
 define CITYNUMBER = ulist(random(1, rowcount("active_cities", "store"), uniform), 2);
 define CITY_A = distmember(cities, [CITYNUMBER.1], 1);
 define CITY_B = distmember(cities, [CITYNUMBER.2], 1);
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

select [_LIMITA] c_last_name
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,extended_price
       ,extended_tax
       ,list_price
 from (select ss_ticket_number
             ,ss_customer_sk
             ,ca_city bought_city
             ,sum(ss_ext_sales_price) extended_price 
             ,sum(ss_ext_list_price) list_price
             ,sum(ss_ext_tax) extended_tax 
       from store_sales
           ,date_dim
           ,store
           ,household_demographics
           ,customer_address 
       where store_sales.ss_sold_date_sk = date_dim.d_date_sk
         and store_sales.ss_store_sk = store.s_store_sk  
        and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
        and store_sales.ss_addr_sk = customer_address.ca_address_sk
        and date_dim.d_dom between 1 and 2 
        and (household_demographics.hd_dep_count = [DEPCNT] or
             household_demographics.hd_vehicle_count= [VEHCNT])
        and (date_dim.d_year=[YEAR] or date_dim.d_year=[YEAR]+1 or date_dim.d_year=[YEAR]+2)
        and store.s_city in ('[CITY_A]','[CITY_B]')
       group by ss_ticket_number
               ,ss_customer_sk
               ,ss_addr_sk,ca_city) dn
      ,customer
      ,customer_address current_addr
 where ss_customer_sk = c_customer_sk
   and customer.c_current_addr_sk = current_addr.ca_address_sk
   and current_addr.ca_city <> bought_city
 order by c_last_name
         ,ss_ticket_number
;

 [AGGG]
 [AGGH]
 [AGGI]

select  c_last_name
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,extended_price
       ,extended_tax
       ,list_price
from (select ss_ticket_number
             ,ss_customer_sk
             ,ca_city bought_city
             ,sum(ss_ext_sales_price) extended_price
             ,sum(ss_ext_list_price) list_price
             ,sum(ss_ext_tax) extended_tax
       from store_sales ss
           join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk)
           join store s on (ss.ss_store_sk = s.s_store_sk)
           join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
           join customer_address ca on (ss.ss_addr_sk = ca.ca_address_sk)
       where d.d_dom between 1 and 2
        and (hd.hd_dep_count = [DEPCNT] or
             hd.hd_vehicle_count= [VEHCNT])
        and d.d_year between [YEAR] and [YEAR]+2
        and s.s_city in ('[CITY_A]','[CITY_B]')
       group by ss_ticket_number
               ,ss_customer_sk
               ,ss_addr_sk,ca_city) dn
      join customer c on (dn.ss_customer_sk = c.c_customer_sk)
      join customer_address current_addr on (c.c_current_addr_sk = current_addr.ca_address_sk)
where current_addr.ca_city <> bought_city
order by c_last_name
         ,ss_ticket_number
[_LIMITC];
