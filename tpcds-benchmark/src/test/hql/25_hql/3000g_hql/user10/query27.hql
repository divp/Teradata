-- start HQL
select  i_item_id,
        s_state, 
        GROUPING__ID,
        avg(cast(ss_quantity as double)) agg1,
        avg(cast(ss_list_price as double)) agg2,
        avg(cast(ss_coupon_amt as double)) agg3,
        avg(cast(ss_sales_price as double)) agg4
from store_sales ss
join customer_demographics cd on (ss.ss_cdemo_sk = cd.cd_demo_sk)
join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk)
join store s on (ss.ss_store_sk = s.s_store_sk)
join item i on (ss.ss_item_sk = i.i_item_sk)
where cd_gender = 'M' and
       cd_marital_status = 'M' and
       cd_education_status = 'Unknown' and
       d_year = 2000 and
       s_state in ('WA','WV', 'PA', 'MI', 'LA', 'IL')
group by i_item_id, s_state with rollup
order by i_item_id
         ,s_state
limit 100;

-- end query 6 in stream 0 using template q27.tpl
