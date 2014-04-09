define YEAR = random(1998, 2002, uniform);
define DMS = random(1176,1224,uniform); -- Qualification: 1176
define _LIMIT=100;
 define AGGD= text({".set retlimit 100",1});
 define AGGE= text({".set retcancel on",1});
 define AGGF= text({"",1});
 define AGGG= text({"",1});
 define AGGH= text({"-- start HQL",1});
 define AGGI= text({"",1});

 [AGGD]
 [AGGE]
 [AGGF]

WITH web_v1(item_sk, d_date,cume_sales) as (
select
  ws_item_sk item_sk, d_date,
  sum(sum(ws_sales_price))
      over (partition by ws_item_sk order by d_date rows between unbounded preceding and current row) cume_sales
from web_sales
    ,date_dim
where ws_sold_date_sk=d_date_sk
   and d_month_seq between [DMS] and [DMS]+11
  /* and d_year=[YEAR] */
  and ws_item_sk is not NULL
group by ws_item_sk, d_date),
store_v1(item_sk, d_date,cume_sales) as (
select
  ss_item_sk item_sk, d_date,
  sum(sum(ss_sales_price))
      over (partition by ss_item_sk order by d_date rows between unbounded preceding and current row) cume_sales
from store_sales
    ,date_dim
where ss_sold_date_sk=d_date_sk
  and d_month_seq between [DMS] and [DMS]+11
  /* and d_year=[YEAR] */
  and ss_item_sk is not NULL
group by ss_item_sk, d_date)
 select [_LIMITA] *
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
           from web_v1 web full outer join store_v1 store on (web.item_sk = store.item_sk
                                                          and web.d_date = store.d_date)
          )x )y
where web_cumulative > store_cumulative
order by item_sk
        ,d_date
;

 [AGGG]
 [AGGH]
 [AGGI]

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
             where d_month_seq between [DMS] and [DMS]+11
             and ws_item_sk is not NULL
             group by ws_item_sk,d_date
             ) x
           ) web full outer join (
             select item_sk,d_date,sum(ss_sales_price) over (partition by item_sk order by d_date rows between unbounded preceding and current row) cume_sales
             from (
             select ss_item_sk item_sk, d_date,sum(ss_sales_price) ss_sales_price
             from store_sales ss
             join date_dim d on (ss.ss_sold_date_sk=d.d_date_sk)
             where d_month_seq between [DMS] and [DMS]+11
             and ss_item_sk is not NULL
             group by ss_item_sk, d_date
             ) x
           ) store on (web.item_sk = store.item_sk and web.d_date = store.d_date)
     )x 
)y
where web_cumulative > store_cumulative
order by item_sk
        ,d_date
[_LIMITC];
