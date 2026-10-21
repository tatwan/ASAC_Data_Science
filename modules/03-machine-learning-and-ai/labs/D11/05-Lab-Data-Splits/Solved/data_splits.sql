-- D11 · Lab 05 · Which rows are held aside? · Solved (every query from the README, in order)

-- Step 1 · Upload, and check every column's type
SELECT horsepower, COUNT(*) AS car_count
FROM ml.cars
WHERE SAFE_CAST(horsepower AS FLOAT64) IS NULL
GROUP BY horsepower;

CREATE OR REPLACE VIEW ml.cars_clean AS
SELECT mpg, cylinders, displacement,
       SAFE_CAST(horsepower AS FLOAT64) AS horsepower,
       weight, acceleration
FROM ml.cars;

-- Step 2 · The default: `AUTO_SPLIT`
CREATE OR REPLACE MODEL ml.cars_auto
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg']) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_auto);

-- Step 3 · `RANDOM`, with `DATA_SPLIT_EVAL_FRACTION`
CREATE OR REPLACE MODEL ml.cars_random
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_random);

-- Step 4 · `CUSTOM`: you choose the evaluation rows
CREATE OR REPLACE MODEL ml.cars_heavy_aside
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'CUSTOM', data_split_col = 'is_eval') AS
SELECT *, weight > 3900 AS is_eval
FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_heavy_aside);

CREATE OR REPLACE TABLE ml.cars_split AS
SELECT *, RAND() < 0.2 AS is_eval
FROM ml.cars_clean;

CREATE OR REPLACE MODEL ml.cars_custom
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'CUSTOM', data_split_col = 'is_eval') AS
SELECT * FROM ml.cars_split;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_custom);
