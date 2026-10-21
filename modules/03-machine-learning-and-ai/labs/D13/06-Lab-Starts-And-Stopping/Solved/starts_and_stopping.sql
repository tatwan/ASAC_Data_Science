-- D13 · Lab 06 · The same groups every time · Solved
-- Needs ml.mall_segments from activity 01.

-- Step 1 · Training, round by round
SELECT iteration, ROUND(loss, 3) AS loss
FROM ML.TRAINING_INFO(MODEL ml.mall_segments)
ORDER BY iteration;

-- Step 2 · Start from five shoppers we choose
CREATE OR REPLACE MODEL ml.mall_fixed
OPTIONS (model_type = 'KMEANS', num_clusters = 5,
         kmeans_init_method = 'CUSTOM', kmeans_init_col = 'is_start') AS
SELECT annual_income_k, spending_score,
       customer_id IN (1, 2, 41, 124, 125) AS is_start
FROM ml.mall;

SELECT centroid_id, COUNT(*) AS shoppers
FROM ML.PREDICT(MODEL ml.mall_fixed, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY shoppers DESC;

-- Step 3 · Run both statements of step 2 again: the same sizes every time.

-- Bonus · One round only
CREATE OR REPLACE MODEL ml.mall_one_round
OPTIONS (model_type = 'KMEANS', num_clusters = 5, kmeans_init_method = 'KMEANS++',
         max_iterations = 1) AS
SELECT annual_income_k, spending_score
FROM ml.mall;

SELECT ROUND(mean_squared_distance, 3) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.mall_one_round);
