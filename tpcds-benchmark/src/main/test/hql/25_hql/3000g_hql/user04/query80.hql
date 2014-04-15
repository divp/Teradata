-- start HQL
select  channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
from
  (select 'store channel' as channel
        , substr(concat('store',store_id),1,21) as id
        , sales
        , returns
        , profit
from    (select  s_store_id as store_id,
          sum(ss_ext_sales_price) as sales,
          sum(coalesce(sr_return_amt, 0)) as returns,
          sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit
  from store_sales ss 
  join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk)
  join store s on (ss.ss_store_sk = s.s_store_sk)
  join item i on (ss.ss_item_sk = i.i_item_sk)
  join promotion p on (ss.ss_promo_sk = p.p_promo_sk)
  left outer join store_returns sr on (ss.ss_item_sk = sr.sr_item_sk and ss.ss_ticket_number = sr.sr_ticket_number)
where d_date between cast('2000-08-06' as date) and date_add(cast('2000-08-06' as date), 30 )
   and i_current_price > 50
   and p_channel_tv = 'N'
group by s_store_id) ssr

 union all
select 'catalog channel' as channel
        , substr(concat('catalog_page',catalog_page_id),1,21) as id
        , sales
        , returns
        , profit
from  
  (select  cp_catalog_page_id as catalog_page_id,
          sum(cs_ext_sales_price) as sales,
          sum(coalesce(cr_return_amount, 0)) as returns,
          sum(cs_net_profit - coalesce(cr_net_loss, 0)) as profit
  from catalog_sales cs 
  join date_dim d on (cs.cs_sold_date_sk = d.d_date_sk)
  join catalog_page cp on (cs.cs_catalog_page_sk = cp.cp_catalog_page_sk)
  join item i on (cs.cs_item_sk = i.i_item_sk)
  join promotion p on (cs.cs_promo_sk = p.p_promo_sk)
  left outer join catalog_returns cr on (cs.cs_item_sk = cr.cr_item_sk and cs.cs_order_number = cr.cr_order_number)
where d_date between cast('2000-08-06' as date) and date_add(cast('2000-08-06' as date), 30 )
   and i_current_price > 50
   and p_channel_tv = 'N'
group by cp_catalog_page_id) csr

union all
select 'web channel' as channel
        , substr(concat('web_site',web_site_id),1,21) as id
        , sales
        , returns
        , profit
from
(select  web_site_id,
          sum(ws_ext_sales_price) as sales,
          sum(coalesce(wr_return_amt, 0)) as returns,
          sum(ws_net_profit - coalesce(wr_net_loss, 0)) as profit
  from web_sales ws
     join date_dim d on (ws.ws_sold_date_sk = d.d_date_sk)
     join web_site w on (ws.ws_web_site_sk = w.web_site_sk)
     join item i on (ws.ws_item_sk = i.i_item_sk)
     join promotion p on (ws.ws_promo_sk = p.p_promo_sk)
     left outer join web_returns wr on (ws.ws_item_sk = wr.wr_item_sk and ws.ws_order_number = wr.wr_order_number)
where d_date between cast('2000-08-06' as date) and date_add(cast('2000-08-06' as date), 30 )
   and i_current_price > 50
   and p_channel_tv = 'N'
group by web_site_id) wsr
) x
group by channel, id with rollup
order by channel,id
limit 100;

-- end query 20 in stream 0 using template q80.tpl
