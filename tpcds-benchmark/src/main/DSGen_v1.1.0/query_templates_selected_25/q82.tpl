 define YEAR=random(1998,2002,uniform);
 define PRICE=random(0,90,uniform);
 define INVDATE=date([YEAR]+"-01-01",[YEAR]+"-07-24",sales);
 define MANUFACT_ID=ulist(random(1,1000,uniform),4);
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

select  [_LIMITA] i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, store_sales
 where i_current_price between [PRICE] and [PRICE]+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('[INVDATE]' as date) and (cast('[INVDATE]' as date) +  60 )
 and i_manufact_id in ([MANUFACT_ID.1],[MANUFACT_ID.2],[MANUFACT_ID.3],[MANUFACT_ID.4])
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
;

 [AGGG]
 [AGGH]
 [AGGI]

select  i_item_id
       ,i_item_desc
       ,i_current_price
 from item im
 join inventory i on ( i.inv_item_sk = im.i_item_sk)
 join date_dim d on (d.d_date_sk=i.inv_date_sk)
 join store_sales ss on (ss.ss_item_sk = im.i_item_sk)
 where i_current_price between [PRICE] and [PRICE]+30
 and d_date between cast('[INVDATE]' as date) and date_add(cast('[INVDATE]' as date),60)
 and i_manufact_id in ([MANUFACT_ID.1],[MANUFACT_ID.2],[MANUFACT_ID.3],[MANUFACT_ID.4])
 and inv_quantity_on_hand between 100 and 500
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
[_LIMITC];
