-- q34

select /* q34 */
        c_last_name
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
    and (hd.hd_buy_potential = '>10000' or
         hd.hd_buy_potential = 'unknown')
    and hd.hd_vehicle_count > 0
    and (case when hd.hd_vehicle_count > 0
        then hd.hd_dep_count/ hd.hd_vehicle_count
        else null
        end)  > 1.2
    and d.d_year between 1998 and 1998+2
    and s.s_county in ('Williamson County','Williamson County','Williamson County','Williamson County','Williamson County','Williamson County','Williamson Davis Parish','Williamson County')
    group by ss_ticket_number,ss_customer_sk) dn
    join customer c on (dn.ss_customer_sk = c.c_customer_sk)
    where cnt between 15 and 20
    order by c_last_name,c_first_name,c_salutation,c_preferred_cust_flag desc
LIMIT 100
;
