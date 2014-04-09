 define AGGC= text({"ss_ext_sales_price",1},{"ss_sales_price",1},{"ss_ext_discount_amt",1},{"ss_net_profit",1});
 define MONTH = random(11,12,uniform);
 define MANUFACT= random(1,1000,uniform);
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

select [_LIMITA] dt.d_year 
       ,item.i_brand_id brand_id 
       ,item.i_brand brand
       ,cast(sum([AGGC]) as decimal(18,2)) sum_agg
 from  date_dim dt 
      ,store_sales
      ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and item.i_manufact_id = [MANUFACT]
   and dt.d_moy=[MONTH]
 group by dt.d_year
      ,item.i_brand
      ,item.i_brand_id
 order by dt.d_year
         ,sum_agg desc
         ,brand_id
;

 [AGGG]
 [AGGH]
 [AGGI]

select  dt.d_year
        ,i.i_brand_id brand_id
        ,i.i_brand brand
        ,sum([AGGC]) as sum_agg
from   date_dim dt 
        join store_sales ss on (dt.d_date_sk = ss.ss_sold_date_sk)
        join item i on (ss.ss_item_sk = i.i_item_sk)
where i.i_manufact_id = [MANUFACT]
  and dt.d_moy=[MONTH]
group by       dt.d_year
                ,i.i_brand
                ,i.i_brand_id
order by       d_year
                ,sum_agg desc
                ,brand_id
[_LIMITC];
