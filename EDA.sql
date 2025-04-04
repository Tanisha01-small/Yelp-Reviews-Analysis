SELECT * FROM yelp_reviews  LIMIT 10;
SELECT * FROM tbl_yelp_businesses LIMIT 10;


----------------------Find Number of Businessess in each category

SELECT TRIM(A.value) AS Category,COUNT(DISTINCT business_id )
FROM tbl_yelp_businesses,Lateral SPLIT_TO_TABLE(categories,',') A
GROUP BY 1
ORDER BY 2 DESC ;


--------------------Find Top 10 users who reviewed the most businessess in 'Restaurants Category' 

WITH category_cte as (
SELECT TRIM(A.value) AS Category,business_id
FROM tbl_yelp_businesses,Lateral SPLIT_TO_TABLE(categories,',') A

)

SELECT R.User_ID,COUNT(distinct R.business_id)
FROM yelp_reviews R
JOIN category_cte B
ON R.BUSINESS_ID=B.BUSINESS_ID
WHERE B.Category='Restaurants'
GROUP BY 1;


---Method 2

SELECT R.User_ID,COUNT(distinct R.business_id)
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID
WHERE B.CATEGORIES ilike '%Restaurants%'
GROUP BY 1;

-----------------------------Question 3 find the most popular categories of business based on number of reviews

WITH category_cte as (
SELECT TRIM(A.value) AS Category,business_id
FROM tbl_yelp_businesses,Lateral SPLIT_TO_TABLE(categories,',') A

)

SELECT B.Category,COUNT(*) No_of_Reviews
FROM yelp_reviews R
JOIN category_cte B
ON R.BUSINESS_ID=B.BUSINESS_ID
GROUP BY 1
ORDER BY 2 DESC ;


------------------Question 4 Find top 3 recent reviews for each business

with cte1 as (
SELECT B.NAME,R.review_date,R.REVIEW_STARS,R.REVIEW_TEXT,DENSE_RANK() OVER(Partition BY B.NAME ORDER BY R.REVIEW_DATE DESC) as rnk
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID 
ORDER BY B.Name,5
)

SELECT *
FROM cte1
WHERE rnk <=3;

-----------------------Question 5 FInd the month with highest number of reviews 


SELECT CONCAT(DATE_PART('year',review_date),'-',DATE_PART('month',review_date)) AS YEAR_MONTH
,COUNT(*)
FROM yelp_reviews  
GROUP BY 1
ORDER BY 2 DESC ;


------------------Question 6 Find % of 5 star reviews for each business

--- Case when statements can be used as well 


with five_star_count as (
SELECT B.NAME,COUNT(*) as cntF
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID 
WHERE R.REVIEW_STARS=5
GROUP BY 1
ORDER BY 2 DESC 
)
, total_count as 
(
SELECT B.NAME,COUNT(*) cntT
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID 
GROUP BY 1
ORDER BY 2 DESC 
)

SELECT F.name, ROUND(F.cntF*100/T.cntT,2) as Percent_Five_star_reviews
FROM five_star_count F
JOIN total_count T
ON F.Name=T.Name
ORDER BY 2 DESC ;

-------------------Question 7 Find the top 5 most reviewed business in city

with cte1 as (
SELECT B.city,B.name,COUNT(*) as total_reviews
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID 
GROUP BY 1,2
)

SELECT *,DENSE_RANK() OVER(Partition BY CITY ORDER BY total_reviews DESC)
FROM cte1
QUALIFY DENSE_RANK() OVER(Partition BY CITY ORDER BY total_reviews DESC) <=5
ORDER BY 1;


-------------------Question8 Find the average rating of Restaurants with at least 100 reviews 

with cte1 as (
SELECT  B.name,COUNT(*) as cnt
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID 
GROUP BY 1
HAVING cnt >=100 

)

SELECT name,ROUND(AVG(stars),0)
FROM tbl_yelp_businesses
WHERE name in (SELECT name FROM cte1) 
GROUP BY 1
ORDER BY 2 DESC;



----------------------Question 9 List the top 10 users who have written most reviews along with the business they reviewed

with cte1 as (
SELECT USER_ID,COUNT(*) cnt
FROM yelp_reviews 
GROUP BY 1
)
, id as (
SELECT USER_ID
FROM cte1 
QUALIFY DENSE_RANK() OVER(ORDER BY cnt DESC) <=10
)

SELECT  R.user_id,B.name
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID 
WHERE R.USER_ID in (SELECT * FROM id)
ORDER BY 1;


----------Find top 10 businessess with highest postive sentiment 

SELECT  B.name,COUNT(*)
FROM yelp_reviews R
JOIN tbl_yelp_businesses B
ON R.BUSINESS_ID=B.BUSINESS_ID  
WHERE R.sentiments='Positive'
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10;
