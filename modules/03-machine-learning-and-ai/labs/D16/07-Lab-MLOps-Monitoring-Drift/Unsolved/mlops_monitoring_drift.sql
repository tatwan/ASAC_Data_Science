-- D16 · Lab 07 · Watching a model after it ships: skew and drift · Starter
-- Self-guided: run one statement at a time, after reading its step in the README. Step 8 is a script: run it whole.
-- The README explains each step: read it first, run the SQL, then compare with "What you should see".

-- Step 1 · The groups and version 1, if you do not have them
CREATE VIEW IF NOT EXISTS ml.diamonds_groups AS
SELECT *,
       CASE MOD(diamond_id, 5)
         WHEN 0 THEN 'test'
         WHEN 1 THEN 'validation'
         ELSE 'train'
       END AS split
FROM ml.diamonds;

CREATE MODEL IF NOT EXISTS ml.diamond_price_v1
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['price'],
         data_split_method = 'NO_SPLIT') AS
SELECT * EXCEPT (diamond_id, split)
FROM ml.diamonds_groups
WHERE split = 'train';

-- Step 2 · Describe the table (C1, part 1)
SELECT *
FROM ML.DESCRIBE_DATA(TABLE ml.diamonds,
                      STRUCT(4 AS num_quantiles, 3 AS top_k));

-- Step 3 · Two batches to check
CREATE OR REPLACE VIEW ml.batch_normal AS
SELECT * EXCEPT (split)
FROM ml.diamonds_groups
WHERE split = 'validation';

CREATE OR REPLACE VIEW ml.batch_big_stones AS
SELECT * EXCEPT (split)
FROM ml.diamonds_groups
WHERE split = 'validation' AND carat >= 1.5;

SELECT 'normal' AS batch, COUNT(*) AS diamond_count, ROUND(AVG(carat), 2) AS average_carat,
       ROUND(AVG(price), 1) AS average_price
FROM ml.batch_normal
UNION ALL
SELECT 'big stones', COUNT(*), ROUND(AVG(carat), 2), ROUND(AVG(price), 1)
FROM ml.batch_big_stones;

-- Step 4 · Skew on an ordinary batch (C1, part 2)
SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_SKEW(MODEL ml.diamond_price_v1,
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_normal),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY input;

-- Step 5 · Skew on the big-stone batch (C2, part 1)
SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_SKEW(MODEL ml.diamond_price_v1,
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_big_stones),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY is_anomaly DESC, value DESC;

-- Step 6 · Does the skew cost accuracy? (C2, part 2)
SELECT 'normal' AS batch, ROUND(mean_absolute_error, 1) AS mae
FROM ML.EVALUATE(MODEL ml.diamond_price_v1,
       (SELECT * EXCEPT (diamond_id) FROM ml.batch_normal))
UNION ALL
SELECT 'big stones', ROUND(mean_absolute_error, 1)
FROM ML.EVALUATE(MODEL ml.diamond_price_v1,
       (SELECT * EXCEPT (diamond_id) FROM ml.batch_big_stones));

-- Step 7 · Drift: two batches, no model
SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_DRIFT(
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_normal),
       (SELECT carat, cut, color, clarity, depth_pct, table_pct,
               length_mm, width_mm, height_mm
        FROM ml.batch_big_stones),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY is_anomaly DESC, value DESC;

SELECT input, metric, threshold, ROUND(value, 3) AS value, is_anomaly
FROM ML.VALIDATE_DATA_DRIFT(
       (SELECT sex, age, sibsp, parch FROM ml.titanic WHERE pclass = 1),
       (SELECT sex, age, sibsp, parch FROM ml.titanic WHERE pclass = 3),
       STRUCT(0.3 AS categorical_default_threshold,
              0.3 AS numerical_default_threshold))
ORDER BY input;

-- Step 8 · Stop when the data has changed: the script, by hand (C3)
CREATE OR REPLACE VIEW ml.diamonds_new_batch AS
SELECT * FROM ml.batch_normal;

-- A script: select from DECLARE down to END IF; and run it all at once, not line by line.
DECLARE skewed_columns STRING;

SET skewed_columns = (
  SELECT STRING_AGG(input, ', ' ORDER BY input)
  FROM ML.VALIDATE_DATA_SKEW(MODEL ml.diamond_price_v1,
         (SELECT carat, cut, color, clarity, depth_pct, table_pct,
                 length_mm, width_mm, height_mm
          FROM ml.diamonds_new_batch),
         STRUCT(0.3 AS categorical_default_threshold,
                0.3 AS numerical_default_threshold))
  WHERE is_anomaly
);

IF skewed_columns IS NOT NULL THEN
  SELECT ERROR(CONCAT('Data skew in: ', skewed_columns,
                      '. The batch was not scored. Check the new diamonds before using the model on them.'));
ELSE
  CREATE OR REPLACE TABLE ml.diamonds_new_batch_scored AS
  SELECT diamond_id, carat, cut, color, clarity,
         ROUND(predicted_price) AS predicted_price
  FROM ML.PREDICT(MODEL ml.diamond_price_v1, TABLE ml.diamonds_new_batch);
END IF;

CREATE OR REPLACE VIEW ml.diamonds_new_batch AS
SELECT * FROM ml.batch_big_stones;
