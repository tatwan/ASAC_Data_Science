-- D13 · 01 · A first clustering: what kinds of shoppers does the mall have? · Starter
-- Run one numbered block at a time. CREATE MODEL and the ML. functions run in BigQuery only.

-- 1. Check the upload: how many shoppers, and the range of the two columns we will compare.
SELECT COUNT(*) AS shoppers,
       MIN(annual_income_k) AS min_income, MAX(annual_income_k) AS max_income,
       MIN(spending_score) AS min_score, MAX(spending_score) AS max_score
FROM ml.mall;

-- 2. Five rows. One row is one shopper; no column says which group they belong to.
SELECT *
FROM ml.mall
ORDER BY customer_id
LIMIT 5;

-- 3. Train: five groups from income and spending score only.
--    No input_label_cols: clustering has no label.
--    Every selected column is used to measure distance, so customer_id, age and gender stay out.
CREATE OR REPLACE MODEL ml.mall_segments
OPTIONS (
  model_type = 'KMEANS',
  num_clusters = 5,
  kmeans_init_method = 'KMEANS++',
  standardize_features = TRUE
) AS
SELECT annual_income_k, spending_score
FROM ml.mall;

-- 4. How big is each group? The numbers 1-5 are labels, not a ranking.
SELECT centroid_id, COUNT(*) AS shoppers
FROM ML.PREDICT(MODEL ml.mall_segments, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY shoppers DESC;

-- 5. Five shoppers from group 1. Change 1 to 2, 3, 4, 5 to look at the other groups.
SELECT centroid_id, customer_id, annual_income_k, spending_score
FROM ML.PREDICT(MODEL ml.mall_segments, (SELECT * FROM ml.mall))
WHERE centroid_id = 1
LIMIT 5;

-- 6. The centre of each group, in thousands of dollars and score points.
SELECT centroid_id, feature, ROUND(numerical_value, 1) AS centre
FROM ML.CENTROIDS(MODEL ml.mall_segments)
ORDER BY centroid_id, feature;

-- 7. Two shoppers' distances to every centre (scaled units), nearest first.
SELECT customer_id, centroid_id, nearest_centroids_distance
FROM ML.PREDICT(MODEL ml.mall_segments,
       (SELECT * FROM ml.mall WHERE customer_id IN (3, 124)));
