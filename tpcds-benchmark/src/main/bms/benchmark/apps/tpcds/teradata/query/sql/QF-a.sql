/*  (a)	Fact lookup by main key (selective, but non-unique, returns a handful of rows)*/
SELECT  * 
FROM store_sales 
WHERE  ss_ticket_number=5741230;
