define MARKET=random(5,10,uniform);
define AMOUNTONE=text({"ss_net_paid",1},{"ss_net_paid_inc_tax",1},{"ss_net_profit",1},{"ss_sales_price",1},{"ss_ext_sales_price",1});
define COLOR=ulist(dist(colors,1,1),2);
 define AGGG= text({"",1});
 define AGGH= text({"-- start HQL",1});
 define AGGI= text({"",1});

with ssales( c_last_name,c_first_name ,s_store_name ,ca_state ,s_state ,i_color,i_current_price ,i_manager_id ,i_units,i_sizeas,netpaid) as
(select c_last_name
      ,c_first_name
      ,s_store_name
      ,ca_state
      ,s_state
      ,i_color
      ,i_current_price
      ,i_manager_id
      ,i_units
      ,i_size
      ,cast(sum([AMOUNTONE]) as decimal(18,2)) netpaid
from store_sales
    ,store_returns
    ,store
    ,item
    ,customer
    ,customer_address
where ss_ticket_number = sr_ticket_number
  and ss_item_sk = sr_item_sk
  and ss_customer_sk = c_customer_sk
  and ss_item_sk = i_item_sk
  and ss_store_sk = s_store_sk
  and c_birth_country = upper(ca_country)
  and s_zip = ca_zip
and s_market_id=[MARKET]
group by c_last_name
        ,c_first_name
        ,s_store_name
        ,ca_state
        ,s_state
        ,i_color
        ,i_current_price
        ,i_manager_id
        ,i_units
        ,i_size)
select c_last_name
      ,c_first_name
      ,s_store_name
      ,cast(sum(netpaid) as decimal(18,2)) paid
from ssales
where i_color = '[COLOR.1]'
group by c_last_name
        ,c_first_name
        ,s_store_name
having sum(netpaid) > (select 0.05*avg(netpaid)
                                 from ssales)
;

with ssales( c_last_name,c_first_name ,s_store_name ,ca_state ,s_state ,i_color,i_current_price ,i_manager_id ,i_units,i_sizeas,netpaid) as
(select c_last_name
      ,c_first_name
      ,s_store_name
      ,ca_state
      ,s_state
      ,i_color
      ,i_current_price
      ,i_manager_id
      ,i_units
      ,i_size
      ,cast(sum([AMOUNTONE]) as decimal(18,2)) netpaid
from store_sales
    ,store_returns
    ,store
    ,item
    ,customer
    ,customer_address
where ss_ticket_number = sr_ticket_number
  and ss_item_sk = sr_item_sk
  and ss_customer_sk = c_customer_sk
  and ss_item_sk = i_item_sk
  and ss_store_sk = s_store_sk
  and c_birth_country = upper(ca_country)
  and s_zip = ca_zip
  and s_market_id = [MARKET]
group by c_last_name
        ,c_first_name
        ,s_store_name
        ,ca_state
        ,s_state
        ,i_color
        ,i_current_price
        ,i_manager_id
        ,i_units
        ,i_size)
select c_last_name
      ,c_first_name
      ,s_store_name
      ,cast(sum(netpaid) as decimal(18,2)) paid
from ssales
where i_color = '[COLOR.2]'
group by c_last_name
        ,c_first_name
        ,s_store_name
having sum(netpaid) > (select 0.05*avg(netpaid)
                           from ssales)
;


 [AGGG]
 [AGGH]
 [AGGI]

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
      ,sum([AMOUNTONE]) netpaid
from store_sales ss 
     join store_returns sr on (ss.ss_ticket_number = sr.sr_ticket_number and ss.ss_item_sk = sr.sr_item_sk)
     join store s on (ss.ss_store_sk = s.s_store_sk)
     join item i on (ss.ss_item_sk = i.i_item_sk)
     join customer c on (ss.ss_customer_sk = c.c_customer_sk)
     join customer_address ca on (s.s_zip = ca.ca_zip and c.c_birth_country = upper(ca.ca_country))
where s_market_id = [MARKET]
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
where i_color = '[COLOR.1]'
group by c_last_name
        ,c_first_name
        ,s_store_name
) a
join (select 0.05*avg(netpaid) as adj_netpaid from temp_ssales3299) b on (1=1)
where a.paid > b.adj_netpaid
;
select c_last_name,c_first_name,s_store_name,paid
from (
select c_last_name
      ,c_first_name
      ,s_store_name
      ,cast(sum(netpaid) as decimal(18,2)) paid
from temp_ssales3299
where i_color = '[COLOR.2]'
group by c_last_name
        ,c_first_name
        ,s_store_name
) a
join (select 0.05*avg(netpaid) as adj_netpaid from temp_ssales3299) b on (1=1)
where a.paid > b.adj_netpaid
;
drop table if exists temp_ssales3299;
