** checking all the data rows and column**
SELECT * FROM amazon.product;


** Discounted_Price Tranformation **
** Removed all Rupees Symbol from Discounted_Price column **
UPDATE amazon.product
SET discounted_price = REPLACE(discounted_price, '₹', '')
WHERE discounted_price LIKE '₹%';

** Removed all Comma(,) Symbol from Discounted_Price column **
UPDATE amazon.product
SET Discounted_Price = replace(Discounted_Price, ",", "")
WHERE discounted_price LIKE '%,%';

**Removed all Extra Space b/w numbers from Discounted_Price column **
UPDATE amazon.product
SET discounted_price = REPLACE(discounted_price, ' ', '')
WHERE discounted_price LIKE '% %';

** Removing % Remove from discount_percentage column**
UPDATE amazon.product
SET discount_percentage = replace(discount_percentage, "%","");

** changing the 'discounted_price' datatype to numeric type**
ALTER TABLE amazon.product
MODIFY COLUMN discounted_price FLOAT;
 
**actual_price column Tranformation** 
**Removed all Rupees Symbol from actual_price**
UPDATE amazon.product
SET actual_price = REPLACE(actual_price, '₹', '')
WHERE actual_price LIKE '₹%';

** Removed all Comma(,) Symbol from actual_price**
UPDATE amazon.product
SET actual_price = replace(actual_price, ",", "")
WHERE actual_price LIKE '%,%';

** Removed all Extra Space b/w numbers from actual_price**
UPDATE amazon.product
SET actual_price = REPLACE(actual_price, ' ', '')
WHERE actual_price LIKE '% %';

** Convert 'actual_price' column datatype to numeric type **
ALTER TABLE amazon.product
MODIFY COLUMN actual_price FLOAT; 


** Total Rows = 1465 **
**The rating column has a value with an incorrect character, so i will exclude it from the dataset** 
-- I checked which row has "|" & removed the entire row taking the product ID SO the row_Count is 1464 now
## Row_count = 1464

DELETE FROM amazon.product
WHERE product_id = 'B08L12N5H1';

** "rating_count" column Tranformation **
** Removed all Rupees Symbol from discounted_price**
UPDATE amazon.product
SET discounted_price = REPLACE(discounted_price, '₹', '')
WHERE discounted_price LIKE '₹%';

## Removed all Comma(,) Symbol 
UPDATE amazon.product
SET rating_count = replace(rating_count, ",", "")
WHERE rating_count LIKE '%,%';

** Removed all Extra Space b/w numbers **
UPDATE amazon.product
SET rating_count = REPLACE(discounted_price, ' ', '')
WHERE rating_count LIKE '% %';

** Check for missing values **
SELECT *
FROM amazon.product
WHERE product_id IS NULL OR product_id = ''
   OR rating_count IS NULL OR rating_count = ''
   OR discounted_price IS NULL OR discounted_price = ''
   OR product_name IS NULL OR product_name = ''
   OR category IS NULL OR category = ''
   OR actual_price IS NULL OR actual_price = ''
   OR rating IS NULL OR rating = ''
   OR rating_count IS NULL OR rating_count = ''
   OR about_product IS NULL OR about_product = ''
   OR user_id IS NULL OR user_id = ''
   OR review_title IS NULL OR review_title = ''
   OR review_content IS NULL OR review_content = ''
   OR img_link IS NULL OR img_link = ''
   OR product_link IS NULL OR product_link = ''
   ;

**Removing the enpty rows**
Delete FROM amazon.product
where rating_count = ""; ## 2 Rows had Empty value 

## rows_Count = '1462'
 select count(*) FROM amazon.product;
 
** Rating weighted - This column weighs the average rating by the number of ratings, giving more weight to ratings with a large number of raters. Craeted the Rating weighted Column **. 
ALTER TABLE amazon.product
ADD COLUMN rating_weighted FLOAT NULL DEFAULT NULL;


## Performimg the weighted Rating Calulation
Update amazon.product
set rating_weighted = rating*rating_count ;


**Extracting Main and Final Categories from a Hierarchical Category Column**
** 1. Creating the main and final categories Column **
Alter Table amazon.product
Add Column Main_Category Text Null Default null,
Add Column Final_Category TEXT NULL DEFAULT NULL; 

## Extracted Values Use the SUBSTRING_INDEX() function to extract the first and last categories
UPDATE amazon.product
SET Main_Category = substring_index(category, "|", 1) , 
Final_Category = substring_index(category , "|	", -1);

# Analyzing distribution of products by main category
Select distinct Main_Category , 
count(product_id) as No_of_Products
FROM amazon.product
group by  Main_Category
order by No_of_Products DESC;

# Analyzing distribution of products by final category
SELECT DISTINCT Final_Category, Main_Category,
COUNT(product_id) AS No_of_Product
FROM amazon.product 
GROUP BY Final_Category , Main_Category 
order by No_of_Product DESC
Limit 5;

## Analyze the distribution of customer ratings
SELECT 
    rating_group,
    COUNT(*) AS review_count
FROM (
    SELECT 
        rating,
        CASE
            WHEN rating >= 2 AND rating < 2.5 THEN '2.0 - 2.5'
            WHEN rating >= 2.5 AND rating < 3 THEN '2.5 - 3.0'
            WHEN rating >= 3 AND rating < 3.5 THEN '3.0 - 3.5'
            WHEN rating >= 3.5 AND rating < 4 THEN '3.5 - 4.0'
            WHEN rating >= 4 AND rating < 4.5 THEN '4.0 - 4.5'
            WHEN rating >= 4.5 AND rating <= 5 THEN '4.5 - 5.0'
            ELSE 'Out of Rating'
        END AS rating_group
    FROM amazon.product
) AS grouped_ratings
GROUP BY rating_group
ORDER BY review_count DESC;

 

**Calculate the top main categories Avg Rating **
select distinct Main_Category, round(avg(rating),2) as Avg_Rating
FROM amazon.product
group by  Main_Category
Order by Avg_Rating Desc
Limit 10;

select distinct Main_Category, max(rating) as highest_rating
FROM amazon.product
group by  Main_Category
Order by highest_rating Desc
Limit 10;



# Calculate the top 10 sub categories with Avg Rating and Count of Rating 
select distinct Final_Category, round(avg(rating),2) as Avg_Rating, count(*) as No_of_Rating 
FROM amazon.product
group by Final_Category
order by Avg_Rating Desc
Limit 10 ;

select Main_Category ,Final_Category, rating , product_id
FROM amazon.product
group by  Main_Category ,Final_Category, rating, product_id
Order by Rating Desc
Limit 5;

** Calculate the top sub categories by Rating**
SELECT 
    Final_Category, 
    AVG(rating) AS avg_rating,
     count(rating) as No_of_rating
FROM amazon.product
GROUP BY Final_Category
ORDER BY avg_rating DESC
LIMIT 10;
 
** Calculate the Bottom sub categories by Rating **
 SELECT 
    Final_Category,
    round(AVG(rating),2) AS avg_rating,
    count(rating) as No_of_rating
FROM amazon.product
GROUP BY Final_Category
ORDER BY avg_rating 
LIMIT 10;

 SELECT Main_Category,
    Final_Category,
	product_id,
    MIN(rating) AS Least_Rating
FROM amazon.product
GROUP BY Main_Category, Final_Category, product_id
ORDER BY  Least_Rating ASC
LIMIT 10;

 SELECT 
    Main_Category,
    MIN(rating) AS Least_Rating
FROM amazon.product
GROUP BY Main_Category
ORDER BY  Least_Rating ASC
LIMIT 10;

** Top Rated Products By Final Category **
with RANKING AS (
select  SUBSTRING_INDEX(product_name, ",", 1) AS Product_name, Final_Category, -- Shortening the Product name
row_number() over (Partition by Final_Category order by rating DESC) AS Ranking , rating 
FROM amazon.product) 
SELECT product_name, Final_Category, rating FROM RANKING 
WHERE Ranking = 1
ORDER BY rating DESC
Limit 10;

** Least Rated Products by Final Category ** 
WITH RANKING AS (
select SUBSTRING_INDEX(product_name, "," , 1) AS Product_name, Final_Category, rating,
 row_number() over(partition by Final_Category order by Rating ASC) AS Ranking
FROM amazon.product )
SELECT Product_name, Final_Category, rating
FROM RANKING 
WHERE Ranking = 1
ORDER BY rating ASC
LIMIT 10;

** Top Rated Products **
SELECT Product_name, rating 
FROM amazon.product
ORDER BY rating DESC
LIMIT 10 ;

** Bottom Rated Products **
SELECT Product_name, rating 
FROM amazon.product
ORDER BY rating ASC
LIMIT 10 ;

** Top Products By Rating Percentage**

-- Reviews and Ratings Per Product
Select Final_Category, count(Distinct(product_id)) as product_count, 
Round(avg(rating),2) as Avg_rating, count(review_content) as total_reviews
FROM amazon.product
group by Final_Category
ORDER BY product_count DESC
Limit 20; 

** Calculate the rating percentage for each product **
SELECT 
    product_id, 
    product_name, 
    category, 
    (rating / 5.0) * 100 AS rating_percentage
FROM amazon.product
ORDER BY rating_percentage DESC
LIMIT 10;

** Discount Perc by Category wise **
select Main_Category, round(avg(discount_percentage),2) as Avg_discount_percentage
FROM amazon.product
group by Main_Category
order by Avg_discount_percentage DESC;

** Discount Perc by Fianl Category wise **
Select Final_Category, Avg_discount_percentage from 
(select Final_Category, round(avg(discount_percentage),2) as Avg_discount_percentage
FROM amazon.product
group by Final_Category
order by Avg_discount_percentage ASC) AS Disc
where Avg_discount_percentage > 0
Limit 15;


** word cloud 
WITH word_split AS (
    SELECT  LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(review_content, ' ', n.n), ' ', -1)) AS word
    FROM 
        amazon.product
    JOIN (
        SELECT 1 AS n
        UNION ALL SELECT 2
        UNION ALL SELECT 3
        UNION ALL SELECT 4
        UNION ALL SELECT 5
        UNION ALL SELECT 6
        UNION ALL SELECT 7
        UNION ALL SELECT 8
        UNION ALL SELECT 9
        UNION ALL SELECT 10
    ) n ON CHAR_LENGTH(review_content) - CHAR_LENGTH(REPLACE(review_content, ' ', '')) >= n.n - 1
    WHERE review_content IS NOT NULL
)
SELECT 
    word, 
    COUNT(*) AS frequency
FROM word_split
GROUP BY word
ORDER BY frequency DESC
LIMIT 200;

** Create a frequency table for user IDs *8
SELECT 
    user_id,
    COUNT(user_id) AS frequency
FROM 
    amazon.product
GROUP BY 
    user_id
ORDER BY 
    frequency DESC;

** Extract the user ID with the highest frequency (most frequent user ID)
SELECT 
    user_id , frequency
FROM 
    (SELECT 
         user_id,
         COUNT(user_id) AS frequency
     FROM 
         amazon.product
     GROUP BY 
         user_id
     ORDER BY 
         frequency DESC
     LIMIT 10) AS most_frequent_user;
     



