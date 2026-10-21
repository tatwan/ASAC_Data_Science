-- D13 · Lab 05 · Choosing k: why five groups? · Solved
-- Needs ml.mall_segments (k = 5, activity 01) and ml.mall_k6 (k = 6, activity 04 block 3).

-- Step 1 · Three and four groups
CREATE OR REPLACE MODEL ml.mall_k3
OPTIONS (model_type = 'KMEANS', num_clusters = 3, kmeans_init_method = 'KMEANS++') AS
SELECT annual_income_k, spending_score
FROM ml.mall;

CREATE OR REPLACE MODEL ml.mall_k4
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++') AS
SELECT annual_income_k, spending_score
FROM ml.mall;

-- Step 2 · Score each k: run once per model, changing only the name
-- (ml.mall_k3, ml.mall_k4, ml.mall_segments, ml.mall_k6).
SELECT ROUND(davies_bouldin_index, 2) AS davies_bouldin,
       ROUND(mean_squared_distance, 2) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.mall_k3);

-- Step 3 · Profiles for k = 4
SELECT centroid_id, COUNT(*) AS shoppers,
       ROUND(AVG(annual_income_k), 1) AS avg_income_k,
       ROUND(AVG(spending_score), 1) AS avg_score,
       ROUND(AVG(age), 1) AS avg_age
FROM ML.PREDICT(MODEL ml.mall_k4, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY avg_income_k;
