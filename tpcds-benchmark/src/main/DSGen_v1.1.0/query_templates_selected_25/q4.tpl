define YEAR=random(1998,2001,uniform);
define SELECTCONE= text({"t_s_secyear.customer_id",1},{"t_s_secyear.customer_first_name",1},{"t_s_secyear.customer_last_name",1},{"t_s_secyear.customer_preferred_cust_flag",1},{"t_s_secyear.customer_birth_country",1},{"t_s_secyear.customer_login",1},{"t_s_secyear.customer_email_address",1},{"t_s_secyear.customer_id,t_s_secyear.customer_first_name,t_s_secyear.customer_last_name,t_s_secyear.c_preferred_cust_flag,t_s_secyear.c_birth_country,t_s_secyear.c_login,t_s_secyear.c_email_address",1});
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

with year_total (customer_id, customer_first_name, customer_last_name, customer_preferred_cust_flag, customer_birth_country, customer_login, customer_email_address, dyear, year_total, sale_type) as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(((ss_ext_list_price-ss_ext_wholesale_cost-ss_ext_discount_amt)+ss_ext_sales_price)/2) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((cs_ext_list_price-cs_ext_wholesale_cost-cs_ext_discount_amt)+cs_ext_sales_price)/2) ) year_total
       ,'c' sale_type
 from customer
     ,catalog_sales
     ,date_dim
 where c_customer_sk = cs_bill_customer_sk
   and cs_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((ws_ext_list_price-ws_ext_wholesale_cost-ws_ext_discount_amt)+ws_ext_sales_price)/2) ) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
         )
select [_LIMITA] [SELECTCONE]
 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_c_firstyear
     ,year_total t_c_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
   and t_s_firstyear.customer_id = t_c_secyear.customer_id
   and t_s_firstyear.customer_id = t_c_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_secyear.customer_id
   and t_s_firstyear.sale_type = 's'
   and t_c_firstyear.sale_type = 'c'
   and t_w_firstyear.sale_type = 'w'
   and t_s_secyear.sale_type = 's'
   and t_c_secyear.sale_type = 'c'
   and t_w_secyear.sale_type = 'w'
   and t_s_firstyear.dyear =  [YEAR]
   and t_s_secyear.dyear = [YEAR]+1
   and t_c_firstyear.dyear =  [YEAR]
   and t_c_secyear.dyear =  [YEAR]+1
   and t_w_firstyear.dyear = [YEAR]
   and t_w_secyear.dyear = [YEAR]+1
   and t_s_firstyear.year_total > 0
   and t_c_firstyear.year_total > 0
   and t_w_firstyear.year_total > 0
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
 order by [SELECTCONE]
;

 [AGGG]
 [AGGH]
 [AGGI]

drop table if exists temp_year_total884;
create table temp_year_total884 as
select * from
(
select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(cast(((ss_ext_list_price-ss_ext_wholesale_cost-ss_ext_discount_amt)+ss_ext_sales_price)/2 as decimal(15,2)))  year_total
       ,'s' sale_type
from customer c
       join store_sales ss on (c.c_customer_sk = ss.ss_customer_sk)
       join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk)
group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
union all
select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(cast(((cs_ext_list_price-cs_ext_wholesale_cost-cs_ext_discount_amt)+cs_ext_sales_price)/2 as decimal(15,2)))  year_total
       ,'c' sale_type
from customer c
       join catalog_sales cs on (c.c_customer_sk = cs.cs_bill_customer_sk)
       join date_dim d on (cs.cs_sold_date_sk = d.d_date_sk)
group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
union all
select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(cast(((ws_ext_list_price-ws_ext_wholesale_cost-ws_ext_discount_amt)+ws_ext_sales_price)/2 as decimal(15,2)))  year_total
       ,'w' sale_type
  from customer c
       join web_sales ws on (c.c_customer_sk = ws.ws_bill_customer_sk)
       join date_dim d on (ws.ws_sold_date_sk = d.d_date_sk)
group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
) a      
;
select  [SELECTCONE]
from temp_year_total884 t_s_firstyear
join temp_year_total884 t_s_secyear on (t_s_secyear.customer_id = t_s_firstyear.customer_id)
join temp_year_total884 t_c_firstyear on (t_s_firstyear.customer_id = t_c_firstyear.customer_id)
join temp_year_total884 t_c_secyear on (t_s_firstyear.customer_id = t_c_secyear.customer_id)
join temp_year_total884 t_w_firstyear on (t_s_firstyear.customer_id = t_w_firstyear.customer_id)
join temp_year_total884 t_w_secyear on (t_s_firstyear.customer_id = t_w_secyear.customer_id)
where t_s_firstyear.sale_type = 's'
   and t_c_firstyear.sale_type = 'c'
   and t_w_firstyear.sale_type = 'w'
   and t_s_secyear.sale_type = 's'
   and t_c_secyear.sale_type = 'c'
   and t_w_secyear.sale_type = 'w'
   and t_s_firstyear.dyear =  [YEAR]
   and t_s_secyear.dyear = [YEAR]+1
   and t_c_firstyear.dyear = [YEAR]
   and t_c_secyear.dyear =  [YEAR]+1
   and t_w_firstyear.dyear = [YEAR] 
   and t_w_secyear.dyear = [YEAR]+1
   and t_s_firstyear.year_total > 0
   and t_c_firstyear.year_total > 0
   and t_w_firstyear.year_total > 0
   and case when t_c_firstyear.year_total > 0 then cast(t_c_secyear.year_total / t_c_firstyear.year_total as decimal(15,2)) else null end
           > case when t_s_firstyear.year_total > 0 then cast(t_s_secyear.year_total / t_s_firstyear.year_total as decimal(15,2)) else null end
   and case when t_c_firstyear.year_total > 0 then cast(t_c_secyear.year_total / t_c_firstyear.year_total as decimal(15,2)) else null end
           > case when t_w_firstyear.year_total > 0 then cast(t_w_secyear.year_total / t_w_firstyear.year_total as decimal(15,2)) else null end
order by [SELECTCONE]
[_LIMITC]
;
drop table if exists temp_year_total884;

