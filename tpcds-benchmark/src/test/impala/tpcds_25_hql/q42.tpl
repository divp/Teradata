-- q42
select  dt.d_year
        ,i.i_category_id
        ,i.i_category
        ,sum(ss_ext_sales_price) as ext_p
from   date_dim dt 
        join store_sales ss on (dt.d_date_sk = ss.ss_sold_date_sk)
        join item i on (ss.ss_item_sk = i.i_item_sk)
where i.i_manager_id = 1
        and dt.d_moy=12
        and dt.d_year=1998
group by       dt.d_year
                ,i.i_category_id
                ,i.i_category
order by       ext_p desc,d_year
                ,i_category_id
                ,i_category
limit 100
;
