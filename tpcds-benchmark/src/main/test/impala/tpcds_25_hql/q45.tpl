-- q45
select  ca_zip, ca_county, sum(ws_sales_price)
from web_sales ws
join customer c on (ws.ws_bill_customer_sk = c.c_customer_sk)
join customer_address ca on (c.c_current_addr_sk = ca.ca_address_sk)
join date_dim d  on (ws.ws_sold_date_sk = d.d_date_sk)
join item i on (ws.ws_item_sk = i.i_item_sk)
left outer join (select i_item_id from item where i_item_sk in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29) group by i_item_id) i2 on (i.i_item_id = i2.i_item_id)
where ( substr(ca_zip,1,5) in ('85669', '86197','88274','83405','86475', '85392', '85460', '80348', '81792')
           or
         i2.i_item_id is not null
       )
     and d_qoy = 2 and d_year = 2000
group by ca_zip, ca_county
order by ca_zip, ca_county
limit 100
;
