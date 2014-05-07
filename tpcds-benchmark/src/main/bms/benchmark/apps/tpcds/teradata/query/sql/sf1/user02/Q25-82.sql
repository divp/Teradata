-- start query 21 in stream 0 using template q82.tpl and seed 1553315955



select  top 100 i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, store_sales
 where i_current_price between 9 and 9+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('2000-03-16' as date) and (cast('2000-03-16' as date) +  60 )
 and i_manufact_id in (817,678,270,370)
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
;

