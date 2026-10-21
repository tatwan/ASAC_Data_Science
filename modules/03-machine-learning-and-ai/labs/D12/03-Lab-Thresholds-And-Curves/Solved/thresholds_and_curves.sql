-- D12 · Lab 03 · Thresholds: from a probability to a decision · Solved
-- Needs ml.churn_tenure (activity 01) and ml.churn_model (activity 02).
-- Churn is BOOLEAN: TRUE = left, FALSE = stayed.

-- Step 1. Ten customers at threshold 0.3. Run again with 0.7: the probabilities stay, the answers change.
SELECT customerID,
       ROUND(p.prob, 2) AS prob_leave,
       predicted_Churn
FROM ML.PREDICT(MODEL ml.churn_model,
       (SELECT * FROM ml.telco ORDER BY customerID LIMIT 10),
       STRUCT(0.3 AS threshold)),
     UNNEST(predicted_Churn_probs) AS p
WHERE p.label = TRUE;

-- Step 2. The ROC curve, on the 20% held aside. Chart: x false_positive_rate, y recall.
SELECT ROUND(false_positive_rate, 3) AS false_positive_rate,
       ROUND(recall, 3) AS recall
FROM ML.ROC_CURVE(MODEL ml.churn_model)
ORDER BY false_positive_rate;

-- Step 3. Price every threshold: a caught leaver is worth about 117, a wasted offer costs 50.
SELECT ROUND(threshold, 2) AS threshold,
       true_positives + false_positives AS offers,
       true_positives * 117 - false_positives * 50 AS campaign_value
FROM ML.ROC_CURVE(MODEL ml.churn_model)
ORDER BY campaign_value DESC
LIMIT 5;

-- Step 3, offers at 100: a caught leaver is worth about 67, a wasted offer costs 100.
SELECT ROUND(threshold, 2) AS threshold,
       true_positives + false_positives AS offers,
       true_positives * 67 - false_positives * 100 AS campaign_value
FROM ML.ROC_CURVE(MODEL ml.churn_model)
ORDER BY campaign_value DESC
LIMIT 5;

-- Step 4. Which model ranks customers better?
SELECT 'tenure only' AS model, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.churn_tenure)
UNION ALL
SELECT 'eight features', ROUND(roc_auc, 3)
FROM ML.EVALUATE(MODEL ml.churn_model);

-- Bonus. Precision against recall.
SELECT ROUND(threshold, 2) AS threshold,
       ROUND(recall, 2) AS recall,
       ROUND(true_positives / (true_positives + false_positives), 2) AS precision
FROM ML.ROC_CURVE(MODEL ml.churn_model)
WHERE threshold BETWEEN 0.1 AND 0.75
ORDER BY recall;
