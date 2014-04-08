-- start HQL
select  sum(cs_ext_discount_amt)  as excess_discount_amount
from
    catalog_sales cs
    join item i on (i.i_item_sk = cs.cs_item_sk)
    join date_dim d on (d.d_date_sk = cs.cs_sold_date_sk)
    cross join (
         select avg(cast(cs_ext_discount_amt as double)) as adj_discount_amt
         from catalog_sales cs2
         join item i2 on (i2.i_item_sk = cs2.cs_item_sk)
         join date_dim d2 on (d2.d_date_sk = cs2.cs_sold_date_sk)
         where d_date between '2000-03-26' and date_add(cast('2000-03-26' as date),90)
         and i2.i_manufact_id = 247
     ) s 
where 
     i_manufact_id = 247
 and d_date between '2000-03-26' and 
                    date_add(cast('2000-03-26' as date),90)
and (cs.cs_ext_discount_amt / 1.3) > s.adj_discount_amt
limit 100;

-- end query 8 in stream 0 using template q32.tpl
