define IMID  = random(1,1000,uniform); -- 255 for qualification
define YEAR  = random(1998,2002,uniform);
define CSDATE = date([YEAR]+"-01-01",[YEAR]+"-04-01",sales);
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

select [_LIMITA] sum(cs_ext_discount_amt) (dec(18,2))  as "excess discount amount" 
from 
   catalog_sales 
   ,item 
   ,date_dim
where
i_manufact_id = [IMID]
and i_item_sk = cs_item_sk 
and d_date between '[CSDATE]' and 
        (cast('[CSDATE]' as date) + 90 )
and d_date_sk = cs_sold_date_sk 
and cs_ext_discount_amt  
     > ( 
         select 
            1.3 * avg(cs_ext_discount_amt) 
         from 
            catalog_sales 
           ,date_dim
         where 
              cs_item_sk = i_item_sk 
          and d_date between '[CSDATE]' and
                             (cast('[CSDATE]' as date) + 90 )
          and d_date_sk = cs_sold_date_sk 
      ) 
;

 [AGGG]
 [AGGH]
 [AGGI]


select  sum(cs_ext_discount_amt)  as excess_discount_amount
from
    catalog_sales cs
    join item i on (i.i_item_sk = cs.cs_item_sk)
    join date_dim d on (d.d_date_sk = cs.cs_sold_date_sk)
    cross join (
         select avg(cast(cs_ext_discount_amt as double)) as adj_discount_amt
         from catalog_sales cs2
         join item i2 on (i2.i_item_sk = cs2.cs_item_sk)
         join date_dim d2 on (d2.d_date_sk = cs2.cs_sold_date_sk)
         where d_date between '[CSDATE]' and date_add(cast('[CSDATE]' as date),90)
         and i2.i_manufact_id = [IMID]
     ) s 
where 
     i_manufact_id = [IMID]
 and d_date between '[CSDATE]' and 
                    date_add(cast('[CSDATE]' as date),90)
and (cs.cs_ext_discount_amt / 1.3) > s.adj_discount_amt
[_LIMITC];
