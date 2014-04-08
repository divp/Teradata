-- start HQL
select
   sum(ws_ext_discount_amt)  as Excess_Discount_Amount
from    
    web_sales ws
    join item i on (i.i_item_sk = ws.ws_item_sk)
    join date_dim d on (d.d_date_sk = ws.ws_sold_date_sk)
    cross join (SELECT avg(cast(ws_ext_discount_amt as double)) as adj_discount_amt FROM web_sales ws join date_dim d on (d.d_date_sk = ws.ws_sold_date_sk) join item i on (i.i_item_sk = ws.ws_item_sk) WHERE d_date between '1998-03-09' and date_add(cast('1998-03-09' as date), 90 ) and i_manufact_id = 71) iavg
where i_manufact_id = 71
and d_date between '1998-03-09' and date_add(cast('1998-03-09' as date), 90 )
and (ws_ext_discount_amt/1.3) > adj_discount_amt
--and ws_ext_discount_amt > 1.3*adj_discount_amt
order by Excess_Discount_Amount
limit 100;

-- end query 23 in stream 0 using template q92.tpl
