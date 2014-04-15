-- q24
drop table if exists temp_ssales3299;
create table temp_ssales3299 as
select c_last_name
      ,c_first_name
      ,s_store_name
      ,ca_state
      ,s_state
      ,i_color
      ,i_current_price
      ,i_manager_id
      ,i_units
      ,i_size
      ,sum(ss_sales_price) netpaid
from store_sales ss 
     join store_returns sr on (ss.ss_ticket_number = sr.sr_ticket_number and ss.ss_item_sk = sr.sr_item_sk)
     join store s on (ss.ss_store_sk = s.s_store_sk)
     join item i on (ss.ss_item_sk = i.i_item_sk)
     join customer c on (ss.ss_customer_sk = c.c_customer_sk)
     join customer_address ca on (s.s_zip = ca.ca_zip and c.c_birth_country = upper(ca.ca_country))
where s_market_id = 7
group by c_last_name
        ,c_first_name
        ,s_store_name
        ,ca_state
        ,s_state
        ,i_color
        ,i_current_price
        ,i_manager_id
        ,i_units
        ,i_size
;
select c_last_name,c_first_name,s_store_name,paid
from (
select c_last_name
      ,c_first_name
      ,s_store_name
      ,sum(netpaid) paid
from temp_ssales3299
where i_color = 'orchid'
group by c_last_name
        ,c_first_name
        ,s_store_name
) a
cross join (select 0.05*avg(netpaid) as adj_netpaid from temp_ssales3299) b
where a.paid > b.adj_netpaid
;
select c_last_name,c_first_name,s_store_name,paid
from (
select c_last_name
      ,c_first_name
      ,s_store_name
      ,sum(netpaid) paid
from temp_ssales3299
where i_color = 'chiffon'
group by c_last_name
        ,c_first_name
        ,s_store_name
) a
cross join (select 0.05*avg(netpaid) as adj_netpaid from temp_ssales3299) b
where a.paid > b.adj_netpaid
;
drop table if exists temp_ssales3299;

