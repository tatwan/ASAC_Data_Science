-- D11 · Lab 07 · Holding the weights back, and how training runs · Solved (every query from the README, in order)

-- Step 1 · `OPTIMIZE_STRATEGY`: one calculation, or many small steps
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

-- Step 2 · `MAX_ITERATIONS`: stop too early on purpose
CREATE OR REPLACE MODEL ml.cars_two_steps
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         optimize_strategy = 'BATCH_GRADIENT_DESCENT', max_iterations = 2) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_two_steps);

-- Step 3 · Why hold weights back at all?
SELECT ROUND(CORR(displacement, weight), 2) AS displacement_weight,
       ROUND(CORR(displacement, cylinders), 2) AS displacement_cylinders,
       ROUND(CORR(horsepower, weight), 2) AS horsepower_weight
FROM ml.cars_clean;

-- Step 4 · `L2_REG`: shrink every weight a little
CREATE OR REPLACE MODEL ml.cars_l2
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         l2_reg = 50) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 2) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_l2, STRUCT(TRUE AS standardize))
ORDER BY processed_input;

-- Step 5 · `L1_REG`: push weak weights to exactly zero
CREATE OR REPLACE MODEL ml.cars_l1
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         l1_reg = 50) AS
SELECT * FROM ml.cars_clean;

SELECT processed_input, ROUND(weight, 3) AS weight
FROM ML.WEIGHTS(MODEL ml.cars_l1, STRUCT(TRUE AS standardize))
ORDER BY ABS(weight) DESC;
