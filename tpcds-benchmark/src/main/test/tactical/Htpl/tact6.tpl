select sum(t_s.ss_quantity) as quantity, sum(t_s.ss_net_paid) as net_paid, sum(t_s.ss_net_profit) as net_profit
from store_sales t_s
inner join date_dim t_d
    on   t_s.ss_sold_date_sk = t_d.d_date_sk
inner join store t_st
    on t_s.ss_store_sk = t_st.s_store_sk
where   ss_item_sk = ${SIS}
    and ss_store_sk = ${SSK}
    and s_state = '${SS}'
    and d_date='${DD}';
