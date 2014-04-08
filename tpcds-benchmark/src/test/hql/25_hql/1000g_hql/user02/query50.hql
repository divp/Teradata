-- start HQL
select  
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk <= 30 ) then 1 else 0 end)  as 30_
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 30) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 60) then 1 else 0 end )  as 31_60_
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 60) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 90) then 1 else 0 end)  as 61_90_
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 90) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 120) then 1 else 0 end)  as 91_120_
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk  > 120) then 1 else 0 end)  as GT_120_
from
  store_sales ss
  join store_returns sr on (ss.ss_ticket_number = sr.sr_ticket_number and ss.ss_item_sk = sr.sr_item_sk and ss.ss_customer_sk = sr.sr_customer_sk)
  join store s on (ss.ss_store_sk = s.s_store_sk)
  join date_dim d1 on (ss.ss_sold_date_sk = d1.d_date_sk)
  join date_dim d2 on (sr.sr_returned_date_sk = d2.d_date_sk)
where
    d2.d_year = 1999
and d2.d_moy  = 8
group by
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
order by s_store_name
        ,s_company_id
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
limit 100;

-- end query 14 in stream 0 using template q50.tpl
