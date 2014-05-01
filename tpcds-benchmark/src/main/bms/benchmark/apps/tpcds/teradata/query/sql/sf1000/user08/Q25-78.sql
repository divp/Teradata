-- start query 19 in stream 0 using template q78.tpl and seed 1533786386

.set retlimit 100
.set retcancel on
with ws(ws_sold_year,ws_item_sk,ws_customer_sk,ws_qty,ws_wc,ws_sp)  as
  (select d_year AS ws_sold_year, ws_item_sk,
    ws_bill_customer_sk ws_customer_sk,
    sum(ws_quantity) ws_qty,
    sum(ws_wholesale_cost) ws_wc,
    sum(ws_sales_price) ws_sp
   from web_sales
   left join web_returns on wr_order_number=ws_order_number and ws_item_sk=wr_item_sk
   join date_dim on ws_sold_date_sk = d_date_sk
   where wr_order_number is null
   group by d_year, ws_item_sk, ws_bill_customer_sk
   ),
cs1(cs_sold_year,cs_item_sk,cs_customer_sk,cs_qty,cs_wc,cs_sp) as
  (select d_year AS cs_sold_year, cs_item_sk,
    cs_bill_customer_sk cs_customer_sk,
    sum(cs_quantity) cs_qty,
    sum(cs_wholesale_cost) cs_wc,
    sum(cs_sales_price) cs_sp
   from catalog_sales
   left join catalog_returns on cr_order_number=cs_order_number and cs_item_sk=cr_item_sk
   join date_dim on cs_sold_date_sk = d_date_sk
   where cr_order_number is null
   group by d_year, cs_item_sk, cs_bill_customer_sk
   ),
ss1(ss_sold_year, ss_item_sk,ss_customer_sk,ss_qty, ss_wc,ss_sp) as
  (select d_year AS ss_sold_year, ss_item_sk,
    ss_customer_sk,
    sum(ss_quantity) ss_qty,
    sum(ss_wholesale_cost) ss_wc,
    sum(ss_sales_price) ss_sp
   from store_sales
   left join store_returns on sr_ticket_number=ss_ticket_number and ss_item_sk=sr_item_sk
   join date_dim on ss_sold_date_sk = d_date_sk
   where sr_ticket_number is null
   group by d_year, ss_item_sk, ss_customer_sk
   )
 select top 100
 ss_sold_year, ss_item_sk, ss_customer_sk, round(ss_qty/(coalesce(ws_qty+cs_qty,1)),2) ratio,
 ss_qty store_qty, ss_wc store_wholesale_cost, ss_sp store_sales_price,
 coalesce(ws_qty,0)+coalesce(cs_qty,0) other_chan_qty,
 coalesce(ws_wc,0)+coalesce(cs_wc,0) other_chan_wholesale_cost,
 coalesce(ws_sp,0)+coalesce(cs_sp,0) other_chan_sales_price
from ss1
left join ws on (ws_sold_year=ss_sold_year and ws_item_sk=ss_item_sk and ws_customer_sk=ss_customer_sk)
left join cs1 on (cs_sold_year=ss_sold_year and cs_item_sk=cs_item_sk and cs_customer_sk=ss_customer_sk)
where coalesce(ws_qty,0)>0 and coalesce(cs_qty, 0)>0 and ss_sold_year=1999
order by 
 ss_sold_year, ss_item_sk, ss_customer_sk,
 ss_qty desc, ss_wc desc, ss_sp desc,
 coalesce(ws_qty,0)+coalesce(cs_qty,0),
 coalesce(ws_wc,0)+coalesce(cs_wc,0),
 coalesce(ws_sp,0)+coalesce(cs_sp,0),
 round(ss_qty/(coalesce(ws_qty+cs_qty,1)),2)
;
