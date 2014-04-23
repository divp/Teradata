-- start query 8 in stream 0 using template q32.tpl and seed 520815945

.set retlimit 100
.set retcancel on
select top 100 sum(cs_ext_discount_amt) (dec(18,2))  as "excess discount amount" 
from 
   catalog_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 946
and i_item_sk = cs_item_sk 
and d_date between '2002-02-24' and 
        (cast('2002-02-24' as date) + 90 )
and d_date_sk = cs_sold_date_sk 
and cs_ext_discount_amt  
     > ( 
         select 
            1.3 * avg(cs_ext_discount_amt) 
         from 
            catalog_sales 
           ,date_dim
         where 
              cs_item_sk = i_item_sk 
          and d_date between '2002-02-24' and
                             (cast('2002-02-24' as date) + 90 )
          and d_date_sk = cs_sold_date_sk 
      ) 
;

