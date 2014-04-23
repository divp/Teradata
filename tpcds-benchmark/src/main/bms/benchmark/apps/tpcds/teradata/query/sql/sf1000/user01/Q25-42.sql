-- start query 11 in stream 0 using template q42.tpl and seed 2110950160

.set retlimit 100
.set retcancel on
select top 100 dt.d_year
        ,item.i_category_id
        ,item.i_category
        ,cast(sum(ss_ext_sales_price) as decimal(18,2))
 from   date_dim dt
        ,store_sales
        ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
        and store_sales.ss_item_sk = item.i_item_sk
        and item.i_manager_id = 1  
        and dt.d_moy=11
        and dt.d_year=2000
 group by       dt.d_year
                ,item.i_category_id
                ,item.i_category
 order by       sum(ss_ext_sales_price) desc,dt.d_year
                ,item.i_category_id
                ,item.i_category
;

