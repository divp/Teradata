-- start HQL
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
        and (hd.hd_dep_count = 1 or
             hd.hd_vehicle_count= -1)
        and d.d_year between 2000 and 2000+2
        and s.s_city in ('White Oak','Harmony')
       group by ss_ticket_number
               ,ss_customer_sk
               ,ss_addr_sk,ca_city) dn
      join customer c on (dn.ss_customer_sk = c.c_customer_sk)
      join customer_address current_addr on (c.c_current_addr_sk = current_addr.ca_address_sk)
where current_addr.ca_city <> bought_city
order by c_last_name
         ,ss_ticket_number
limit 100;

-- end query 18 in stream 0 using template q68.tpl
