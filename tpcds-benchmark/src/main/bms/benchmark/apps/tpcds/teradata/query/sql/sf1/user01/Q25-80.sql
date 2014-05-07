-- start query 20 in stream 0 using template q80.tpl and seed 1532660774



with ssr(store_id,sales,returns1,profit) as
 (select  s_store_id as store_id,
          cast(sum(ss_ext_sales_price) as decimal(18,2)) as sales,
          cast(sum(coalesce(sr_return_amt, 0)) as decimal(18,2)) as returns1,
          cast(sum(ss_net_profit - coalesce(sr_net_loss, 0)) as decimal(18,2)) as profit
  from store_sales left outer join store_returns on
         (ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number),
     date_dim,
     store,
     item,
     promotion
 where ss_sold_date_sk = d_date_sk
       and d_date between cast('2001-08-09' as date) 
                  and (cast('2001-08-09' as date) +  30 )
       and ss_store_sk = s_store_sk
       and ss_item_sk = i_item_sk
       and i_current_price > 50
       and ss_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
 group by s_store_id)
 ,
 csr(catalog_page_id,sales,returns1,profit) as
 (select  cp_catalog_page_id as catalog_page_id,
          cast(sum(cs_ext_sales_price) as decimal(18,2)) as sales,
          cast(sum(coalesce(cr_return_amount, 0)) as decimal(18,2)) as returns1,
          cast(sum(cs_net_profit - coalesce(cr_net_loss, 0)) as decimal(18,2)) as profit
  from catalog_sales left outer join catalog_returns on
         (cs_item_sk = cr_item_sk and cs_order_number = cr_order_number),
     date_dim,
     catalog_page,
     item,
     promotion
 where cs_sold_date_sk = d_date_sk
       and d_date between cast('2001-08-09' as date)
                  and (cast('2001-08-09' as date) +  30 )
        and cs_catalog_page_sk = cp_catalog_page_sk
       and cs_item_sk = i_item_sk
       and i_current_price > 50
       and cs_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by cp_catalog_page_id)
 ,
 wsr(web_site_id,sales,returns1, profit) as
 (select  web_site_id,
          cast(sum(ws_ext_sales_price) as decimal(18,2)) as sales,
          cast(sum(coalesce(wr_return_amt, 0)) as decimal(18,2)) as returns1,
          cast(sum(ws_net_profit - coalesce(wr_net_loss, 0)) as decimal(18,2)) as profit
  from web_sales left outer join web_returns on
         (ws_item_sk = wr_item_sk and ws_order_number = wr_order_number),
     date_dim,
     web_site,
     item,
     promotion
 where ws_sold_date_sk = d_date_sk
       and d_date between cast('2001-08-09' as date)
                  and (cast('2001-08-09' as date) +  30 )
        and ws_web_site_sk = web_site_sk
       and ws_item_sk = i_item_sk
       and i_current_price > 50
       and ws_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by web_site_id)
  select top 100 channel
        , id
        , sum(sales) as sales
        , sum(returns1) as returns1
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , 'store' || store_id as id
        , sales
        , returns1
        , profit
 from   ssr
 union all
 select 'catalog channel' as channel
        , 'catalog_page' || catalog_page_id as id
        , sales
        , returns1
        , profit
 from  csr
 union all
 select 'web channel' as channel
        , 'web_site' || web_site_id as id
        , sales
        , returns1
        , profit
 from   wsr
 ) x
 group by rollup (channel, id)
 order by channel
         ,id
;

