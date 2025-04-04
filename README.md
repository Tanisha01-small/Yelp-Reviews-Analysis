# Yelp Reviews Analysis using Snowflake & Sentiment Analysis

## 📌 Project Overview
This project processes and analyzes Yelp's **5GB JSON dataset** to extract valuable business insights. The workflow includes:

- **Splitting large JSON files using Python**
- **Uploading data to Snowflake using SnowSQL CLI**
- **Transforming JSON into structured tables**
- **Applying Sentiment Analysis with a Python UDF in Snowflake**
- **Running SQL queries for exploratory data analysis (EDA)**

---

## 🚀 Steps to Reproduce

### 1️⃣ Split JSON File into Smaller Chunks
**Python script (`split_json.py`)**
```python
import json

input_file = "yelp_academic_dataset_review.json"
output_prefix = "split_file_"
num_files = 10

with open(input_file, "r", encoding="utf8") as f:
    total_lines = sum(1 for _ in f)
    
lines_per_file = total_lines // num_files
print(f"Total lines: {total_lines}, Lines per file: {lines_per_file}")

with open(input_file, "r", encoding="utf8") as f:
    for i in range(num_files):
        output_filename = f"{output_prefix}{i+1}.json"
        with open(output_filename, "w", encoding="utf8") as out_file:
            for j in range(lines_per_file):
                line = f.readline()
                if not line:
                    break
                out_file.write(line)
print("JSON FILE SUCCESSFULLY SPLIT INTO SMALLER PARTS!")
```

### 2️⃣ Upload JSON to Snowflake
Run the following SnowSQL commands:
```sql
CREATE OR REPLACE FILE FORMAT myjsonformat
TYPE = 'JSON'
STRIP_OUTER_ARRAY = TRUE;

CREATE OR REPLACE STAGE my_json_stage
FILE_FORMAT = myjsonformat;

CREATE TABLE yelp_reviews (data VARIANT);

PUT file://C:/Users/Desktop/Yelp-JSON/JSON_FILES/*.json @my_json_stage AUTO_COMPRESS=TRUE;

COPY INTO yelp_reviews FROM @my_json_stage
FILE_FORMAT = (FORMAT_NAME = 'myjsonformat')
ON_ERROR = 'SKIP_FILE';
```

### 3️⃣ Define a Sentiment Analysis UDF in Snowflake
```sql
CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('textblob')
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;
```

### 4️⃣ Transform JSON into Structured Tables
```sql
CREATE OR REPLACE TABLE Yelp_Reviews AS 
SELECT data:business_id::string as business_id,
data:date::Date as review_date,
data:stars::number as review_stars,
data:text::string as review_text,
data:user_id::string as user_id,
analyze_sentiment(review_text) as sentiments
FROM yelp_reviews;
```

### 5️⃣ Exploratory Data Analysis (EDA) Queries
#### 1. Find number of businesses in each category
```sql
SELECT TRIM(A.value) AS Category, COUNT(DISTINCT business_id)
FROM tbl_yelp_businesses, LATERAL SPLIT_TO_TABLE(categories, ',') A
GROUP BY 1 ORDER BY 2 DESC;
```
#### 2. Find top 10 users who reviewed the most businesses in 'Restaurants' category
```sql
SELECT R.User_ID, COUNT(DISTINCT R.business_id)
FROM yelp_reviews R
JOIN tbl_yelp_businesses B ON R.BUSINESS_ID = B.BUSINESS_ID
WHERE B.CATEGORIES ILIKE '%Restaurants%'
GROUP BY 1;
```
#### 3. Find the most popular business categories based on number of reviews
```sql
WITH category_cte AS (
SELECT TRIM(A.value) AS Category, business_id
FROM tbl_yelp_businesses, LATERAL SPLIT_TO_TABLE(categories, ',') A)
SELECT B.Category, COUNT(*) AS No_of_Reviews
FROM yelp_reviews R
JOIN category_cte B ON R.BUSINESS_ID = B.BUSINESS_ID
GROUP BY 1 ORDER BY 2 DESC;
```
#### 4. Find businesses with highest positive sentiment
```sql
SELECT B.name, COUNT(*)
FROM yelp_reviews R
JOIN tbl_yelp_businesses B ON R.BUSINESS_ID = B.BUSINESS_ID
WHERE R.sentiments = 'Positive'
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;
```

---

## 📊 Key Insights Discovered
- **Top business categories**: Restaurants have the highest reviews.
- **Users with most reviews**: Top users wrote 500+ reviews.
- **Most positively reviewed businesses**: Sentiment analysis reveals top-rated places.

---

## 🛠 Technologies Used
- **Python** (File handling, JSON processing)
- **Snowflake** (SQL, Staging, JSON parsing, UDFs)
- **SnowSQL CLI** (Cloud data handling)
- **TextBlob** (Sentiment analysis)
- **SQL Queries** (Data exploration & insights)

---

 Download the full dataset from [Yelp Open Dataset](https://www.yelp.com/dataset).

---

📄 This project is licensed under the [MIT License](./LICENSE).



