-- start HQL
select  i_item_id
       ,i_item_desc
       ,i_current_price
 from item im
 join inventory i on ( i.inv_item_sk = im.i_item_sk)
 join date_dim d on (d.d_date_sk=i.inv_date_sk)
 join store_sales ss on (ss.ss_item_sk = im.i_item_sk)
 where i_current_price between 12 and 12+30
 and d_date between cast('2000-04-04' as date) and date_add(cast('2000-04-04' as date),60)
 and i_manufact_id in (181,727,602,57)
 and inv_quantity_on_hand between 100 and 500
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
limit 100;

-- end query 21 in stream 0 using template q82.tpl
