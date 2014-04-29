
USE orc_tpcds1000g;

select * from (
select count(*) cnt, 'store_sales' tbl from store_sales
UNION ALL
select count(*) cnt, 's_purchase' tbl from s_purchase
UNION ALL
select count(*) cnt, 's_purchase_lineitem' tbl from s_purchase_lineitem
UNION ALL
select count(*) cnt, 'customer' tbl from customer
UNION ALL
select count(*) cnt, 'store' tbl from store
UNION ALL
select count(*) cnt, 'date_dim' tbl from date_dim
UNION ALL
select count(*) cnt, 'time_dim' tbl from time_dim
UNION ALL
select count(*) cnt, 'promotion' tbl from promotion
UNION ALL
select count(*) cnt, 'item' tbl from item
) result;
