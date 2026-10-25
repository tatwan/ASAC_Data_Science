-- D11 · Lab 07 · Ridge, Lasso and Elastic Net, and how training runs · Solved (every query from the README, in order)

-- Step 1 · The baseline: no penalty
CREATE OR REPLACE MODEL ml.cars_plain
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_plain, STRUCT(TRUE AS standardize))
ORDER BY processed_input;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_plain);

-- Step 2 · Why hold weights back at all?
SELECT ROUND(CORR(displacement, weight), 2) AS displacement_weight,
       ROUND(CORR(displacement, cylinders), 2) AS displacement_cylinders,
       ROUND(CORR(horsepower, weight), 2) AS horsepower_weight
FROM ml.cars_clean;

-- Step 3 · Ridge: `L2_REG`
CREATE OR REPLACE MODEL ml.cars_ridge
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         l2_reg = 10) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_ridge, STRUCT(TRUE AS standardize))
ORDER BY processed_input;

SELECT ROUND(SUM(weight * weight), 2) AS sum_of_squared_weights
FROM ML.WEIGHTS(MODEL ml.cars_ridge, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__';

-- Then: train cars_ridge again with l2_reg = 100, then 1000, and re-run both queries.

-- Step 4 · Lasso: `L1_REG`
CREATE OR REPLACE MODEL ml.cars_lasso
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT',
         l1_reg = 10, early_stop = FALSE) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 3) AS weight,
       IF(weight = 0, 'DROPPED', 'KEPT') AS status
FROM ML.WEIGHTS(MODEL ml.cars_lasso, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;

-- Then: train cars_lasso again with l1_reg = 100, then 500, and re-run the weights query each time.
-- At 500 (in our class run, cylinders was DROPPED here); step 6 compares this version:
CREATE OR REPLACE MODEL ml.cars_lasso
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT',
         l1_reg = 500, early_stop = FALSE) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 3) AS weight,
       IF(weight = 0, 'DROPPED', 'KEPT') AS status
FROM ML.WEIGHTS(MODEL ml.cars_lasso, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;

-- Optional: at l1_reg = 500, add max_iterations = 50 (the default is 20) and compare the weights.

-- Step 5 · Elastic Net: both penalties
CREATE OR REPLACE MODEL ml.cars_enet
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT',
         l1_reg = 500, l2_reg = 100, early_stop = FALSE) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 3) AS weight,
       IF(weight = 0, 'DROPPED', 'KEPT') AS status
FROM ML.WEIGHTS(MODEL ml.cars_enet, STRUCT(TRUE AS standardize))
WHERE processed_input != '__INTERCEPT__'
ORDER BY ABS(weight) DESC;

-- Step 6 · Which one predicts best?
SELECT 'No penalty' AS model, ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_plain)
UNION ALL
SELECT 'Ridge', ROUND(mean_absolute_error, 2), ROUND(r2_score, 3)
FROM ML.EVALUATE(MODEL ml.cars_ridge)
UNION ALL
SELECT 'Lasso', ROUND(mean_absolute_error, 2), ROUND(r2_score, 3)
FROM ML.EVALUATE(MODEL ml.cars_lasso)
UNION ALL
SELECT 'Elastic Net', ROUND(mean_absolute_error, 2), ROUND(r2_score, 3)
FROM ML.EVALUATE(MODEL ml.cars_enet);

-- Overdo it, then re-run the comparison above:
CREATE OR REPLACE MODEL ml.cars_ridge
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         l2_reg = 100000) AS
SELECT * FROM ml.cars_clean;

-- Step 7 · `OPTIMIZE_STRATEGY`: one calculation, or many small steps
CREATE OR REPLACE MODEL ml.cars_normal
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'NORMAL_EQUATION') AS
SELECT * FROM ml.cars_clean;

CREATE OR REPLACE MODEL ml.cars_steps
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT') AS
SELECT * FROM ml.cars_clean;

SELECT iteration, ROUND(loss, 2) AS loss, ROUND(eval_loss, 2) AS eval_loss,
       ROUND(learning_rate, 3) AS learning_rate
FROM ML.TRAINING_INFO(MODEL ml.cars_steps)
ORDER BY iteration;

-- One calculation with an L1 penalty: expect an error, not a model.
CREATE OR REPLACE MODEL ml.cars_lasso_one_calc
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'NORMAL_EQUATION', l1_reg = 500) AS
SELECT * FROM ml.cars_clean;

-- Step 8 · `MAX_ITERATIONS`: stop early on purpose
CREATE OR REPLACE MODEL ml.cars_two_steps
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT', max_iterations = 2) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_two_steps);
