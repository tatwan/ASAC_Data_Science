-- D14 · Lab 10 · Feature engineering with BigQuery ML's functions · Solved (every query from the README, in order)
-- Self-guided: run one statement at a time.

-- Step 1 · Age bands with fixed cut points
SELECT ML.BUCKETIZE(age, [30, 45, 60]) AS age_band,
       MIN(age) AS youngest, MAX(age) AS oldest, COUNT(*) AS people
FROM ml.insurance_groups
WHERE split = 'train'
GROUP BY age_band
ORDER BY age_band;

CREATE OR REPLACE MODEL ml.ins_linear_ageband
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT') AS
SELECT age, ML.BUCKETIZE(age, [30, 45, 60]) AS age_band, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups WHERE split = 'train';

SELECT ROUND(r2_score, 3) AS validation_r2, ROUND(mean_absolute_error) AS validation_mae
FROM ML.EVALUATE(MODEL ml.ins_linear_ageband,
  (SELECT *, ML.BUCKETIZE(age, [30, 45, 60]) AS age_band FROM ml.insurance_groups WHERE split = 'validation'));

-- Step 2 · A cross of two categories
SELECT ML.FEATURE_CROSS(STRUCT(IF(smoker, 'yes', 'no') AS smoker, IF(bmi >= 30, '30plus', 'under30') AS bmi_group)).smoker_bmi_group
         AS smoker_bmi,
       COUNT(*) AS people, ROUND(AVG(charges)) AS avg_charges
FROM ml.insurance_groups
WHERE split = 'train'
GROUP BY smoker_bmi
ORDER BY avg_charges;

CREATE OR REPLACE MODEL ml.ins_linear_cross
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'], data_split_method = 'NO_SPLIT') AS
SELECT age, sex, bmi, children, smoker, region,
       ML.FEATURE_CROSS(STRUCT(IF(smoker, 'yes', 'no') AS smoker, IF(bmi >= 30, '30plus', 'under30') AS bmi_group)).smoker_bmi_group
         AS smoker_bmi,
       charges
FROM ml.insurance_groups WHERE split = 'train';

SELECT ROUND(r2_score, 3) AS validation_r2, ROUND(mean_absolute_error) AS validation_mae
FROM ML.EVALUATE(MODEL ml.ins_linear_cross,
  (SELECT *,
          ML.FEATURE_CROSS(STRUCT(IF(smoker, 'yes', 'no') AS smoker, IF(bmi >= 30, '30plus', 'under30') AS bmi_group)).smoker_bmi_group
            AS smoker_bmi
   FROM ml.insurance_groups WHERE split = 'validation'));

-- Step 3 · Bands of equal size, and a trap
SELECT bmi_quarter, MIN(bmi) AS lowest, MAX(bmi) AS highest, COUNT(*) AS people
FROM (
  SELECT bmi, ML.QUANTILE_BUCKETIZE(bmi, 4, 'bucket_ranges') OVER () AS bmi_quarter
  FROM ml.insurance_groups
)
GROUP BY bmi_quarter
ORDER BY lowest;

-- Step 4 · Squares and products
SELECT age, bmi,
       ML.POLYNOMIAL_EXPAND(STRUCT(age, bmi), 2) AS expanded
FROM ml.insurance_groups
WHERE split = 'train'
LIMIT 3;
