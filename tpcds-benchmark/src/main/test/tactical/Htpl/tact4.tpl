select * from store where s_city like '%${SC}%' and (s_street_name like '${SSN}%' or s_street_name like 'Fifth%');
