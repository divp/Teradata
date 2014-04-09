
select * from (
select count(*) cnt, 'call_center' as tbl from call_center
union all
select count(*) cnt, 'catalog_page' as tbl from catalog_page
union all
select count(*) cnt, 'catalog_returns' as tbl from catalog_returns
union all
select count(*) cnt, 'catalog_sales' as tbl from catalog_sales
union all
select count(*) cnt, 'customer' as tbl from customer
union all
select count(*) cnt, 'customer_address' as tbl from customer_address
union all
select count(*) cnt, 'customer_demographics' as tbl from customer_demographics
union all
select count(*) cnt, 'date_dim' as tbl from date_dim
union all
select count(*) cnt, 'household_demographics' as tbl from household_demographics
union all
select count(*) cnt, 'income_band' as tbl from income_band
union all
select count(*) cnt, 'inventory' as tbl from inventory
union all
select count(*) cnt, 'item' as tbl from item
union all
select count(*) cnt, 'promotion' as tbl from promotion
union all
select count(*) cnt, 'reason' as tbl from reason
union all
select count(*) cnt, 'ship_mode' as tbl from ship_mode
union all
select count(*) cnt, 'store' as tbl from store
union all
select count(*) cnt, 'store_returns' as tbl from store_returns
union all
select count(*) cnt, 'store_sales' as tbl from store_sales
union all
select count(*) cnt, 'time_dim' as tbl from time_dim
union all
select count(*) cnt, 'warehouse' as tbl from warehouse
union all
select count(*) cnt, 'web_page' as tbl from web_page
union all
select count(*) cnt, 'web_returns' as tbl from web_returns
union all
select count(*) cnt, 'web_sales' as tbl from web_sales
union all
select count(*) cnt, 'web_site' as tbl from web_site
) x
order by cnt asc
LIMIT 100
;
