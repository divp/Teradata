use ${hiveconf:db};

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
       ,sum(((ss_ext_list_price-ss_ext_wholesale_cost-ss_ext_discount_amt)+ss_ext_sales_price)/2) year_total
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
       ,sum((((cs_ext_list_price-cs_ext_wholesale_cost-cs_ext_discount_amt)+cs_ext_sales_price)/2) ) year_total
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
       ,sum((((ws_ext_list_price-ws_ext_wholesale_cost-ws_ext_discount_amt)+ws_ext_sales_price)/2) ) year_total
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
select  t_s_secyear.customer_id
	,t_s_secyear.customer_first_name
       ,t_s_secyear.customer_last_name
       ,t_s_secyear.customer_preferred_cust_flag
       ,t_s_secyear.customer_birth_country
       ,t_s_secyear.customer_login
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
   and t_s_firstyear.dyear =  2001
   and t_s_secyear.dyear = 2001+1
   and t_c_firstyear.dyear = 2001
   and t_c_secyear.dyear =  2001+1
   and t_w_firstyear.dyear = 2001 
   and t_w_secyear.dyear = 2001+1
   and t_s_firstyear.year_total > 0
   and t_c_firstyear.year_total > 0
   and t_w_firstyear.year_total > 0
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
order by t_s_secyear.customer_id, t_s_secyear.customer_first_name ,t_s_secyear.customer_last_name
       ,t_s_secyear.customer_preferred_cust_flag ,t_s_secyear.customer_birth_country ,t_s_secyear.customer_login
limit 100
;
drop table if exists temp_year_total884;
