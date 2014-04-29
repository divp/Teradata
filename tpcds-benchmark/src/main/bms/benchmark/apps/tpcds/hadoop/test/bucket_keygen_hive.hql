select  
abs(hash(col_3, col_1)%5) * 1000 + rank() over (distribute by abs(hash(col_3, col_1)%5) sort by col_2) as ID,
col_1, col_2, col_3, col_4
from schools
