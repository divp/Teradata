define IMID  = random(1,1000,uniform);
define YEAR  = random(1998,2002,uniform);
define WSDATE = date([YEAR]+"-01-01",[YEAR]+"-04-01",sales);
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
   cast(sum(ws_ext_discount_amt) as decimal(18,2))  as "Excess Discount Amount"
from
    web_sales
   ,item
   ,date_dim
where
i_manufact_id = [IMID]
and i_item_sk = ws_item_sk
and d_date between '[WSDATE]' and
        (cast('[WSDATE]' as date) + 90 )
and d_date_sk = ws_sold_date_sk
and ws_ext_discount_amt
     > (
         SELECT
            1.3 * avg(ws_ext_discount_amt)
         FROM
            web_sales
           ,date_dim
         WHERE
              ws_item_sk = i_item_sk
          and d_date between '[WSDATE]' and
                             (cast('[WSDATE]' as date) + 90 )
          and d_date_sk = ws_sold_date_sk
      )
order by sum(ws_ext_discount_amt)
;


 [AGGG]
 [AGGH]
 [AGGI]

select
   sum(ws_ext_discount_amt)  as Excess_Discount_Amount
from    
    web_sales ws
    join item i on (i.i_item_sk = ws.ws_item_sk)
    join date_dim d on (d.d_date_sk = ws.ws_sold_date_sk)
    cross join (SELECT avg(cast(ws_ext_discount_amt as double)) as adj_discount_amt FROM web_sales ws join date_dim d on (d.d_date_sk = ws.ws_sold_date_sk) join item i on (i.i_item_sk = ws.ws_item_sk) WHERE d_date between '[WSDATE]' and date_add(cast('[WSDATE]' as date), 90 ) and i_manufact_id = [IMID]) iavg
where i_manufact_id = [IMID]
and d_date between '[WSDATE]' and date_add(cast('[WSDATE]' as date), 90 )
and (ws_ext_discount_amt/1.3) > adj_discount_amt
--and ws_ext_discount_amt > 1.3*adj_discount_amt
order by Excess_Discount_Amount
[_LIMITC];


