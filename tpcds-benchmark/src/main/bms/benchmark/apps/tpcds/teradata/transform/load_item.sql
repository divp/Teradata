/*
for every row v in view V
   begin transaction // minimal transaction boundary
       if there is a row d in table D where the business keys of v and d are equal
     get the row d of the dimension table
                      where the value of rec_end_date is NULL
     update rec_end_date of d with current date minus one day
     update rec_start_date of v with current date
   end-if 
   generate next primary key value pkv of D
   insert v into D including pkv as primary key and NULL as rec_end_date
   end transaction
end-for
*/

BEGIN TRANSACTION;

INSERT INTO ITEM (item_item_id i_item_id ,i_rec_start_date, i_rec_end_date ,item_item_description i_item_desc ,item_list_price i_current_price ,item_wholesale_cost i_wholesalecost ,i_brand_id ,i_brand ,i_class_id ,i_class ,i_category_id ,i_category ,i_manufact_id ,i_manufact ,item_size i_size ,item_formulation i_formulation ,item_color i_color ,item_units i_units ,item_container i_container ,item_manager_id i_manager ,i_product_name)
SELECT item_item_id i_item_id, CURRENT_DATE i_rec_start_date ,CAST(NULL AS DATE) i_rec_end_date ,item_item_description i_item_desc ,item_list_price i_current_price ,item_wholesale_cost i_wholesalecost ,i_brand_id ,i_brand ,i_class_id ,i_class ,i_category_id ,i_category ,i_manufact_id ,i_manufact ,item_size i_size ,item_formulation i_formulation ,item_color i_color ,item_units i_units ,item_container i_container ,item_manager_id i_manager ,i_product_name





UPDATE item SET 

CREATE VIEW itemv AS
SELECT  
    item_item_id i_item_id
    ,CURRENT_DATE i_rec_start_date
    ,CAST(NULL AS DATE) i_rec_end_date
    ,item_item_description i_item_desc
    ,item_list_price i_current_price
    ,item_wholesale_cost i_wholesalecost
    ,i_brand_id
    ,i_brand
    ,i_class_id
    ,i_class
    ,i_category_id
    ,i_category
    ,i_manufact_id
    ,i_manufact
    ,item_size i_size
    ,item_formulation i_formulation
    ,item_color i_color
    ,item_units i_units
    ,item_container i_container
    ,item_manager_id i_manager
    ,i_product_name
FROM s_item
LEFT OUTER JOIN item 
    ON   (item_item_id = i_item_id 
    AND i_rec_end_date IS NULL);