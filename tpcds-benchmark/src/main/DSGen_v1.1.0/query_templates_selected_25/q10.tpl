 define COUNTY = ulist(dist(fips_county,2,1),10);
 define MONTH = random(1,4,uniform);
 define YEAR = random(1999,2002,uniform);
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

 select [_LIMITA]
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
  customer c,customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  ca_county in ('[COUNTY.1]','[COUNTY.2]','[COUNTY.3]','[COUNTY.4]','[COUNTY.5]') and
  cd_demo_sk = c.c_current_cdemo_sk and 
  exists (select *
          from store_sales,date_dim
          where c.c_customer_sk = ss_customer_sk and
                ss_sold_date_sk = d_date_sk and
                d_year = [YEAR] and
                d_moy between [MONTH] and [MONTH]+3) and
   (exists (select *
            from web_sales,date_dim
            where c.c_customer_sk = ws_bill_customer_sk and
                  ws_sold_date_sk = d_date_sk and
                  d_year = [YEAR] and
                  d_moy between [MONTH] ANd [MONTH]+3) or 
    exists (select * 
            from catalog_sales,date_dim
            where c.c_customer_sk = cs_ship_customer_sk and
                  cs_sold_date_sk = d_date_sk and
                  d_year = [YEAR] and
                  d_moy between [MONTH] and [MONTH]+3))
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
;

 [AGGG]
 [AGGH]
 [AGGI]

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
  left semi join (select ss.ss_customer_sk from store_sales ss join date_dim d on (ss.ss_sold_date_sk = d.d_date_sk) where d_year = [YEAR] and d_moy between [MONTH] and [MONTH]+3 group by ss.ss_customer_sk) e1 on (c.c_customer_sk = e1.ss_customer_sk)
  left join (select ws.ws_bill_customer_sk from web_sales ws join date_dim d on (ws.ws_sold_date_sk = d.d_date_sk) where d_year = [YEAR] and d_moy between [MONTH] and [MONTH]+3 group by ws.ws_bill_customer_sk) e2 on (c.c_customer_sk = e2.ws_bill_customer_sk)
  left join (select cs.cs_ship_customer_sk from catalog_sales cs join date_dim d on (cs.cs_sold_date_sk = d.d_date_sk) where d_year = [YEAR] and d_moy between [MONTH] and [MONTH]+3 group by cs.cs_ship_customer_sk) e3 on (c.c_customer_sk = e3.cs_ship_customer_sk)
where ca_county in ('[COUNTY.1]','[COUNTY.2]','[COUNTY.3]','[COUNTY.4]','[COUNTY.5]')
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
[_LIMITC];

