-- D10 · Lab (after class): Best sellers and trends

-- C1. Ranked by units inside each category. (56 rows; Sportswear tie on 284 at rank 6)
-- @check C1
WITH product_units AS (
  SELECT p.category,
         p.product_name,
         SUM(i.qty) AS units
  FROM nakheel.order_items AS i
  INNER JOIN nakheel.orders AS o
    ON i.order_id = o.order_id
  INNER JOIN nakheel.products AS p
    ON i.product_id = p.product_id
  WHERE o.status = 'completed'
  GROUP BY p.category, p.product_name
)
SELECT category,
       product_name,
       units,
       RANK() OVER (PARTITION BY category ORDER BY units DESC) AS unit_rank,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY units DESC) AS unit_dense_rank
FROM product_units
ORDER BY category, unit_rank, product_name;

-- C2. Each channel by month. (48 rows; online's biggest rise August 2025, +2,399.00)
-- @check C2
WITH channel_month AS (
  SELECT channel,
         DATE_TRUNC(order_date, MONTH) AS month,
         SUM(order_total) AS revenue
  FROM nakheel.orders
  WHERE status = 'completed'
  GROUP BY channel, month
)
SELECT channel,
       month,
       revenue,
       revenue - LAG(revenue) OVER (PARTITION BY channel ORDER BY month) AS change,
       SUM(revenue) OVER (PARTITION BY channel ORDER BY month) AS running_total
FROM channel_month
ORDER BY channel, month;

-- C2 audit: completed revenue per channel. (2 rows: online 110,685.50, store 205,338.00)
SELECT channel,
       SUM(order_total) AS revenue
FROM nakheel.orders
WHERE status = 'completed'
GROUP BY channel
ORDER BY channel;

-- C3. Top three by units in each category, with their share. (18 rows; Slide sandal 19.4)
-- @check C3
WITH product_units AS (
  SELECT p.category,
         p.product_name,
         SUM(i.qty) AS units
  FROM nakheel.order_items AS i
  INNER JOIN nakheel.orders AS o
    ON i.order_id = o.order_id
  INNER JOIN nakheel.products AS p
    ON i.product_id = p.product_id
  WHERE o.status = 'completed'
  GROUP BY p.category, p.product_name
)
SELECT category,
       product_name,
       units,
       RANK() OVER (PARTITION BY category ORDER BY units DESC) AS unit_rank,
       ROUND(100 * units / SUM(units) OVER (PARTITION BY category), 1) AS share_of_category_units
FROM product_units
QUALIFY unit_rank <= 3
ORDER BY category, unit_rank;

-- More practice (not checked). Each customer's most recent completed order.
-- (452 rows: one per customer who has bought)
SELECT customer_id,
       order_id,
       order_date,
       order_total
FROM nakheel.orders
WHERE status = 'completed'
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id
                           ORDER BY order_date DESC, order_id DESC) = 1
ORDER BY customer_id;

-- More practice, optional. The D07 city rule written once, as a SQL function.
-- Run both statements together in BigQuery. (9 rows: amman 196 first; unknown 6)
-- @skip BigQuery only; CREATE TEMP FUNCTION
CREATE TEMP FUNCTION clean_city(city STRING) AS (
  CASE
    WHEN city IS NULL THEN 'unknown'
    WHEN LOWER(TRIM(city)) = 'al zarqa' THEN 'zarqa'
    ELSE LOWER(TRIM(city))
  END
);

-- @skip BigQuery only; needs the function above
SELECT clean_city(city) AS city_clean,
       COUNT(*) AS customers
FROM nakheel.customers
GROUP BY city_clean
ORDER BY customers DESC;

-- (instructor check, not part of the ask) The same answer with the CASE written out, which the
-- function replaces, so the DuckDB runner can check the 9 rows. (9 rows: amman 196 first)
SELECT CASE
         WHEN city IS NULL THEN 'unknown'
         WHEN LOWER(TRIM(city)) = 'al zarqa' THEN 'zarqa'
         ELSE LOWER(TRIM(city))
       END AS city_clean,
       COUNT(*) AS customers
FROM nakheel.customers
GROUP BY city_clean
ORDER BY customers DESC;
