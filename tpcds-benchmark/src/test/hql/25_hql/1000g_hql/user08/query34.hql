-- start HQL
select c_last_name
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales ss
    join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk)
    join store s on (ss.ss_store_sk = s.s_store_sk)
    join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
    where (d.d_dom between 1 and 3 or d.d_dom between 25 and 28)
    and (hd.hd_buy_potential = '1001-5000' or
         hd.hd_buy_potential = '0-500')
    and hd.hd_vehicle_count > 0
    and (case when hd.hd_vehicle_count > 0
        then floor(hd.hd_dep_count/ hd.hd_vehicle_count)
        else null
        end)  > 1.2
    and d.d_year between 1999 and 1999+2
    and s.s_county in ('Oglethorpe County','Bronx County','Daviess County','Gogebic County','Franklin Parish','Mobile County','Raleigh County','Dauphin County')
    group by ss_ticket_number,ss_customer_sk) dn
    join customer c on (dn.ss_customer_sk = c.c_customer_sk)
    where cnt between 15 and 20
    order by c_last_name,c_first_name,c_salutation,c_preferred_cust_flag desc;

-- end query 9 in stream 0 using template q34.tpl
