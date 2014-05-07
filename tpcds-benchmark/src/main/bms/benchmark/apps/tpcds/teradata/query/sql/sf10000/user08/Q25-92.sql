-- start query 23 in stream 0 using template q92.tpl and seed 1924035314



select top 100
   cast(sum(ws_ext_discount_amt) as decimal(18,2))  as "Excess Discount Amount"
from
    web_sales
   ,item
   ,date_dim
where
i_manufact_id = 315
and i_item_sk = ws_item_sk
and d_date between '1998-02-04' and
        (cast('1998-02-04' as date) + 90 )
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
          and d_date between '1998-02-04' and
                             (cast('1998-02-04' as date) + 90 )
          and d_date_sk = ws_sold_date_sk
      )
order by sum(ws_ext_discount_amt)
;

