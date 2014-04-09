 define AGG= text({"sum",1},{"min",1},{"max",1},{"avg",1},{"stddev_samp",1}); -- for qualification sum 
 define YEAR= random(1998,2000, uniform); -- for qualification 1998 
 define MONTH = random(4,4,uniform); -- for qualification 3 
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
 
select [_LIMITA]
     i_item_id
    ,i_item_desc
    ,s_store_id
    ,s_store_name
    ,[AGG](ss_quantity)        as store_sales_quantity
    ,[AGG](sr_return_quantity) as store_returns_quantity
    ,[AGG](cs_quantity)        as catalog_sales_quantity
 from
    store_sales
   ,store_returns
   ,catalog_sales
   ,date_dim             d1
   ,date_dim             d2
   ,date_dim             d3
   ,store
   ,item
 where
     d1.d_moy               = [MONTH] 
 and d1.d_year              = [YEAR]
 and d1.d_date_sk           = ss_sold_date_sk
 and i_item_sk              = ss_item_sk
 and s_store_sk             = ss_store_sk
 and ss_customer_sk         = sr_customer_sk
 and ss_item_sk             = sr_item_sk
 and ss_ticket_number       = sr_ticket_number
 and sr_returned_date_sk    = d2.d_date_sk
 and d2.d_moy               between [MONTH] and  [MONTH] + 3 
 and d2.d_year              = [YEAR]
 and sr_customer_sk         = cs_bill_customer_sk
 and sr_item_sk             = cs_item_sk
 and cs_sold_date_sk        = d3.d_date_sk     
 and (d3.d_year=[YEAR] or d3.d_year=[YEAR]+1 or d3.d_year=[YEAR]+2)
 group by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
 order by
    i_item_id 
   ,i_item_desc
   ,s_store_id
   ,s_store_name
;
 
 [AGGG]
 [AGGH]
 [AGGI]

select   
     i_item_id
    ,i_item_desc
    ,s_store_id
    ,s_store_name
    ,[AGG](ss_quantity)        as store_sales_quantity
    ,[AGG](sr_return_quantity) as store_returns_quantity
    ,[AGG](cs_quantity)        as catalog_sales_quantity
from
    store_sales ss
   join store_returns sr on (ss.ss_customer_sk = sr.sr_customer_sk and ss.ss_item_sk = sr.sr_item_sk and ss.ss_ticket_number = sr.sr_ticket_number)
   join catalog_sales cs on (sr.sr_customer_sk = cs.cs_bill_customer_sk and sr.sr_item_sk = cs.cs_item_sk)
   join date_dim d1 on (d1.d_date_sk = ss.ss_sold_date_sk)
   join date_dim d2 on (sr.sr_returned_date_sk = d2.d_date_sk)
   join date_dim d3 on (cs.cs_sold_date_sk = d3.d_date_sk)
   join store s on (s.s_store_sk = ss.ss_store_sk)
   join item i on (i.i_item_sk = ss.ss_item_sk)
where
    d1.d_moy               = [MONTH]
and d1.d_year              = [YEAR]
and d2.d_moy               between [MONTH] and  [MONTH] + 3
and d2.d_year              = [YEAR]
and d3.d_year              between [YEAR] and [YEAR]+2
group by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
order by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
[_LIMITC];
