-- start HQL
select  sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 else 0 end) store_only
       ,sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1 else 0 end) catalog_only
       ,sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 else 0 end) store_and_catalog
from (select ss_customer_sk customer_sk,ss_item_sk item_sk from store_sales aa inner join date_dim bb on (aa.ss_sold_date_sk = bb.d_date_sk) where d_month_seq between 1180 and 1180 + 11 group by ss_customer_sk,ss_item_sk) ssci full outer join (select cs_bill_customer_sk customer_sk,cs_item_sk item_sk from catalog_sales aaa inner join date_dim bbb on (aaa.cs_sold_date_sk = bbb.d_date_sk) where d_month_seq between 1180 and 1180 + 11 group by cs_bill_customer_sk, cs_item_sk) csci on (ssci.customer_sk = csci.customer_sk and ssci.item_sk = csci.item_sk)
limit 100;

-- end query 25 in stream 0 using template q97.tpl
