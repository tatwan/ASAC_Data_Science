-- D11 · 03 · Many features, scored honestly · Solved
-- Run one numbered block at a time. CREATE MODEL and the ML. functions run in BigQuery only.
-- (Upload insurance.csv as the table ml.insurance first: see the README.)

-- 1. Look first. One row is one insured person. Then: smokers against non-smokers.
SELECT *
FROM ml.insurance
LIMIT 10;

SELECT smoker,
       COUNT(*) AS people,
       ROUND(AVG(charges)) AS avg_charges
FROM ml.insurance
GROUP BY smoker;

-- 2. Train on six features, holding 20% of the rows aside for scoring.
CREATE OR REPLACE MODEL ml.insurance_model
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['charges'],
  data_split_method = 'RANDOM',
  data_split_eval_fraction = 0.2
) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance;

-- 3. Ask it about five people. charges is what they cost; predicted is the model's estimate.
SELECT age, smoker, bmi,
       ROUND(charges) AS charges,
       ROUND(predicted_charges) AS predicted
FROM ML.PREDICT(MODEL ml.insurance_model,
  (SELECT * FROM ml.insurance))
LIMIT 5;

-- 4. Score it on the 20% held aside.
SELECT ROUND(mean_absolute_error) AS mae,
       ROUND(SQRT(mean_squared_error)) AS rmse,
       ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.insurance_model);

-- 5. The guess to beat: the average for everyone. Its average miss:
SELECT ROUND(AVG(charges)) AS guess
FROM ml.insurance;

SELECT ROUND(AVG(ABS(charges - 13270))) AS mae_of_the_guess
FROM ml.insurance;

-- 6. Seen rows against unseen rows: close scores mean no overfitting.
SELECT 'held aside (unseen)' AS scored_on, ROUND(r2_score, 3) AS r2, ROUND(mean_absolute_error) AS mae
FROM ML.EVALUATE(MODEL ml.insurance_model)
UNION ALL
SELECT 'all rows (mostly seen)', ROUND(r2_score, 3), ROUND(mean_absolute_error)
FROM ML.EVALUATE(MODEL ml.insurance_model, (SELECT * FROM ml.insurance));

-- 7. What it learned. Text and true/false features keep one weight per value in category_weights.
SELECT processed_input, ROUND(weight, 1) AS weight, category_weights
FROM ML.WEIGHTS(MODEL ml.insurance_model);

-- 8. Two new people, the same except for smoking.
--    smoker is BOOLEAN (Auto detect read the file's yes/no as true/false): write FALSE and TRUE.
SELECT smoker, ROUND(predicted_charges) AS predicted_charges
FROM ML.PREDICT(MODEL ml.insurance_model,
  (SELECT 40 AS age, 'female' AS sex, 28.0 AS bmi, 1 AS children, FALSE AS smoker, 'northwest' AS region
   UNION ALL
   SELECT 40, 'female', 28.0, 1, TRUE, 'northwest'));
