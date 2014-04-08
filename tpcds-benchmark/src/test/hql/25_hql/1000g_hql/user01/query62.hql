-- start HQL
select  
   substr(w_warehouse_name,1,20) as thename
  ,sm_type
  ,web_name
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk <= 30 ) then 1 else 0 end)  as 30_days
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 30) and
                 (ws_ship_date_sk - ws_sold_date_sk <= 60) then 1 else 0 end )  as 31_60_days
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 60) and
                 (ws_ship_date_sk - ws_sold_date_sk <= 90) then 1 else 0 end)  as 61_90_days
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 90) and
                 (ws_ship_date_sk - ws_sold_date_sk <= 120) then 1 else 0 end)  as 91_120_days
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk  > 120) then 1 else 0 end)  as GT_120_days
from
   web_sales ws
  join warehouse w on (ws.ws_warehouse_sk = w.w_warehouse_sk)
  join ship_mode sm on (ws.ws_ship_mode_sk = sm.sm_ship_mode_sk)
  join web_site web on (ws.ws_web_site_sk = web.web_site_sk)
  join date_dim d on (ws.ws_ship_date_sk = d.d_date_sk)
where d_month_seq between 1202 and 1202 + 11
group by
   substr(w_warehouse_name,1,20)
  ,sm_type
  ,web_name
order by thename
        ,sm_type
       ,web_name
limit 100;

-- end query 16 in stream 0 using template q62.tpl
