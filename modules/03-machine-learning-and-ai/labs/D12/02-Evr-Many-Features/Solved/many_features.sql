-- D12 · 02 · Eight features: better than a guess, and who gets an offer? · Solved
-- Run one numbered block at a time. CREATE MODEL and the ML. functions run in BigQuery only.
-- Churn is BOOLEAN: TRUE = left, FALSE = stayed.

-- 1. Eight features, 20% held aside.
CREATE OR REPLACE MODEL ml.churn_model
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['Churn'],
  data_split_method = 'RANDOM',
  data_split_eval_fraction = 0.2
) AS
SELECT tenure, MonthlyCharges, Contract, InternetService,
       PaymentMethod, SeniorCitizen, PaperlessBilling, TechSupport,
       Churn
FROM ml.telco;

-- 2. Five scores on the 20% held aside, at threshold 0.5.
SELECT ROUND(accuracy, 3) AS accuracy, ROUND(precision, 3) AS precision,
       ROUND(recall, 3) AS recall, ROUND(f1_score, 3) AS f1,
       ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.churn_model);

-- 3. The majority guess: say FALSE (stays) for everyone.
SELECT ROUND(COUNTIF(Churn = FALSE) / COUNT(*), 3) AS majority_accuracy
FROM ml.telco;

-- 4. The confusion matrix of the held-aside rows.
SELECT *
FROM ML.CONFUSION_MATRIX(MODEL ml.churn_model);

-- 5. The ROC curve: one row per threshold.
SELECT ROUND(threshold, 2) AS threshold, ROUND(recall, 3) AS recall,
       ROUND(false_positive_rate, 3) AS false_positive_rate
FROM ML.ROC_CURVE(MODEL ml.churn_model)
ORDER BY threshold;

-- 6. The same ROC rows, in the retention team's words.
--    Find the rows closest to 0.3, 0.5 and 0.7.
SELECT ROUND(threshold, 2) AS threshold,
       true_positives + false_positives AS offers,
       true_positives AS leavers_caught,
       ROUND(recall, 2) AS recall
FROM ML.ROC_CURVE(MODEL ml.churn_model)
WHERE threshold BETWEEN 0.25 AND 0.75
ORDER BY threshold;

-- 7. The leavers by contract: how many it missed, and the share.
--    All customers, the training rows included: for looking at mistakes, not for scoring.
SELECT Contract,
       COUNT(*) AS leavers,
       COUNTIF(predicted_Churn = FALSE) AS missed,
       ROUND(COUNTIF(predicted_Churn = FALSE) / COUNT(*), 2) AS miss_rate
FROM ML.PREDICT(MODEL ml.churn_model, (SELECT * FROM ml.telco))
WHERE Churn = TRUE
GROUP BY Contract
ORDER BY miss_rate DESC;

-- 8. What it learned: read the signs.
SELECT processed_input, ROUND(weight, 3) AS weight, category_weights
FROM ML.WEIGHTS(MODEL ml.churn_model);

-- 8b. The category features' weights, one row per category.
SELECT processed_input AS feature, c.category, ROUND(c.weight, 3) AS category_weight
FROM ML.WEIGHTS(MODEL ml.churn_model), UNNEST(category_weights) AS c
ORDER BY feature, category_weight DESC;

-- 9. The same customer, two contracts.
SELECT Contract, ROUND(p.prob, 2) AS prob_leave
FROM ML.PREDICT(MODEL ml.churn_model,
  (SELECT 12 AS tenure, 70.0 AS MonthlyCharges, 'Month-to-month' AS Contract,
          'Fiber optic' AS InternetService, 'Electronic check' AS PaymentMethod,
          0 AS SeniorCitizen, TRUE AS PaperlessBilling, 'No' AS TechSupport
   UNION ALL
   SELECT 12, 70.0, 'Two year', 'Fiber optic', 'Electronic check', 0, TRUE, 'No')),
  UNNEST(predicted_Churn_probs) AS p
WHERE p.label = TRUE;
