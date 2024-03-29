-- start query 25 in stream 0 using template q97.tpl and seed 1193799387



with ssci ( customer_sk,  item_sk) as (
select ss_customer_sk customer_sk
      ,ss_item_sk item_sk
from store_sales,date_dim
where ss_sold_date_sk = d_date_sk
  and d_month_seq between 1218 and 1218 + 11
  /* and d_year=2000 */
group by ss_customer_sk
        ,ss_item_sk),
csci (customer_sk, item_sk) as (
 select cs_bill_customer_sk customer_sk
      ,cs_item_sk item_sk
from catalog_sales,date_dim
where cs_sold_date_sk = d_date_sk
  and d_month_seq between 1218 and 1218 + 11
  /* and d_year=2000 */
group by cs_bill_customer_sk
        ,cs_item_sk)
 select top 100 sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 else 0 end) store_only
      ,sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1 else 0 end) catalog_only
      ,sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 else 0 end) store_and_catalog
from ssci full outer join csci on (ssci.customer_sk=csci.customer_sk
                               and ssci.item_sk = csci.item_sk)
;

