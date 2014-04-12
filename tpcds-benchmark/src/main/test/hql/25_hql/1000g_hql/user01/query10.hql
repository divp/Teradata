-- start HQL
select
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3,
  cd_dep_count,
  count(*) cnt4,
  cd_dep_employed_count,
  count(*) cnt5,
  cd_dep_college_count,
  count(*) cnt6
from
  customer c
  join customer_address ca on (c.c_current_addr_sk = ca.ca_address_sk)
  join customer_demographics cd on (cd.cd_demo_sk = c.c_current_cdemo_sk)
  left semi join (select ss.ss_customer_sk from store_sales ss join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk) where d_year = 2001 and d_moy between 2 and 2+3 group by ss.ss_customer_sk) e1 on (c.c_customer_sk = e1.ss_customer_sk)
  left join (select ws.ws_bill_customer_sk from web_sales ws join date_dim d on (ws.ws_sold_date_sk = d.d_date_sk) where d_year = 2001 and d_moy between 2 and 2+3 group by ws.ws_bill_customer_sk) e2 on (c.c_customer_sk = e2.ws_bill_customer_sk)
  left join (select cs.cs_ship_customer_sk from catalog_sales cs join date_dim d on (cs.cs_sold_date_sk = d.d_date_sk) where d_year = 2001 and d_moy between 2 and 2+3 group by cs.cs_ship_customer_sk) e3 on (c.c_customer_sk = e3.cs_ship_customer_sk)
where ca_county in ('Buchanan County','Hardeman County','Jackson County','Dewey County','Dade County')
  and (e2.ws_bill_customer_sk is not null or e3.cs_ship_customer_sk is not null)
 group by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
order by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
limit 100;

-- end query 3 in stream 0 using template q10.tpl
