-- D16 · Lab 06 · Two versions of a model, and one promoted · Solved (every query from the README, in order)
-- Self-guided: run one statement at a time.

-- Step 1 · Fix the groups
CREATE OR REPLACE VIEW ml.diamonds_groups AS
SELECT *,
       CASE MOD(diamond_id, 5)
         WHEN 0 THEN 'test'
         WHEN 1 THEN 'validation'
         ELSE 'train'
       END AS split
FROM ml.diamonds;

SELECT split, COUNT(*) AS diamond_count, ROUND(AVG(price), 1) AS average_price
FROM ml.diamonds_groups
GROUP BY split
ORDER BY diamond_count DESC;

-- Step 2 · Version 1: the class model, on the training rows
CREATE OR REPLACE MODEL ml.diamond_price_v1
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['price'],
         data_split_method = 'NO_SPLIT') AS
SELECT * EXCEPT (diamond_id, split)
FROM ml.diamonds_groups
WHERE split = 'train';

-- Step 3 · Version 2: predict the logarithm of the price
SELECT ROUND(MIN(LN(price)), 3) AS lowest_log_price,
       ROUND(MAX(LN(price)), 3) AS highest_log_price
FROM ml.diamonds_groups
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.diamond_price_v2
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['log_price'],
         data_split_method = 'NO_SPLIT') AS
SELECT * EXCEPT (diamond_id, split, price),
       LN(price) AS log_price
FROM ml.diamonds_groups
WHERE split = 'train';

-- Step 4 · Score both in dollars, on the same validation rows (C1)
SELECT 'ml.diamond_price_v1' AS model_name,
       ROUND(AVG(ABS(price - predicted_price)), 1) AS validation_mae,
       COUNTIF(predicted_price < 0) AS below_zero
FROM ML.PREDICT(MODEL ml.diamond_price_v1,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'))
UNION ALL
SELECT 'ml.diamond_price_v2',
       ROUND(AVG(ABS(price - EXP(predicted_log_price))), 1),
       COUNTIF(EXP(predicted_log_price) < 0)
FROM ML.PREDICT(MODEL ml.diamond_price_v2,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'));

-- Step 5 · The same diamonds, side by side
SELECT v1.diamond_id, v1.carat, v1.cut, v1.color, v1.clarity, v1.price,
       ROUND(v1.predicted_price) AS version_1,
       ROUND(EXP(v2.predicted_log_price)) AS version_2
FROM ML.PREDICT(MODEL ml.diamond_price_v1,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation')) AS v1
JOIN ML.PREDICT(MODEL ml.diamond_price_v2,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation')) AS v2
  ON v1.diamond_id = v2.diamond_id
ORDER BY v1.diamond_id
LIMIT 5;

-- Step 6 · The model log (C2, part 1)
CREATE OR REPLACE TABLE ml.model_log AS
SELECT 'ml.diamond_price_v1' AS model_name,
       1 AS version,
       CURRENT_DATE() AS trained_on,
       (SELECT ROUND(AVG(ABS(price - predicted_price)), 1)
        FROM ML.PREDICT(MODEL ml.diamond_price_v1,
               (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'))) AS validation_mae,
       'archived' AS stage,
       'LINEAR_REG on price; every column except diamond_id; trained on split = train' AS note
UNION ALL
SELECT 'ml.diamond_price_v2',
       2,
       CURRENT_DATE(),
       (SELECT ROUND(AVG(ABS(price - EXP(predicted_log_price))), 1)
        FROM ML.PREDICT(MODEL ml.diamond_price_v2,
               (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'))),
       'production',
       'LINEAR_REG on LN(price), predictions EXP(predicted_log_price); same columns and rows as v1';

SELECT * FROM ml.model_log ORDER BY version;

-- Step 7 · Label the models
ALTER MODEL ml.diamond_price_v2
SET OPTIONS (description = 'Diamond price, version 2: LINEAR_REG on LN(price). Validation MAE about 492 dollars. Served by ml.v_diamond_prices.',
             labels = [('stage', 'production'), ('version', '2')]);

ALTER MODEL ml.diamond_price_v1
SET OPTIONS (description = 'Diamond price, version 1: LINEAR_REG on price. Replaced by version 2.',
             labels = [('stage', 'archived'), ('version', '1')]);

-- Step 8 · Promote version 2 behind the view (C2, part 2)
SELECT ordinal_position, column_name, data_type
FROM ml.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'v_diamond_prices'
ORDER BY ordinal_position;

CREATE OR REPLACE VIEW ml.v_diamond_prices AS
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(EXP(predicted_log_price)) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price_v2, TABLE ml.diamonds);

SELECT COUNT(*) AS diamonds_scored,
       COUNTIF(predicted_price < 0) AS below_zero
FROM ml.v_diamond_prices;

-- Step 9 · The test diamonds, once (C3)
SELECT ROUND(AVG(ABS(price - EXP(predicted_log_price))), 1) AS test_mae,
       COUNTIF(EXP(predicted_log_price) < 0) AS below_zero,
       COUNT(*) AS test_diamonds
FROM ML.PREDICT(MODEL ml.diamond_price_v2,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'test'));
