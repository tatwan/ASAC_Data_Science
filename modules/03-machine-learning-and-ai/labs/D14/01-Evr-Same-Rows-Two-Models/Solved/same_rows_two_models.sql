-- D14 · 01 · The same rows for every model, and two models on them · Solved
-- Run one numbered block at a time. CREATE MODEL and the ML. functions run in BigQuery only.
-- You need ml.insurance from D11 (activity 03). If it is missing, upload insurance.csv first: see the README.

-- 1. Fix the groups once. Number the people in order of their charges, then deal them out like cards:
--    of every five, three go to training, one to validation, one to test.
CREATE OR REPLACE VIEW ml.insurance_groups AS
SELECT *,
       CASE MOD(ROW_NUMBER() OVER (ORDER BY charges), 5)
         WHEN 3 THEN 'validation'
         WHEN 4 THEN 'test'
         ELSE 'train'
       END AS split
FROM ml.insurance;

-- 2. Check the deal: the three groups should look alike.
SELECT split,
       COUNT(*) AS people,
       ROUND(AVG(charges)) AS avg_charges,
       COUNTIF(smoker = TRUE) AS smokers
FROM ml.insurance_groups
GROUP BY split
ORDER BY people DESC;

-- 3. D11's model again: six features, trained on the training rows only.
--    NO_SPLIT: we chose the rows ourselves, so BigQuery must not hold any more aside.
CREATE OR REPLACE MODEL ml.ins_linear
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['charges'],
  data_split_method = 'NO_SPLIT'
) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups
WHERE split = 'train';

-- 4. A prepared model: boosted trees, with BigQuery's default settings.
--    Same six features, same training rows. Only the model type changes.
CREATE OR REPLACE MODEL ml.ins_boosted
OPTIONS (
  model_type = 'BOOSTED_TREE_REGRESSOR',
  input_label_cols = ['charges'],
  data_split_method = 'NO_SPLIT'
) AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups
WHERE split = 'train';

-- 5. Both models, scored on the same 268 validation people, in one table.
SELECT 'linear' AS model,
       ROUND(mean_absolute_error) AS mae,
       ROUND(SQRT(mean_squared_error)) AS rmse,
       ROUND(r2_score, 2) AS r2
FROM ML.EVALUATE(MODEL ml.ins_linear,
  (SELECT * FROM ml.insurance_groups WHERE split = 'validation'))
UNION ALL
SELECT 'boosted trees',
       ROUND(mean_absolute_error),
       ROUND(SQRT(mean_squared_error)),
       ROUND(r2_score, 2)
FROM ML.EVALUATE(MODEL ml.ins_boosted,
  (SELECT * FROM ml.insurance_groups WHERE split = 'validation'));

-- 6. The guess to beat: the training average, for every validation person.
SELECT ROUND(AVG(charges)) AS guess
FROM ml.insurance_groups
WHERE split = 'train';

SELECT ROUND(AVG(ABS(charges - 13267))) AS mae_of_the_guess
FROM ml.insurance_groups
WHERE split = 'validation';
