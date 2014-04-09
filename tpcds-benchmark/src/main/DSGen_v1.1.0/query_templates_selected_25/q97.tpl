define YEAR=random(1998,2002, uniform);
define DMS = random(1176,1224, uniform); -- Qualification: 1200
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

with ssci ( customer_sk,  item_sk) as (
select ss_customer_sk customer_sk
      ,ss_item_sk item_sk
from store_sales,date_dim
where ss_sold_date_sk = d_date_sk
  and d_month_seq between [DMS] and [DMS] + 11
  /* and d_year=[YEAR] */
group by ss_customer_sk
        ,ss_item_sk),
csci (customer_sk, item_sk) as (
 select cs_bill_customer_sk customer_sk
      ,cs_item_sk item_sk
from catalog_sales,date_dim
where cs_sold_date_sk = d_date_sk
  and d_month_seq between [DMS] and [DMS] + 11
  /* and d_year=[YEAR] */
group by cs_bill_customer_sk
        ,cs_item_sk)
 select [_LIMITA] sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 else 0 end) store_only
      ,sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1 else 0 end) catalog_only
      ,sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 else 0 end) store_and_catalog
from ssci full outer join csci on (ssci.customer_sk=csci.customer_sk
                               and ssci.item_sk = csci.item_sk)
;


 [AGGG]
 [AGGH]
 [AGGI]


select  sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 else 0 end) store_only
       ,sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1 else 0 end) catalog_only
       ,sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 else 0 end) store_and_catalog
from (select ss_customer_sk customer_sk,ss_item_sk item_sk from store_sales aa inner join date_dim bb on (aa.ss_sold_date_sk = bb.d_date_sk) where d_month_seq between [DMS] and [DMS] + 11 group by ss_customer_sk,ss_item_sk) ssci full outer join (select cs_bill_customer_sk customer_sk,cs_item_sk item_sk from catalog_sales aaa inner join date_dim bbb on (aaa.cs_sold_date_sk = bbb.d_date_sk) where d_month_seq between [DMS] and [DMS] + 11 group by cs_bill_customer_sk, cs_item_sk) csci on (ssci.customer_sk = csci.customer_sk and ssci.item_sk = csci.item_sk)
[_LIMITC];


