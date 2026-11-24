-- =====================================================
-- Project : Superstore Sales Analysis (MySQL + Tableau)
-- File    : 02_sql_basics.sql
-- Goal    : Learn and practice core SQL on the raw data:
--           SELECT, WHERE, ORDER BY, aggregates, GROUP BY, HAVING
-- Table   : raw_superstore (loaded in 01_setup_and_load.sql)
-- =====================================================

USE retail_sales_project;

-- -----------------------------------------------------
-- 1. SELECT and LIMIT: look at the data
-- -----------------------------------------------------
-- Count the rows (expected: 9994)
SELECT COUNT(*) AS total_rows FROM raw_superstore;

-- First 10 rows, all columns
SELECT * FROM raw_superstore LIMIT 10;

-- Only some columns
SELECT order_id, customer_name, sales, profit
FROM raw_superstore
LIMIT 10;

-- -----------------------------------------------------
-- 2. WHERE: filter rows
-- -----------------------------------------------------
-- Line items that lost money
SELECT order_id, product_name, sales, profit
FROM raw_superstore
WHERE profit < 0
LIMIT 20;

-- Furniture sold in the West region
SELECT order_id, product_name, sales
FROM raw_superstore
WHERE category = 'Furniture' AND region = 'West';

-- Products with "chair" in the name
SELECT DISTINCT product_name
FROM raw_superstore
WHERE product_name LIKE '%chair%';

-- -----------------------------------------------------
-- 3. ORDER BY: sort (ASC = smallest first, DESC = biggest first)
-- -----------------------------------------------------
-- 10 biggest single sales lines
SELECT product_name, sales
FROM raw_superstore
ORDER BY sales DESC
LIMIT 10;

-- -----------------------------------------------------
-- 4. Aggregate functions: many rows into one number
-- -----------------------------------------------------
-- Overall summary (one row = one line item, so COUNT(*) is NOT orders)
SELECT COUNT(*)                      AS total_rows,
       COUNT(DISTINCT order_id)      AS total_orders,
       COUNT(DISTINCT customer_id)   AS total_customers,
       ROUND(SUM(sales), 2)          AS total_sales,
       ROUND(SUM(profit), 2)         AS total_profit,
       ROUND(AVG(discount), 3)       AS avg_discount
FROM raw_superstore;

-- -----------------------------------------------------
-- 5. GROUP BY: "for each ..., give me ..."
-- -----------------------------------------------------
-- Sales, profit and margin by category
SELECT category,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM raw_superstore
GROUP BY category
ORDER BY total_profit DESC;

-- -----------------------------------------------------
-- 6. HAVING: filter groups after they are calculated
-- -----------------------------------------------------
-- Sub-categories that lose money overall
SELECT sub_category,
       ROUND(SUM(profit), 2) AS total_profit
FROM raw_superstore
GROUP BY sub_category
HAVING SUM(profit) < 0;

-- =====================================================
-- HOMEWORK QUERIES
-- =====================================================

-- H1. Sales, profit and margin by region
SELECT region,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM raw_superstore
GROUP BY region
ORDER BY total_profit DESC;

-- H2. Top 5 customers by total sales
-- (DESC is needed, otherwise you get the 5 smallest)
SELECT customer_name,
       ROUND(SUM(sales), 2) AS total_sales
FROM raw_superstore
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 5;

-- H3. Sub-categories with average discount above 0.2
SELECT sub_category,
       ROUND(AVG(discount), 2) AS avg_discount
FROM raw_superstore
GROUP BY sub_category
HAVING AVG(discount) > 0.2
ORDER BY avg_discount DESC;

-- =====================================================
-- LEAD TO INVESTIGATE: why is Furniture margin so low?
-- Check whether high-discount sub-categories have the lowest profit.
-- =====================================================
SELECT sub_category,
       ROUND(SUM(sales), 2)    AS total_sales,
       ROUND(SUM(profit), 2)   AS total_profit,
       ROUND(AVG(discount), 2) AS avg_discount
FROM raw_superstore
GROUP BY sub_category
ORDER BY total_profit ASC;
