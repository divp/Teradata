-- start HQL
select  dt.d_year
        ,i.i_brand_id brand_id
        ,i.i_brand brand
        ,sum(ss_sales_price) as sum_agg
from   date_dim dt 
        join store_sales ss on (dt.d_date_sk = ss.ss_sold_date_sk)
        join item i on (ss.ss_item_sk = i.i_item_sk)
where i.i_manufact_id = 890
  and dt.d_moy=12
group by       dt.d_year
                ,i.i_brand
                ,i.i_brand_id
order by       d_year
                ,sum_agg desc
                ,brand_id
limit 100;

-- end query 1 in stream 0 using template q3.tpl
