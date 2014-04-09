define YEAR = random(1998,2002,uniform);
define DMS = random(1176,1224,uniform); -- Qualification 1200
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
   substr(w_warehouse_name,1,20)
  ,sm_type
  ,web_name
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk <= 30 ) then 1 else 0 end)  as "30 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 30) and 
                 (ws_ship_date_sk - ws_sold_date_sk <= 60) then 1 else 0 end )  as "31-60 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 60) and 
                 (ws_ship_date_sk - ws_sold_date_sk <= 90) then 1 else 0 end)  as "61-90 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 90) and
                 (ws_ship_date_sk - ws_sold_date_sk <= 120) then 1 else 0 end)  as "91-120 days" 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk  > 120) then 1 else 0 end)  as ">120 days" 
from
   web_sales
  ,warehouse
  ,ship_mode
  ,web_site
  ,date_dim
where
    d_month_seq between [DMS] and [DMS] + 11
    /* extract(year from d_date) = [YEAR] */
and ws_ship_date_sk   = d_date_sk
and ws_warehouse_sk   = w_warehouse_sk
and ws_ship_mode_sk   = sm_ship_mode_sk
and ws_web_site_sk    = web_site_sk
group by
   substr(w_warehouse_name,1,20)
  ,sm_type
  ,web_name
order by substr(w_warehouse_name,1,20)
        ,sm_type
       ,web_name
;

 [AGGG]
 [AGGH]
 [AGGI]


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
where d_month_seq between [DMS] and [DMS] + 11
group by
   substr(w_warehouse_name,1,20)
  ,sm_type
  ,web_name
order by thename
        ,sm_type
       ,web_name
[_LIMITC];
