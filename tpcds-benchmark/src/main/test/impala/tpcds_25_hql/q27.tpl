-- q27

select  /* q27 */
        i_item_id,
        s_state, 
        GROUPING__ID,
        avg(ss_quantity) agg1,
        avg(ss_list_price) agg2,
        avg(ss_coupon_amt) agg3,
        avg(ss_sales_price) agg4
from store_sales ss
join customer_demographics cd on (ss.ss_cdemo_sk = cd.cd_demo_sk)
join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk)
join store s on (ss.ss_store_sk = s.s_store_sk)
join item i on (ss.ss_item_sk = i.i_item_sk)
where cd_gender = 'F' and
       cd_marital_status = 'W' and
       cd_education_status = 'Primary' and
       d_year = 1998 and
       s_state in ('TN','TN', 'TN', 'TN', 'TN', 'TN')
group by i_item_id, s_state with rollup
order by i_item_id
         ,s_state
limit 100
;
