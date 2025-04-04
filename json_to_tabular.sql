CREATE OR REPLACE TABLE Yelp_Reviews AS 
SELECT data:business_id::string as business_id,
data:date::Date as review_date,
data:stars::number as review_stars,
data:text::string as review_text,
data:user_id::string as user_id,
analyze_sentiment(review_text) as sentiments
FROM yelpreviews ;

SELECT * FROM yelp_reviews LIMIT 100 ;



SELECT * FROM tbl_yelp_businesses;


create or replace table tbl_yelp_businesses as 
select data:business_id::string as business_id
,data:name::string as name
,data:city::string as city
,data:state::string as state
,data:review_count::string as review_count
,data:stars::number as stars
,data:categories::string as categories
FROM yelpbusiness ;
