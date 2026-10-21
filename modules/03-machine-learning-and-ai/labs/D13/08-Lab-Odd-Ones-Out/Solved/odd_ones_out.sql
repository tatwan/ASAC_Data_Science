-- D13 · Lab 08 · The odd ones out: anomalies from a k-means model · Solved
-- Needs ml.wholesale_logs and ml.wholesale_log_model from lab 07, step 3.

-- Step 1 · Flag the most unusual 2%
SELECT client_id, channel, fresh, milk, grocery, frozen, detergents_paper, delicatessen,
       ROUND(normalized_distance, 2) AS normalized_distance
FROM ML.DETECT_ANOMALIES(MODEL ml.wholesale_log_model,
       STRUCT(0.02 AS contamination),
       (SELECT * FROM ml.wholesale_logs))
WHERE is_anomaly
ORDER BY normalized_distance DESC;

-- Step 2 · The same query with 5% (about 22 clients)
SELECT client_id, channel, fresh, milk, grocery, frozen, detergents_paper, delicatessen,
       ROUND(normalized_distance, 2) AS normalized_distance
FROM ML.DETECT_ANOMALIES(MODEL ml.wholesale_log_model,
       STRUCT(0.05 AS contamination),
       (SELECT * FROM ml.wholesale_logs))
WHERE is_anomaly
ORDER BY normalized_distance DESC;
