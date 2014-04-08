-- start HQL
select  *
from (select item_sk
     ,d_date
     ,web_sales
     ,store_sales
     ,max(web_sales)
         over (partition by item_sk order by d_date rows between unbounded preceding and current row) web_cumulative
     ,max(store_sales)
         over (partition by item_sk order by d_date rows between unbounded preceding and current row) store_cumulative
     from (select case when web.item_sk is not null then web.item_sk else store.item_sk end item_sk
                 ,case when web.d_date is not null then web.d_date else store.d_date end d_date
                 ,web.cume_sales web_sales
                 ,store.cume_sales store_sales
           from (
             select item_sk,d_date,sum(ws_sales_price) over (partition by item_sk order by d_date rows between unbounded preceding and current row) as cume_sales
             from (
             select ws_item_sk item_sk, d_date, sum(ws_sales_price) ws_sales_price
             from web_sales ws
             join date_dim d on (ws.ws_sold_date_sk=d.d_date_sk)
             where d_month_seq between 1188 and 1188+11
             and ws_item_sk is not NULL
             group by ws_item_sk,d_date
             ) x
           ) web full outer join (
             select item_sk,d_date,sum(ss_sales_price) over (partition by item_sk order by d_date rows between unbounded preceding and current row) cume_sales
             from (
             select ss_item_sk item_sk, d_date,sum(ss_sales_price) ss_sales_price
             from store_sales ss
             join date_dim d on (ss.ss_sold_date_sk=d.d_date_sk)
             where d_month_seq between 1188 and 1188+11
             and ss_item_sk is not NULL
             group by ss_item_sk, d_date
             ) x
           ) store on (web.item_sk = store.item_sk and web.d_date = store.d_date)
     )x 
)y
where web_cumulative > store_cumulative
order by item_sk
        ,d_date
limit 100;

-- end query 15 in stream 0 using template q51.tpl
