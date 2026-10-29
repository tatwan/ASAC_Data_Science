-- D16 · What is this diamond worth? Regression, start to finish · Solved (every query from the README, in order)
-- Run one statement at a time, in order. CREATE MODEL and the ML. functions run in BigQuery only.

-- Before you start: make sure ml exists, then upload diamonds.csv into it
-- (shared/datasets/ml_recap on GitHub; Create table, Upload, CSV, table diamonds, Auto detect).
CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');
SELECT COUNT(*) AS diamonds FROM ml.diamonds;  -- 53,940

-- Step 1 · Look: one row is one diamond
SELECT COUNT(*) AS diamonds_on_file,
       MIN(price) AS cheapest, MAX(price) AS dearest,
       ROUND(AVG(price)) AS average_price
FROM ml.diamonds;

-- Step 2 · Create the model
CREATE OR REPLACE MODEL ml.diamond_price
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['price']) AS
SELECT * EXCEPT (diamond_id)
FROM ml.diamonds;

-- Step 3 · Evaluate
SELECT ROUND(mean_absolute_error) AS mae,
       ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.diamond_price);

-- Step 4 · Predict, and read the first rows
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(predicted_price) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price, TABLE ml.diamonds)
ORDER BY diamond_id
LIMIT 5;

-- Step 5 · Save the predictions as a view
CREATE OR REPLACE VIEW ml.v_diamond_prices AS
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(predicted_price) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price, TABLE ml.diamonds);

SELECT COUNT(*) AS diamonds_scored,
       COUNTIF(predicted_price < 0) AS below_zero
FROM ml.v_diamond_prices;
