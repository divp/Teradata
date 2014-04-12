-- start HQL
drop table if exists temp_inv9205;
create table temp_inv9205 as 
select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy,stdev,mean, case mean when 0.0 then null else stdev/mean end cov
from(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
            ,stddev_samp(inv_quantity_on_hand) stdev,avg(inv_quantity_on_hand) mean
      from inventory i
      join item im on (i.inv_item_sk = im.i_item_sk)
      join warehouse w on (i.inv_warehouse_sk = w.w_warehouse_sk)
      join date_dim d on (i.inv_date_sk = d.d_date_sk)
      where d_year = 2001
      group by w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy) foo
where case mean when 0.0 then 0.0 else stdev/mean end > 1.0
;
select inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean, inv1.cov
        ,inv2.w_warehouse_sk,inv2.i_item_sk,inv2.d_moy,inv2.mean, inv2.cov
from temp_inv9205 inv1 
join temp_inv9205 inv2 on (inv1.i_item_sk = inv2.i_item_sk and inv1.w_warehouse_sk =  inv2.w_warehouse_sk)
where inv1.d_moy=4
  and inv2.d_moy=4+1
order by inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean,inv1.cov
        ,inv2.d_moy,inv2.mean, inv2.cov
;
select inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean, inv1.cov
        ,inv2.w_warehouse_sk,inv2.i_item_sk,inv2.d_moy,inv2.mean, inv2.cov
from temp_inv9205 inv1
join temp_inv9205 inv2 on (inv1.i_item_sk = inv2.i_item_sk and inv1.w_warehouse_sk =  inv2.w_warehouse_sk)
where inv1.d_moy=4
  and inv2.d_moy=4+1
  and inv1.cov > 1.5
order by inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean,inv1.cov
        ,inv2.d_moy,inv2.mean, inv2.cov
;
drop table if exists temp_inv9205;

-- end query 10 in stream 0 using template q39.tpl
