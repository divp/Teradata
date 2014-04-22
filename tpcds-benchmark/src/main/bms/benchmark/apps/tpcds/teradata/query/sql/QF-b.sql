/*  (b)    Fact lookup by main key with uniqueness constraint (returns 1 row)*/
SELECT   * 
FROM store_sales 
WHERE   ss_ticket_number=5741230 
    AND ss_item_sk=4825;