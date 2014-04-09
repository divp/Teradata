define YEAR=random(1998, 2002, uniform);
define _LIMIT = 100;
 define AGGD= text({".set retlimit 100",1});
 define AGGE= text({".set retcancel on",1});
 define AGGF= text({"",1});
 define AGGG= text({"",1});
 define AGGH= text({"-- start HQL",1});
 define AGGI= text({"",1});

 [AGGD]
 [AGGE]
 [AGGF]

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
 select [_LIMITA]
 ss_sold_year, ss_item_sk, ss_customer_sk, round(ss_qty/(coalesce(ws_qty+cs_qty,1)),2) ratio,
 ss_qty store_qty, ss_wc store_wholesale_cost, ss_sp store_sales_price,
 coalesce(ws_qty,0)+coalesce(cs_qty,0) other_chan_qty,
 coalesce(ws_wc,0)+coalesce(cs_wc,0) other_chan_wholesale_cost,
 coalesce(ws_sp,0)+coalesce(cs_sp,0) other_chan_sales_price
from ss1
left join ws on (ws_sold_year=ss_sold_year and ws_item_sk=ss_item_sk and ws_customer_sk=ss_customer_sk)
left join cs1 on (cs_sold_year=ss_sold_year and cs_item_sk=cs_item_sk and cs_customer_sk=ss_customer_sk)
where coalesce(ws_qty,0)>0 and coalesce(cs_qty, 0)>0 and ss_sold_year=[YEAR]
order by 
 ss_sold_year, ss_item_sk, ss_customer_sk,
 ss_qty desc, ss_wc desc, ss_sp desc,
 coalesce(ws_qty,0)+coalesce(cs_qty,0),
 coalesce(ws_wc,0)+coalesce(cs_wc,0),
 coalesce(ws_sp,0)+coalesce(cs_sp,0),
 round(ss_qty/(coalesce(ws_qty+cs_qty,1)),2)
;


 [AGGG]
 [AGGH]
 [AGGI]

select
ss.ss_sold_year, ss_item_sk, ss_customer_sk,
round(ss.ss_qty/(coalesce(ws_qty+cs_qty,1)),2) ratio,
ss.ss_qty store_qty, ss_wc store_wholesale_cost, ss_sp store_sales_price,
coalesce(ws_qty,0)+coalesce(cs_qty,0) other_chan_qty,
coalesce(ws_wc,0)+coalesce(cs_wc,0) other_chan_wholesale_cost,
coalesce(ws_sp,0)+coalesce(cs_sp,0) other_chan_sales_price
from (select d_year AS ss_sold_year, ss_item_sk, ss_customer_sk, sum(ss_quantity) ss_qty, sum(ss_wholesale_cost) ss_wc, sum(ss_sales_price) ss_sp from store_sales a left join store_returns b on (b.sr_ticket_number=a.ss_ticket_number and a.ss_item_sk=b.sr_item_sk) join date_dim c on a.ss_sold_date_sk = c.d_date_sk where b.sr_ticket_number is null group by d_year, ss_item_sk, ss_customer_sk) ss
left join (select d_year AS ws_sold_year, ws_item_sk, ws_bill_customer_sk ws_customer_sk, sum(ws_quantity) ws_qty, sum(ws_wholesale_cost) ws_wc, sum(ws_sales_price) ws_sp from web_sales a left join web_returns b on (b.wr_order_number=a.ws_order_number and a.ws_item_sk=b.wr_item_sk) join date_dim c on (a.ws_sold_date_sk = c.d_date_sk) where b.wr_order_number is null group by d_year, ws_item_sk, ws_bill_customer_sk) ws on (ws.ws_sold_year=ss.ss_sold_year and ws.ws_item_sk=ss.ss_item_sk and ws.ws_customer_sk=ss.ss_customer_sk)
left join (select d_year AS cs_sold_year, cs_item_sk, cs_bill_customer_sk cs_customer_sk, sum(cs_quantity) cs_qty, sum(cs_wholesale_cost) cs_wc, sum(cs_sales_price) cs_sp from catalog_sales a left join catalog_returns b on (b.cr_order_number=a.cs_order_number and a.cs_item_sk=b.cr_item_sk) join date_dim c on (a.cs_sold_date_sk = c.d_date_sk) where b.cr_order_number is null group by d_year, cs_item_sk, cs_bill_customer_sk) cs on (cs.cs_sold_year=ss.ss_sold_year and cs.cs_item_sk=cs.cs_item_sk and cs.cs_customer_sk=ss.ss_customer_sk)
where coalesce(ws.ws_qty,0)>0 and coalesce(cs.cs_qty, 0)>0 and ss.ss_sold_year=[YEAR]
order by
  ss_sold_year, ss_item_sk, ss_customer_sk,
  store_qty desc, store_wholesale_cost desc, store_sales_price desc,
  other_chan_qty,
  other_chan_wholesale_cost,
  other_chan_sales_price,
  ratio
[_LIMITC];
