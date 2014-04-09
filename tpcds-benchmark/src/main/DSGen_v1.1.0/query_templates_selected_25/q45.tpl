 define GBOBC= text({"ca_city",1},{"ca_county",1},{"ca_state",1});
 define YEAR=random(1998,2002,uniform);
 define QOY=random(1,2,uniform);
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

select [_LIMITA] ca_zip, [GBOBC], sum(ws_sales_price)
 from web_sales, customer, customer_address, date_dim, item
 where ws_bill_customer_sk = c_customer_sk
        and c_current_addr_sk = ca_address_sk 
        and ws_item_sk = i_item_sk 
        and ( substr(ca_zip,1,5) in ('85669', '86197','88274','83405','86475', '85392', '85460', '80348', '81792')
              or 
              i_item_id in (select i_item_id
                             from item
                             where i_item_sk in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
                             )
            )
        and ws_sold_date_sk = d_date_sk
        and d_qoy = [QOY] and d_year = [YEAR]
 group by ca_zip, [GBOBC]
 order by ca_zip, [GBOBC]
;

 [AGGG]
 [AGGH]
 [AGGI]


select  ca_zip, [GBOBC], sum(ws_sales_price)
from web_sales ws
join customer c on (ws.ws_bill_customer_sk = c.c_customer_sk)
join customer_address ca on (c.c_current_addr_sk = ca.ca_address_sk)
join date_dim d  on (ws.ws_sold_date_sk = d.d_date_sk)
join item i on (ws.ws_item_sk = i.i_item_sk)
left outer join (select i_item_id from item where i_item_sk in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29) group by i_item_id) i2 on (i.i_item_id = i2.i_item_id)
where ( substr(ca_zip,1,5) in ('85669', '86197','88274','83405','86475', '85392', '85460', '80348', '81792')
           or
         i2.i_item_id is not null
       )
     and d_qoy = [QOY] and d_year = [YEAR]
group by ca_zip, [GBOBC]
order by ca_zip, [GBOBC]
[_LIMITC];
