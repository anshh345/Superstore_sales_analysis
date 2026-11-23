-- =====================================================
-- Project : Superstore Sales Analysis (MySQL + Tableau)
-- File    : 01_setup_and_load.sql
-- Goal    : Create the database and raw table, load the CSV,
--           and verify the load against the source file
-- =====================================================

-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS retail_sales_project;
USE retail_sales_project;

-- 2. Raw table: data is stored exactly as it comes in the CSV.
--    Dates are kept as text here and converted in 02_cleaning.sql.
--    Postal code is VARCHAR so leading zeros are not lost.
CREATE TABLE IF NOT EXISTS raw_superstore (
    row_id        INT,
    order_id      VARCHAR(20),
    order_date    VARCHAR(20),
    ship_date     VARCHAR(20),
    ship_mode     VARCHAR(30),
    customer_id   VARCHAR(20),
    customer_name VARCHAR(100),
    segment       VARCHAR(30),
    country       VARCHAR(50),
    city          VARCHAR(100),
    state         VARCHAR(100),
    postal_code   VARCHAR(10),
    region        VARCHAR(20),
    product_id    VARCHAR(30),
    category      VARCHAR(30),
    sub_category  VARCHAR(30),
    product_name  VARCHAR(255),
    sales         DECIMAL(12,4),
    quantity      INT,
    discount      DECIMAL(5,2),
    profit        DECIMAL(12,4)
);

-- 3. Allow loading local files.
--    Also needed in Workbench: Edit Connection > Advanced > Others:
--    OPT_LOCAL_INFILE=1   (then reconnect)
SET GLOBAL local_infile = 1;

-- 4. Empty the table so a re-run never creates duplicate rows
TRUNCATE TABLE raw_superstore;

-- 5. Load the CSV (use forward slashes in the path).
--    Change the path to where your file is.
--    If 0 rows load, change '\r\n' to '\n'.
LOAD DATA LOCAL INFILE 'C:/Users/ANASWARA/Downloads/archive/Sample - Superstore.csv'
INTO TABLE raw_superstore
CHARACTER SET latin1
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- 6. Verify the load against the source file.
--    Expected: 9994 rows, sales about 2297200.86, profit about 286397.02
SELECT COUNT(*)              AS total_rows,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM raw_superstore;

-- 7. Row ID range check (first_id 1, last_id 9994, total_rows 9994)
SELECT MIN(row_id) AS first_id,
       MAX(row_id) AS last_id,
       COUNT(*)    AS total_rows
FROM raw_superstore;

-- 8. Housekeeping: remove the first, incomplete import (9,694 rows)
--    Run only if this table still exists.
-- DROP TABLE IF EXISTS `sample - superstore`;

-- NOTE FOR README:
-- The first import with the Workbench wizard lost 300 rows.
-- Found by comparing the row count with the CSV (9,694 vs 9,994),
-- fixed by reloading with LOAD DATA LOCAL INFILE.
