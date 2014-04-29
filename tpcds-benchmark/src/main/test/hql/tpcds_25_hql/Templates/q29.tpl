use ${hiveconf:db};

select   
     i_item_id
    ,i_item_desc
    ,s_store_id
    ,s_store_name
    ,sum(ss_quantity)        as store_sales_quantity
    ,sum(sr_return_quantity) as store_returns_quantity
    ,sum(cs_quantity)        as catalog_sales_quantity
from
    store_sales ss
   join store_returns sr on (ss.ss_customer_sk = sr.sr_customer_sk and ss.ss_item_sk = sr.sr_item_sk and ss.ss_ticket_number = sr.sr_ticket_number)
   join catalog_sales cs on (sr.sr_customer_sk = cs.cs_bill_customer_sk and sr.sr_item_sk = cs.cs_item_sk)
   join date_dim d1 on (d1.d_date_sk = ss.ss_sold_date_sk)
   join date_dim d2 on (sr.sr_returned_date_sk = d2.d_date_sk)
   join date_dim d3 on (cs.cs_sold_date_sk = d3.d_date_sk)
   join store s on (s.s_store_sk = ss.ss_store_sk)
   join item i on (i.i_item_sk = ss.ss_item_sk)
where
     d1.d_moy               = 4
and d1.d_year              = 1998
and d2.d_moy               between 4 and  4 + 3
and d2.d_year              = 1998
and d3.d_year              between 1998 and 1998+2
group by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
order by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
limit 100
;
