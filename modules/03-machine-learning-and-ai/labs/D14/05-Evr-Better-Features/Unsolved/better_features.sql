-- D14 · 05 · Better features for the line · Starter
-- Run one numbered block at a time. CREATE MODEL and the ML. functions run in BigQuery only.
-- You need ml.insurance_groups and ml.ins_linear (activity 01).

-- 1. The pattern the trees found: smokers and BMI, on the training rows only.
SELECT smoker,
       bmi >= 30 AS bmi_30_or_more,
       COUNT(*) AS people,
       ROUND(AVG(charges)) AS avg_charges
FROM ml.insurance_groups
WHERE split = 'train'
GROUP BY smoker, bmi_30_or_more
ORDER BY smoker, bmi_30_or_more;

-- 2. Two new columns, built from columns we already have.
--    smoker_obese: 1 for a smoker with a BMI of 30 or more, otherwise 0.
--    age_sq: age times age, so the line can bend upwards with age.
CREATE OR REPLACE VIEW ml.insurance_features AS
SELECT *,
       IF(smoker = TRUE AND bmi >= 30, 1, 0) AS smoker_obese,
       age * age AS age_sq
FROM ml.insurance_groups;

-- 3. The same line, with the two new features. Same training rows.
CREATE OR REPLACE MODEL ml.ins_linear_plus
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['charges'],
  data_split_method = 'NO_SPLIT'
) AS
SELECT age, sex, bmi, children, smoker, region, smoker_obese, age_sq, charges
FROM ml.insurance_features
WHERE split = 'train';

-- 4. Old line against new line, on the same 268 validation people.
SELECT 'linear, six features' AS model, ROUND(mean_absolute_error) AS mae, ROUND(r2_score, 2) AS r2
FROM ML.EVALUATE(MODEL ml.ins_linear, (SELECT * FROM ml.insurance_groups WHERE split = 'validation'))
UNION ALL
SELECT 'linear + smoker_obese + age_sq', ROUND(mean_absolute_error), ROUND(r2_score, 2)
FROM ML.EVALUATE(MODEL ml.ins_linear_plus, (SELECT * FROM ml.insurance_features WHERE split = 'validation'));

-- 5. What the new line learned. Text features keep one weight per value in category_weights.
SELECT processed_input, ROUND(weight, 1) AS weight, category_weights
FROM ML.WEIGHTS(MODEL ml.ins_linear_plus);

-- 6. A dead end, on purpose: a colleague offers "monthly charges", the bill divided by 12.
--    Does this column use the label? Train it and look at the score, then do not keep this model.
CREATE OR REPLACE MODEL ml.ins_too_good
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['charges'],
  data_split_method = 'NO_SPLIT'
) AS
SELECT age, sex, bmi, children, smoker, region, charges / 12 AS monthly_charges, charges
FROM ml.insurance_groups
WHERE split = 'train';

SELECT ROUND(mean_absolute_error) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.ins_too_good,
  (SELECT *, charges / 12 AS monthly_charges FROM ml.insurance_groups WHERE split = 'validation'));
