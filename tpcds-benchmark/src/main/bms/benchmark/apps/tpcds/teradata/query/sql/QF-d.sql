/* (d) Dimension lookup by compound attribute text constraint */
SELECT   * 
FROM store 
WHERE   s_city LIKE '%greenville%' 
    AND (s_street_name LIKE '5th' 
    OR   s_street_name LIKE 'fifth');