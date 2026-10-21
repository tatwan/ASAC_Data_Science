-- D13 · 04 · Judging the segments: profiles, a score, k, and a second run · Solved
-- Needs ml.mall and ml.mall_segments from activity 01. Run one numbered block at a time.

-- 1. A profile of each group, in original units, with the columns the model did not use.
SELECT centroid_id,
       COUNT(*) AS shoppers,
       ROUND(AVG(annual_income_k), 1) AS avg_income_k,
       ROUND(AVG(spending_score), 1) AS avg_score,
       ROUND(AVG(age), 1) AS avg_age,
       ROUND(COUNTIF(gender = 'Female') / COUNT(*), 2) AS share_women
FROM ML.PREDICT(MODEL ml.mall_segments, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY avg_income_k;

-- 2. The two numbers BigQuery gives a k-means model.
SELECT ROUND(davies_bouldin_index, 3) AS davies_bouldin,
       ROUND(mean_squared_distance, 3) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.mall_segments);

-- 3. Six groups instead of five: train, score, profile.
CREATE OR REPLACE MODEL ml.mall_k6
OPTIONS (
  model_type = 'KMEANS',
  num_clusters = 6,
  kmeans_init_method = 'KMEANS++',
  standardize_features = TRUE
) AS
SELECT annual_income_k, spending_score
FROM ml.mall;

SELECT ROUND(davies_bouldin_index, 3) AS davies_bouldin,
       ROUND(mean_squared_distance, 3) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.mall_k6);

SELECT centroid_id,
       COUNT(*) AS shoppers,
       ROUND(AVG(annual_income_k), 1) AS avg_income_k,
       ROUND(AVG(spending_score), 1) AS avg_score,
       ROUND(AVG(age), 1) AS avg_age
FROM ML.PREDICT(MODEL ml.mall_k6, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY avg_income_k;

-- 4. Train the five-group model again under a new name, and compare the two runs.
CREATE OR REPLACE MODEL ml.mall_segments_2
OPTIONS (
  model_type = 'KMEANS',
  num_clusters = 5,
  kmeans_init_method = 'KMEANS++',
  standardize_features = TRUE
) AS
SELECT annual_income_k, spending_score
FROM ml.mall;

-- Compare with block 2's mean squared distance for the first run.
SELECT ROUND(mean_squared_distance, 3) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.mall_segments_2);

SELECT centroid_id, COUNT(*) AS shoppers, ROUND(AVG(annual_income_k), 1) AS avg_income_k,
       ROUND(AVG(spending_score), 1) AS avg_score
FROM ML.PREDICT(MODEL ml.mall_segments_2, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY avg_income_k;

-- 5. Partner task: no SQL. Name each group and give it one action (sample answer in the slides).
