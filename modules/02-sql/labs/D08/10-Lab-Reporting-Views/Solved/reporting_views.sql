-- D08 · Lab: Reporting views for Power BI and for D11

-- C1 · step 1. bi.customer_summary: one row per customer, built in two named steps. D11 builds its training table from it.
-- Creates the view; the next query checks it.
CREATE OR REPLACE VIEW bi.customer_summary AS
WITH completed AS (
  SELECT customer_id,
         COUNT(*) AS completed_orders,
         SUM(order_total) AS revenue,
         MIN(order_date) AS first_order,
         MAX(order_date) AS last_order
  FROM nakheel.orders
  WHERE status = 'completed'
  GROUP BY customer_id
)
SELECT c.customer_id,
       c.customer_name,
       c.segment,
       c.city,
       COALESCE(x.completed_orders, 0) AS completed_orders,
       ROUND(COALESCE(x.revenue, 0), 2) AS revenue,
       x.first_order,
       x.last_order
FROM bi.dim_customer AS c
LEFT JOIN completed AS x
  ON c.customer_id = x.customer_id;

-- C1 · step 2. Audit the view. (1 row: 500 customers; 2,770 orders; 315,085.50; 49 with none)
-- @check 2
SELECT COUNT(*) AS customers,
       SUM(completed_orders) AS completed_orders,
       ROUND(SUM(revenue), 2) AS revenue,
       COUNTIF(completed_orders = 0) AS customers_with_none
FROM bi.customer_summary;

-- C2 · step 3. bi.category_month: completed revenue by category and month.
-- Creates the view; the next query checks it.
CREATE OR REPLACE VIEW bi.category_month AS
SELECT p.category,
       DATE_TRUNC(f.order_date, MONTH) AS month,
       SUM(f.qty) AS units,
       SUM(f.revenue) AS revenue
FROM bi.fact_sales AS f
INNER JOIN bi.dim_product AS p
  ON f.product_id = p.product_id
WHERE f.status = 'completed'
GROUP BY p.category, month;

-- C2 · step 4. Audit: 6 categories x 24 months, and the completed total. (1 row: 144; 316,023.50)
-- @check 4
SELECT COUNT(*) AS row_count,
       ROUND(SUM(revenue), 2) AS revenue
FROM bi.category_month;

-- C3 · step 5. bi.dim_customer_complete: every customer, plus one 'unknown' row for each customer_id
-- that has orders but no customer record. Two named steps and a UNION ALL.
-- Creates the view; the next query checks it.
CREATE OR REPLACE VIEW bi.dim_customer_complete AS
WITH missing AS (
  SELECT DISTINCT o.customer_id
  FROM nakheel.orders AS o
  LEFT JOIN nakheel.customers AS c
    ON o.customer_id = c.customer_id
  WHERE c.customer_id IS NULL
)
SELECT customer_id, customer_name, city, segment, signup_date
FROM bi.dim_customer
UNION ALL
SELECT customer_id,
       'Unknown customer' AS customer_name,
       'unknown' AS city,
       'unknown' AS segment,
       CAST(NULL AS DATE) AS signup_date
FROM missing;

-- C3 · step 6. Audit: 501 rows, and the INNER JOIN no longer loses order 101664. (1 row: 6,951 lines; 316,023.50)
-- @check 6
SELECT COUNT(*) AS line_rows,
       ROUND(SUM(f.revenue), 2) AS revenue
FROM bi.fact_sales AS f
INNER JOIN bi.dim_customer_complete AS c
  ON f.customer_id = c.customer_id
WHERE f.status = 'completed';

-- C3 · step 6b. The view itself. (501 rows)
-- @check 6b
SELECT *
FROM bi.dim_customer_complete;

-- Stretch card (not checked). bi.segment_month: completed units and revenue by customer segment and month,
-- on bi.category_month's pattern. dim_customer_complete gives order 101664 the segment 'unknown'.
-- Creates the view; the next query checks it.
CREATE OR REPLACE VIEW bi.segment_month AS
SELECT c.segment,
       DATE_TRUNC(f.order_date, MONTH) AS month,
       SUM(f.qty) AS units,
       SUM(f.revenue) AS revenue
FROM bi.fact_sales AS f
INNER JOIN bi.dim_customer_complete AS c
  ON f.customer_id = c.customer_id
WHERE f.status = 'completed'
GROUP BY c.segment, month;

-- Stretch audit: 2 segments x 24 months, plus 'unknown' in November 2025 only. (1 row: 49; 316,023.50)
-- @check S1
SELECT COUNT(*) AS row_count,
       ROUND(SUM(revenue), 2) AS revenue
FROM bi.segment_month;

-- More practice (not checked, not submitted)

-- X1. "Which customers spent more than the average customer?" The average includes the 49 who spent 0.
-- (94 rows; the average is 630.17; C-1380 Leen Najjar first, 35,338.50)
-- @check X1
SELECT customer_id,
       customer_name,
       segment,
       revenue
FROM bi.customer_summary
WHERE revenue > (SELECT AVG(revenue) FROM bi.customer_summary)
ORDER BY revenue DESC;

-- X2. "Completed revenue by city, now that every order line has a customer." The D07 city-rule answer, from the views.
-- (9 rows: amman first, 1,064 orders, 130,848.00; unknown 37 orders, 3,197.00)
-- @check X2
SELECT c.city,
       COUNT(DISTINCT f.order_id) AS completed_orders,
       ROUND(SUM(f.revenue), 2) AS revenue
FROM bi.fact_sales AS f
INNER JOIN bi.dim_customer_complete AS c
  ON f.customer_id = c.customer_id
WHERE f.status = 'completed'
GROUP BY c.city
ORDER BY revenue DESC;

-- X3. "In which months did Outerwear do better than its own average month?" The category filter goes
-- inside the brackets too. (10 rows; Outerwear's average month is 3,193.21; April 2026 the best, 5,068.50)
-- @check X3
SELECT month,
       ROUND(revenue, 2) AS revenue
FROM bi.category_month
WHERE category = 'Outerwear'
  AND revenue > (SELECT AVG(revenue)
                 FROM bi.category_month
                 WHERE category = 'Outerwear')
ORDER BY month;
