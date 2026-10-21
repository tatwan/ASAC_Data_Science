-- D13 · Lab 09 (optional) · Nakheel's customers by k-means · Solved (every query from the README, in order)
-- Needs ml.customer_features from D11 lab 08, step 3.

-- Step 1 · Look at the three columns
SELECT COUNT(*) AS customers,
       MIN(days_since_last) AS min_days, ROUND(AVG(days_since_last)) AS avg_days, MAX(days_since_last) AS max_days,
       MIN(orders_before) AS min_orders, ROUND(AVG(orders_before), 1) AS avg_orders, MAX(orders_before) AS max_orders,
       MIN(revenue_before) AS min_spend, ROUND(AVG(revenue_before)) AS avg_spend, MAX(revenue_before) AS max_spend
FROM ml.customer_features;

-- Step 2 · k-means on the raw columns
CREATE OR REPLACE MODEL ml.nakheel_seg_a
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++',
         standardize_features = FALSE) AS
SELECT days_since_last, orders_before, revenue_before
FROM ml.customer_features;

SELECT centroid_id, COUNT(*) AS customers
FROM ML.PREDICT(MODEL ml.nakheel_seg_a, (SELECT * FROM ml.customer_features))
GROUP BY centroid_id
ORDER BY customers DESC;

-- Step 3 · Scaled
CREATE OR REPLACE MODEL ml.nakheel_seg_b
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++',
         standardize_features = TRUE) AS
SELECT days_since_last, orders_before, revenue_before
FROM ml.customer_features;

SELECT centroid_id, COUNT(*) AS customers
FROM ML.PREDICT(MODEL ml.nakheel_seg_b, (SELECT * FROM ml.customer_features))
GROUP BY centroid_id
ORDER BY customers DESC;

-- Step 4 · Logs, then scaled
CREATE OR REPLACE VIEW ml.customer_features_log AS
SELECT *, LN(1 + orders_before) AS log_orders, LN(1 + revenue_before) AS log_revenue
FROM ml.customer_features;

CREATE OR REPLACE MODEL ml.nakheel_seg_c
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++',
         standardize_features = TRUE) AS
SELECT days_since_last, log_orders, log_revenue
FROM ml.customer_features_log;

-- Step 5 · Profile, and check against what happened next
SELECT centroid_id, COUNT(*) AS customers,
       ROUND(AVG(days_since_last)) AS avg_days,
       ROUND(AVG(orders_before), 1) AS avg_orders,
       ROUND(AVG(revenue_before)) AS avg_spend,
       ROUND(AVG(revenue_next_6m)) AS avg_spend_after,
       ROUND(COUNTIF(revenue_next_6m = 0) / COUNT(*), 2) AS share_bought_nothing_after
FROM ML.PREDICT(MODEL ml.nakheel_seg_c, (SELECT * FROM ml.customer_features_log))
GROUP BY centroid_id
ORDER BY avg_spend;
