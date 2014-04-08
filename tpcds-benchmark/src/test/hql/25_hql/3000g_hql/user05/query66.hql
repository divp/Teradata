-- start HQL
select   
         w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,ship_carriers
        ,yearx
        ,sum(jan_sales) as jan_sales
        ,sum(feb_sales) as feb_sales
        ,sum(mar_sales) as mar_sales
        ,sum(apr_sales) as apr_sales
        ,sum(may_sales) as may_sales
        ,sum(jun_sales) as jun_sales
        ,sum(jul_sales) as jul_sales
        ,sum(aug_sales) as aug_sales
        ,sum(sep_sales) as sep_sales
        ,sum(oct_sales) as oct_sales
        ,sum(nov_sales) as nov_sales
        ,sum(dec_sales) as dec_sales
        ,sum(jan_sales/w_warehouse_sq_ft) as jan_sales_per_sq_foot
        ,sum(feb_sales/w_warehouse_sq_ft) as feb_sales_per_sq_foot
        ,sum(mar_sales/w_warehouse_sq_ft) as mar_sales_per_sq_foot
        ,sum(apr_sales/w_warehouse_sq_ft) as apr_sales_per_sq_foot
        ,sum(may_sales/w_warehouse_sq_ft) as may_sales_per_sq_foot
        ,sum(jun_sales/w_warehouse_sq_ft) as jun_sales_per_sq_foot
        ,sum(jul_sales/w_warehouse_sq_ft) as jul_sales_per_sq_foot
        ,sum(aug_sales/w_warehouse_sq_ft) as aug_sales_per_sq_foot
        ,sum(sep_sales/w_warehouse_sq_ft) as sep_sales_per_sq_foot
        ,sum(oct_sales/w_warehouse_sq_ft) as oct_sales_per_sq_foot
        ,sum(nov_sales/w_warehouse_sq_ft) as nov_sales_per_sq_foot
        ,sum(dec_sales/w_warehouse_sq_ft) as dec_sales_per_sq_foot
        ,sum(jan_net) as jan_net
        ,sum(feb_net) as feb_net
        ,sum(mar_net) as mar_net
        ,sum(apr_net) as apr_net
        ,sum(may_net) as may_net
        ,sum(jun_net) as jun_net
        ,sum(jul_net) as jul_net
        ,sum(aug_net) as aug_net
        ,sum(sep_net) as sep_net
        ,sum(oct_net) as oct_net
        ,sum(nov_net) as nov_net
        ,sum(dec_net) as dec_net
from (
    select *
    from
    (select
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,concat('ZOUROS',',','USPS') as ship_carriers
        ,d_year as yearx
        ,sum(case when d_moy = 1
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as jan_sales
        ,sum(case when d_moy = 2
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as feb_sales
        ,sum(case when d_moy = 3
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as mar_sales
        ,sum(case when d_moy = 4
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as apr_sales
        ,sum(case when d_moy = 5
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as may_sales
        ,sum(case when d_moy = 6
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as jun_sales
        ,sum(case when d_moy = 7
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as jul_sales
        ,sum(case when d_moy = 8
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as aug_sales
        ,sum(case when d_moy = 9
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as sep_sales
        ,sum(case when d_moy = 10
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as oct_sales
        ,sum(case when d_moy = 11
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as nov_sales
        ,sum(case when d_moy = 12
                then ws_sales_price *ws_quantity else cast(0 as decimal) end) as dec_sales
        ,sum(case when d_moy = 1
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as jan_net
        ,sum(case when d_moy = 2
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as feb_net
        ,sum(case when d_moy = 3
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as mar_net
        ,sum(case when d_moy = 4
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as apr_net
        ,sum(case when d_moy = 5
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as may_net
        ,sum(case when d_moy = 6
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as jun_net
        ,sum(case when d_moy = 7
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as jul_net
        ,sum(case when d_moy = 8
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as aug_net
        ,sum(case when d_moy = 9
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as sep_net
        ,sum(case when d_moy = 10
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as oct_net
        ,sum(case when d_moy = 11
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as nov_net
        ,sum(case when d_moy = 12
                then ws_net_paid_inc_tax *ws_quantity else cast(0 as decimal) end) as dec_net
     from
          web_sales ws
         join warehouse w on (ws.ws_warehouse_sk = w.w_warehouse_sk)
         join date_dim d on (ws.ws_sold_date_sk = d.d_date_sk)
         join time_dim t on (ws.ws_sold_time_sk = t.t_time_sk)
         join ship_mode s on (ws.ws_ship_mode_sk = s.sm_ship_mode_sk)
     where d_year = 2000
     and t_time between 4000 and 4000+28800 
      and sm_carrier in ('ZOUROS','USPS')
     group by
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
       ,d_year
union all
    select
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,concat('ZOUROS',',','USPS') as ship_carriers
        ,d_year as yearx
        ,sum(case when d_moy = 1
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as jan_sales
        ,sum(case when d_moy = 2
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as feb_sales
        ,sum(case when d_moy = 3
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as mar_sales
        ,sum(case when d_moy = 4
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as apr_sales
        ,sum(case when d_moy = 5
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as may_sales
        ,sum(case when d_moy = 6
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as jun_sales
        ,sum(case when d_moy = 7
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as jul_sales
        ,sum(case when d_moy = 8
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as aug_sales
        ,sum(case when d_moy = 9
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as sep_sales
        ,sum(case when d_moy = 10
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as oct_sales
        ,sum(case when d_moy = 11
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as nov_sales
        ,sum(case when d_moy = 12
                then cs_ext_list_price *cs_quantity else cast(0 as decimal) end) as dec_sales
        ,sum(case when d_moy = 1
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as jan_net
        ,sum(case when d_moy = 2
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as feb_net
        ,sum(case when d_moy = 3
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as mar_net
        ,sum(case when d_moy = 4
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as apr_net
        ,sum(case when d_moy = 5
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as may_net
        ,sum(case when d_moy = 6
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as jun_net
        ,sum(case when d_moy = 7
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as jul_net
        ,sum(case when d_moy = 8
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as aug_net
        ,sum(case when d_moy = 9
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as sep_net
        ,sum(case when d_moy = 10
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as oct_net
        ,sum(case when d_moy = 11
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as nov_net
        ,sum(case when d_moy = 12
                then cs_net_profit *cs_quantity else cast(0 as decimal) end) as dec_net
     from
          catalog_sales cs
         join warehouse w on (cs.cs_warehouse_sk = w.w_warehouse_sk)
         join date_dim d on (cs.cs_sold_date_sk = d.d_date_sk)
         join time_dim t on (cs.cs_sold_time_sk = t.t_time_sk)
         join ship_mode s on (cs.cs_ship_mode_sk = s.sm_ship_mode_sk)
     where d_year = 2000
     and t_time between 4000 AND 4000+28800 
      and sm_carrier in ('ZOUROS','USPS')
     group by
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
       ,d_year
   ) zunionall
)dtable
group by
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,ship_carriers
       ,yearx
order by w_warehouse_name
limit 100;

-- end query 17 in stream 0 using template q66.tpl
