
 define MONTH = random(11,12,uniform);
 define YEAR = random(1998,2002,uniform);
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
        ,item.i_category_id
        ,item.i_category
        ,cast(sum(ss_ext_sales_price) as decimal(18,2))
 from   date_dim dt
        ,store_sales
        ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
        and store_sales.ss_item_sk = item.i_item_sk
        and item.i_manager_id = 1  
        and dt.d_moy=[MONTH]
        and dt.d_year=[YEAR]
 group by       dt.d_year
                ,item.i_category_id
                ,item.i_category
 order by       sum(ss_ext_sales_price) desc,dt.d_year
                ,item.i_category_id
                ,item.i_category
;

 [AGGG]
 [AGGH]
 [AGGI]

select  dt.d_year
        ,i.i_category_id
        ,i.i_category
        ,sum(ss_ext_sales_price) as ext_p
from   date_dim dt 
        join store_sales ss on (dt.d_date_sk = ss.ss_sold_date_sk)
        join item i on (ss.ss_item_sk = i.i_item_sk)
where i.i_manager_id = 1
        and dt.d_moy=[MONTH]
        and dt.d_year=[YEAR]
group by       dt.d_year
                ,i.i_category_id
                ,i.i_category
order by       ext_p desc,d_year
                ,i_category_id
                ,i_category
[_LIMITC];
