-- D11 · Lab 06 · What goes into the line · Solved (every query from the README, in order)

-- Step 1 · `FIT_INTERCEPT`: does the line need a starting point?
CREATE OR REPLACE MODEL ml.salary_no_intercept
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['salary'],
         fit_intercept = FALSE) AS
SELECT years_experience, salary
FROM ml.salary_data;

SELECT processed_input, ROUND(weight, 1) AS weight
FROM ML.WEIGHTS(MODEL ml.salary_no_intercept);

SELECT ROUND(mean_absolute_error) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.salary_no_intercept);

-- Step 2 · `CATEGORY_ENCODING_METHOD`: how text becomes numbers
CREATE OR REPLACE MODEL ml.insurance_onehot
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'],
         category_encoding_method = 'ONE_HOT_ENCODING') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance;

CREATE OR REPLACE MODEL ml.insurance_dummy
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'],
         category_encoding_method = 'DUMMY_ENCODING') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance;

SELECT cw.category, ROUND(cw.weight, 1) AS weight
FROM ML.WEIGHTS(MODEL ml.insurance_onehot), UNNEST(category_weights) AS cw
WHERE processed_input = 'region'
ORDER BY cw.category;

-- Step 3 · Raw weights against standardized weights
SELECT processed_input, ROUND(weight, 4) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_random)
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;

SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_random, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;

-- Bonus · Which weights would survive new data?
CREATE OR REPLACE MODEL ml.insurance_pvalues
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['charges'],
         category_encoding_method = 'DUMMY_ENCODING',
         calculate_p_values = TRUE,
         data_split_method = 'NO_SPLIT') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance;

SELECT processed_input, category, ROUND(weight, 1) AS weight, ROUND(p_value, 4) AS p_value
FROM ML.ADVANCED_WEIGHTS(MODEL ml.insurance_pvalues);
