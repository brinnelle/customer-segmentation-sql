-- Customer Segmentation: SQL Analysis (SQLite)
-- Dataset: 2,240 customers of a specialty food retailer; 2,216 after removing rows with missing income.

-- SETUP: build 3 tables from the raw import
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS spend;
DROP TABLE IF EXISTS campaigns;

CREATE TABLE customers AS
SELECT CAST(ID AS INTEGER) AS customer_id,
       CAST(Year_Birth AS INTEGER) AS birth_year,
       Education, Marital_Status,
       CAST(Income AS REAL) AS Income,
       CAST(Kidhome AS INTEGER) AS Kidhome,
       CAST(Teenhome AS INTEGER) AS Teenhome,
       Dt_Customer
FROM raw
WHERE Income IS NOT NULL AND TRIM(Income) <> '';

CREATE TABLE spend AS
SELECT CAST(ID AS INTEGER) AS customer_id,
       CAST(MntWines AS INTEGER) AS wine,
       CAST(MntFruits AS INTEGER) AS fruits,
       CAST(MntMeatProducts AS INTEGER) AS meat,
       CAST(MntFishProducts AS INTEGER) AS fish,
       CAST(MntSweetProducts AS INTEGER) AS sweets,
       CAST(MntGoldProds AS INTEGER) AS gold
FROM raw
WHERE Income IS NOT NULL AND TRIM(Income) <> '';

CREATE TABLE campaigns AS
SELECT CAST(ID AS INTEGER) AS customer_id,
       CAST(AcceptedCmp1 AS INTEGER) AS AcceptedCmp1,
       CAST(AcceptedCmp2 AS INTEGER) AS AcceptedCmp2,
       CAST(AcceptedCmp3 AS INTEGER) AS AcceptedCmp3,
       CAST(AcceptedCmp4 AS INTEGER) AS AcceptedCmp4,
       CAST(AcceptedCmp5 AS INTEGER) AS AcceptedCmp5,
       CAST(Response AS INTEGER) AS Response
FROM raw
WHERE Income IS NOT NULL AND TRIM(Income) <> '';

--Q1: How much more do high-income customers spend?
SELECT
  CASE WHEN c.Income >= 70000 THEN 'High ($70K+)'
       WHEN c.Income >= 35000 THEN 'Mid ($35K-$70K)'
       ELSE 'Low (under $35K)' END AS income_bracket,
  COUNT(*) AS customers,
  ROUND(AVG(s.wine + s.fruits + s.meat + s.fish + s.sweets + s.gold)) AS avg_spend
FROM customers c
JOIN spend s ON c.customer_id = s.customer_id
GROUP BY income_bracket;

--Q2: What share of total spend does each category make up?
WITH long_spend AS (
  SELECT 'Wine' AS category, wine AS amount FROM spend
  UNION ALL SELECT 'Meat', meat FROM spend
  UNION ALL SELECT 'Gold', gold FROM spend
  UNION ALL SELECT 'Fish', fish FROM spend
  UNION ALL SELECT 'Sweets', sweets FROM spend
  UNION ALL SELECT 'Fruits', fruits FROM spend
)
SELECT category,
       SUM(amount) AS total_spend,
       ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM long_spend), 1) AS pct_of_spend
FROM long_spend
GROUP BY category
ORDER BY total_spend DESC;

--Q3: Spend and campaign response rate by income bracket
WITH customer_totals AS (
  SELECT c.customer_id,
         s.wine + s.fruits + s.meat + s.fish + s.sweets + s.gold AS total_spend,
         CASE WHEN c.Income >= 70000 THEN 'High'
              WHEN c.Income >= 35000 THEN 'Mid'
              ELSE 'Low' END AS income_bracket
  FROM customers c
  JOIN spend s ON c.customer_id = s.customer_id
)
SELECT t.income_bracket,
       COUNT(*) AS customers,
       ROUND(AVG(t.total_spend)) AS avg_spend,
       ROUND(100.0 * AVG(cp.Response), 1) AS response_rate_pct
FROM customer_totals t
JOIN campaigns cp ON t.customer_id = cp.customer_id
GROUP BY t.income_bracket;

--Q4: Top 3 spenders within each income bracket (window function)
WITH customer_totals AS (
  SELECT c.customer_id, c.Income,
         s.wine + s.fruits + s.meat + s.fish + s.sweets + s.gold AS total_spend,
         CASE WHEN c.Income >= 70000 THEN 'High'
              WHEN c.Income >= 35000 THEN 'Mid'
              ELSE 'Low' END AS income_bracket
  FROM customers c
  JOIN spend s ON c.customer_id = s.customer_id
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY income_bracket ORDER BY total_spend DESC) AS spend_rank
  FROM customer_totals
)
SELECT income_bracket, customer_id, Income, total_spend, spend_rank
FROM ranked
WHERE spend_rank <= 3
ORDER BY income_bracket, spend_rank;

--Q5: Share of customers vs. share of revenue by bracket
WITH customer_totals AS (
  SELECT c.customer_id,
         s.wine + s.fruits + s.meat + s.fish + s.sweets + s.gold AS total_spend,
         CASE WHEN c.Income >= 70000 THEN 'High'
              WHEN c.Income >= 35000 THEN 'Mid'
              ELSE 'Low' END AS income_bracket
  FROM customers c
  JOIN spend s ON c.customer_id = s.customer_id
)
SELECT income_bracket,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer_totals), 1) AS pct_of_customers,
       ROUND(100.0 * SUM(total_spend) / (SELECT SUM(total_spend) FROM customer_totals), 1) AS pct_of_revenue
FROM customer_totals
GROUP BY income_bracket;
