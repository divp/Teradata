-- start query 1 in stream 0 using template q3.tpl and seed 1621510873



select top 100 dt.d_year 
       ,item.i_brand_id brand_id 
       ,item.i_brand brand
       ,cast(sum(ss_sales_price) as decimal(18,2)) sum_agg
 from  date_dim dt 
      ,store_sales
      ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and item.i_manufact_id = 809
   and dt.d_moy=11
 group by dt.d_year
      ,item.i_brand
      ,item.i_brand_id
 order by dt.d_year
         ,sum_agg desc
         ,brand_id
;

