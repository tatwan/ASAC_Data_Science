-- D12 · 01 · A first classifier: will this customer leave? · Starter
-- Run one numbered block at a time. CREATE MODEL and the ML. functions run in BigQuery only.
-- Churn is BOOLEAN: TRUE = left, FALSE = stayed (Auto detect read Yes/No that way).

-- 1. Which values of TotalCharges are not numbers?
SELECT tenure, TotalCharges
FROM ml.telco
WHERE SAFE_CAST(TotalCharges AS FLOAT64) IS NULL;

-- 2. Who leaves, by contract?
SELECT Contract,
       COUNT(*) AS customers,
       ROUND(COUNTIF(Churn = TRUE) / COUNT(*), 3) AS share_left
FROM ml.telco
GROUP BY Contract
ORDER BY share_left DESC;

-- 3. Train on one feature, 20% held aside.
CREATE OR REPLACE MODEL ml.churn_tenure
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['Churn'],
  data_split_method = 'RANDOM',
  data_split_eval_fraction = 0.2
) AS
SELECT tenure, Churn
FROM ml.telco;

-- 4. Five customers: the probability of leaving.
SELECT customerID, tenure, Churn,
       ROUND(p.prob, 3) AS prob_leave
FROM ML.PREDICT(MODEL ml.churn_tenure,
       (SELECT * FROM ml.telco LIMIT 5)),
     UNNEST(predicted_Churn_probs) AS p
WHERE p.label = TRUE;

-- 5. What it learned.
SELECT processed_input, ROUND(weight, 4) AS weight
FROM ML.WEIGHTS(MODEL ml.churn_tenure);
