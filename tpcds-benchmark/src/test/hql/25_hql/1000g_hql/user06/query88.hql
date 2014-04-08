-- start HQL
select  *
from
 (select count(*) h8_30_to_9
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 8
     and t.t_minute >= 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s1
 cross join (select count(*) h9_to_9_30
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 9
     and t.t_minute < 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s2
 cross join (select count(*) h9_30_to_10
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 9
     and t.t_minute >= 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s3
 cross join (select count(*) h10_to_10_30
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 10
     and t.t_minute < 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s4
 cross join (select count(*) h10_30_to_11
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 10
     and t.t_minute >= 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s5
 cross join (select count(*) h11_to_11_30
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 11
     and t.t_minute < 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s6
 cross join (select count(*) h11_30_to_12
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 11
     and t.t_minute >= 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s7 
 cross join (select count(*) h12_to_12_30
 from store_sales ss
 join household_demographics hd on (ss.ss_hdemo_sk = hd.hd_demo_sk)
 join time_dim t on (ss.ss_sold_time_sk = t.t_time_sk)
 join store s on (ss.ss_store_sk = s.s_store_sk)
 where t.t_hour = 12
     and t.t_minute < 30
     and ((hd.hd_dep_count = 0 and hd.hd_vehicle_count<=0+2) or
          (hd.hd_dep_count = 3 and hd.hd_vehicle_count<=3+2) or
          (hd.hd_dep_count = 4 and hd.hd_vehicle_count<=4+2))
     and s.s_store_name = 'ese') s8 
;

-- end query 22 in stream 0 using template q88.tpl
