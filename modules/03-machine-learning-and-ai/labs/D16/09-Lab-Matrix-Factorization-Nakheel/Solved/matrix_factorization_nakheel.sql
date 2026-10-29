-- D16 · Lab 09 · Recommending products to Nakheel's customers (optional) · Solved (every query from the README, in order)
-- Self-guided: run one statement at a time.

-- Step 1 · One row per customer and product (C1)
SELECT status, COUNT(*) AS orders_placed
FROM nakheel.orders
GROUP BY status
ORDER BY orders_placed DESC;

CREATE OR REPLACE TABLE ml.customer_product_units AS
SELECT o.customer_id, i.product_id, SUM(i.qty) AS units
FROM nakheel.order_items AS i
JOIN nakheel.orders AS o ON o.order_id = i.order_id
WHERE o.status = 'completed'
GROUP BY o.customer_id, i.product_id;

SELECT COUNT(*) AS pairs,
       COUNT(DISTINCT customer_id) AS customer_count,
       COUNT(DISTINCT product_id) AS product_count,
       SUM(units) AS total_units,
       MAX(units) AS most_units
FROM ml.customer_product_units;

-- Step 2 · Train the recommender
CREATE OR REPLACE MODEL ml.nakheel_recommender
OPTIONS (model_type = 'MATRIX_FACTORIZATION',
         feedback_type = 'IMPLICIT',
         user_col = 'customer_id',
         item_col = 'product_id',
         rating_col = 'units') AS
SELECT customer_id, product_id, units
FROM ml.customer_product_units;

-- Step 3 · Every product, scored for one customer
SELECT *
FROM ML.RECOMMEND(MODEL ml.nakheel_recommender)
WHERE customer_id = 'C-1002'
ORDER BY predicted_units_confidence DESC;

-- Step 4 · The top five C-1002 has not bought (C2)
SELECT r.product_id, p.product_name, p.category,
       ROUND(r.predicted_units_confidence, 3) AS confidence
FROM ML.RECOMMEND(MODEL ml.nakheel_recommender) AS r
JOIN nakheel.products AS p ON p.product_id = r.product_id
LEFT JOIN ml.customer_product_units AS b
  ON b.customer_id = r.customer_id AND b.product_id = r.product_id
WHERE r.customer_id = 'C-1002'
  AND b.product_id IS NULL
ORDER BY confidence DESC
LIMIT 5;

-- Step 5 · Every customer's top five, as a view (C3)
CREATE OR REPLACE VIEW ml.v_customer_recommendations AS
SELECT r.customer_id, c.customer_name,
       ROW_NUMBER() OVER (PARTITION BY r.customer_id
                          ORDER BY r.predicted_units_confidence DESC) AS recommendation_rank,
       r.product_id, p.product_name, p.category,
       ROUND(r.predicted_units_confidence, 3) AS confidence
FROM ML.RECOMMEND(MODEL ml.nakheel_recommender) AS r
JOIN nakheel.products AS p ON p.product_id = r.product_id
LEFT JOIN nakheel.customers AS c ON c.customer_id = r.customer_id
LEFT JOIN ml.customer_product_units AS b
  ON b.customer_id = r.customer_id AND b.product_id = r.product_id
WHERE b.product_id IS NULL
QUALIFY recommendation_rank <= 5;

SELECT COUNT(*) AS recommendations,
       COUNT(DISTINCT customer_id) AS customer_count
FROM ml.v_customer_recommendations;
