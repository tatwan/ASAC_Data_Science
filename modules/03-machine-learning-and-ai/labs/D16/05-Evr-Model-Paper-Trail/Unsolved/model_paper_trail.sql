-- D16 · A model's paper trail, and a view as the contract
-- Needs ml.diamond_price and ml.v_diamond_prices from activity 01. Step 1 is clicks: ml → Models → diamond_price.

-- Step 2 · ML.TRAINING_INFO
SELECT training_run, iteration, ROUND(loss) AS loss, duration_ms
FROM ML.TRAINING_INFO(MODEL ml.diamond_price)
ORDER BY iteration;

-- Step 3 · A table of the same rows
CREATE OR REPLACE TABLE ml.diamond_prices_snapshot AS
SELECT * FROM ml.v_diamond_prices;

SELECT
  (SELECT ROUND(AVG(predicted_price)) FROM ml.v_diamond_prices)        AS view_average,
  (SELECT ROUND(AVG(predicted_price)) FROM ml.diamond_prices_snapshot) AS table_average;
