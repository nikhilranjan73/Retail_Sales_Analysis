CREATE  DATABASE A_sales_store

USE A_sales_store

CREATE TABLE MYstore (
        transaction_id VARCHAR(15),
        customer_id VARCHAR (15),
        customer_name VARCHAR (30),
        customer_age INT,
        gender VARCHAR(15),
        product_id VARCHAR(15),
        product_name VARCHAR(30),
        product_category VARCHAR(15),
        quantiy INT,
        prce FLOAT,
        payment_mode VARCHAR(50),
        purchase_date DATE,
        time_of_purchase TIME,
        status VARCHAR(50)
        )

SELECT * FROM MYstore

SET DATEFORMAT dmy
BULK INSERT MYstore
FROM 'D:\PROJECTS\sales.csv'
    WITH (
        FIRSTROW=2,
        FIELDTERMINATOR =',',
        ROWTERMINATOR = '\n'
        )

SELECT * FROM sales_store

--copy of data --
SELECT * INTO MYstore FROM sales_store

-- Data cleaning --
-- Step 1 - Check Duplicate

SELECT Transaction_id, count(*)
FROM MYstore
GROUP BY transaction_id
HAVING count(transaction_id)>1

TXN240646
TXN342128
TXN855235
TXN981773

WITH CTE AS(
            SELECT *,
                 ROW_NUMBER () OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_num
            FROM MYstore
            )
DELETE FROM CTE
WHERE Row_num =2 

SELECT * FROM CTE
WHERE Row_num >1

-- Step 2 - correction of header name

EXEC sp_rename 'MYstore.quantiy','quantity','column'
EXEC sp_rename 'MYstore.prce','price','column'
select * from MYstore

-- step 3 To check datatype

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNs
WHERE TABLE_NAME = 'MYSTORE'

--Step 4 To check null value

SELECT *
FROM MYstore 
WHERE transaction_id IS NULL
       OR 
       customer_id IS NULL
       OR
       customer_name IS NULL
       OR
       customer_age IS NULL
       OR
       gender IS NULL
       OR 
       product_id IS NULL
       OR
       product_name IS NULL
       OR
       product_category IS NULL
       OR
       quantity IS NULL
       OR
       price IS NULL
       OR
       payment_mode IS NULL
       OR
       purchase_date IS NULL
       OR
       time_of_purchase IS NULL
       OR
       status IS NULL

DELETE FROM MYstore
WHERE TRANSACTION_ID IS NULL

SELECT *
FROM MYstore
WHERE customer_name = 'Ehsaan Ram'

UPDATE MYstore
SET customer_id = 'CUST9494'
WHERE TRANSACTION_ID = 'TXN977900'

SELECT *
FROM MYstore
WHERE customer_name = 'Damini Raju'

UPDATE MYstore
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663'

SELECT *
FROM MYstore
WHERE customer_id = 'CUST1003'

UPDATE MYstore
SET customer_name='Mahika Saini', customer_age=35, gender= 'Male'
WHERE transaction_id = 'TXN432798'

SELECT *
FROM MYstore

-- step 5 Data Cleaning
SELECT DISTINCT gender
FROM MYstore

UPDATE MYstore
SET gender='M'
WHERE gender = 'Male'

UPDATE MYstore
SET gender='F'
WHERE gender = 'Female'

SELECT DISTINCT payment_mode
FROM MYstore

UPDATE MYstore
SET payment_mode='Credit Card'
WHERE payment_mode='CC'
 -----------------------------------------------------------------------------------------------------------------------
 -- Data Analysis
 ------------------------------------------------------------------------------------------------
 -- 1. What are top 5 most selling product by quantity

 SELECT TOP 5 product_name, SUM(quantity) AS total_quantity_sold
 FROM MYstore
 WHERE status = 'delivered'
 GROUP BY product_name
 ORDER BY total_quantity_sold DESC

 -- Business problem - We don't know which products are mostin demand?
 -- Business Impact - Helps to prioritize stock and boost sales through targeted promotion.
 -------------------------------------------------------------------------------------------------------------------

-- Q2 Which products are most frequently canceled?

SELECT TOP 5 product_name, SUM(quantity) AS total_canceled
 FROM MYstore
 WHERE status = 'cancelled'
 GROUP BY product_name
 ORDER BY total_canceled DESC

 -- Business problem : frequently cancellation affect revenue and consumer trust
 -- Business Impact: Identify poor performing product to improve qualit or remove from catalogs.
 ----------------------------------------------------------------------------------------------------------------------------------------

 -- Q3 What time of the day has the highest number of purchase

 SELECT* FROM MYstore
   SELECT
       CASE 
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
       END AS time_of_day,
       COUNT(*) AS total_orders
    FROM MYstore
    GROUP BY 
          CASE 
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
          WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
       END
    ORDER BY total_orders DESC
-- Business problem : Find peak sales time
-- Business Impact : Optimize staffing, promotions, and server loads
---------------------------------------------------------------------------------------------------------------------------------

-- Q4 Who are the top 5 highest spending customers?
SELECT * FROM MYstore

SELECT TOP 5 customer_name, FORMAT(SUM(price*quantity),'C0','en-IN') AS total_spend
FROM MYstore
GROUP BY customer_name
ORDER BY total_spend DESC

-- BUSINESS PROBLEM:Identify VIP customers.
-- Business Impact :Personalized offers, loyalty rewards, and retention.
--------------------------------------------------------------------------------------------------------------------------------------

-- Q5. which product categories generate the highest revenue?
SELECT * FROM MYstore

SELECT product_category, FORMAT(SUM(price*quantity),'C0','en-IN') AS revenue
FROM MYstore
GROUP BY product_category
ORDER BY SUM(price*quantity) DESC

--BUSINESS PROBLEM:Identify top-performing product categories
--BUSINESS IMPACT: Refine product strategy, supply chain, and promotions
-- allowing the business to invest more in high-margin or high-demand categories.
-----------------------------------------------------------------------------------------------------------------------------------------

-- Q6. What is the return and cancellation rate per product category?

SELECT * FROM MYstore
--cancellation
SELECT product_category,
      FORMAT( COUNT(CASE
                 WHEN status = 'cancelled'THEN 1
             END)*100.0/COUNT(*), 'N3')+' %' AS cancelled_pecentage
FROM MYstore
GROUP BY product_category
ORDER BY cancelled_pecentage DESC

-- RETURN PERCENTAGE
SELECT product_category,
      FORMAT( COUNT(CASE
                 WHEN status = 'returned'THEN 1
             END)*100.0/COUNT(*), 'N3')+' %' AS cancelled_pecentage
FROM MYstore
GROUP BY product_category
ORDER BY cancelled_pecentage DESC

-- BUSINESS PROBLEM : monitor dissatisfaction trends per category
-- BUSINESS IMPACT: reduce return, improve product descriptions/expectations
-- Helps identify and fix product or logistics issues.
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q7. what is the most prefered payment mode?

SELECT* FROM MYstore

SELECT payment_mode, COUNT(*) AS num_of_payment
FROM MYstore
GROUP BY payment_mode
ORDER BY COUNT(*) DESC

-- BUSINESS PROBLEM: know which paymentt option customers prefer.
-- BUSINESS IMPACT : streamline payment processing, prioritize popular modes.
------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q8. How does age group affect purchasing behaviour?

SELECT* FROM MYstore

SELECT 
       CASE
           WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
           WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
           WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
           ELSE '51+'
       END AS customer_age_group,
       FORMAT(SUM(price*quantity), 'C0', 'en-IN') AS total_purchase
FROM MYstore
GROUP BY CASE
           WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
           WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
           WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
           ELSE '51+'
       END
ORDER BY SUM(price*quantity) DESC

-- BUSINESS PROBLEM : Understand customer demographics
-- BUSINESS IMPACT: Trageted marketing and product recommendations by age group
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q9 What's the monthly sales trend?
SELECT * FROM MYstore

SELECT 
     FORMAT(purchase_date, 'yyyy-MM'),
     FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
     SUM(quantity) AS total_quantity
FROM MYstore
GROUP BY FORMAT(purchase_date, 'yyyy-MM')

-- METHOD 2 
SELECT 
     month(purchase_date) as months,
     FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
     SUM(quantity) AS total_quantity
FROM MYstore
GROUP BY month(purchase_date)
ORDER BY month(purchase_date)

-- BUSINESS PROBLEM: Sales flactuation go unnoticed.
-- BUSINESS IMPACT: Plan inventory and marketing according to seasonal trends.
---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q10. Are certain gender buying more specific categories?

SELECT* FROM MYstore

SELECT product_category, gender, count(*) AS total_num
FROM MYstore
GROUP BY product_category, gender
ORDER BY count(*) DESC

-- BUSINESS PROBLEM: Gender based product preference
-- BUSINESS IMPACT: Personalized ads, gender-focused campaigns