-- D16 · Who was likely to survive the Titanic? Classification, start to finish · Starter
-- Run one statement at a time, in order. CREATE MODEL and the ML. functions run in BigQuery only.
-- The README explains each step: read it first, run the SQL, then compare with "What you should see".

-- Step 1 · Look: one row is one passenger
SELECT sex,
       COUNT(*) AS passengers,
       COUNTIF(survived) AS survivors,
       ROUND(AVG(IF(survived, 1, 0)), 3) AS share_survived
FROM ml.titanic
GROUP BY sex;

-- Step 2 · Create the model
CREATE OR REPLACE MODEL ml.titanic_survival
OPTIONS (model_type = 'LOGISTIC_REG',
         input_label_cols = ['survived']) AS
SELECT * EXCEPT (passenger_id)
FROM ml.titanic;

-- Step 3 · Evaluate
SELECT ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision,
       ROUND(recall, 3) AS recall,
       ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.titanic_survival);

-- Step 4 · Predict: two passengers you describe
SELECT pclass, sex, age, predicted_survived,
       ROUND(p.prob, 2) AS chance_of_surviving
FROM ML.PREDICT(MODEL ml.titanic_survival,
       (SELECT 1 AS pclass, 'female' AS sex, 17.0 AS age, 0 AS sibsp, 1 AS parch
        UNION ALL
        SELECT 3, 'male', 20.0, 0, 0)),
     UNNEST(predicted_survived_probs) AS p
WHERE p.label = TRUE;

-- Step 5 · Save the predictions as a view
CREATE OR REPLACE VIEW ml.v_titanic_scored AS
SELECT passenger_id, pclass, sex, age, survived, predicted_survived,
       ROUND(p.prob, 3) AS survival_chance
FROM ML.PREDICT(MODEL ml.titanic_survival, TABLE ml.titanic),
     UNNEST(predicted_survived_probs) AS p
WHERE p.label = TRUE;

SELECT pclass, sex, COUNT(*) AS passengers,
       ROUND(AVG(survival_chance), 2) AS average_chance
FROM ml.v_titanic_scored
GROUP BY pclass, sex
ORDER BY pclass, sex;

-- ===================== Part 2 · TRANSFORM, and reading the evaluation charts =====================
-- Needs only ml.titanic (1,309 rows).

-- Step 6 · Fix the passengers you score on
SELECT COUNTIF(MOD(passenger_id, 5) <> 0) AS to_learn_from,
       COUNTIF(MOD(passenger_id, 5) = 0)  AS to_score_on,
       COUNTIF(MOD(passenger_id, 5) = 0 AND survived) AS survivors_to_score
FROM ml.titanic;

-- Step 7 · Model A: sex only
CREATE OR REPLACE MODEL ml.titanic_sex_only
OPTIONS (model_type = 'LOGISTIC_REG',
         input_label_cols = ['survived'],
         data_split_method = 'NO_SPLIT') AS
SELECT sex, survived
FROM ml.titanic
WHERE MOD(passenger_id, 5) <> 0;

-- Step 8 · Model B: the preparation inside the model, with TRANSFORM
CREATE OR REPLACE MODEL ml.titanic_transform
TRANSFORM (pclass,
           sex,
           ML.IMPUTER(age, 'median') OVER () AS age,
           IF(age < 13, TRUE, FALSE) AS is_child,
           sibsp + parch + 1 AS family_size,
           survived)
OPTIONS (model_type = 'LOGISTIC_REG',
         input_label_cols = ['survived'],
         data_split_method = 'NO_SPLIT') AS
SELECT pclass, sex, age, sibsp, parch, survived
FROM ml.titanic
WHERE MOD(passenger_id, 5) <> 0;

-- Step 9 · Predict from raw columns
SELECT pclass, sex, age, sibsp, parch, predicted_survived,
       ROUND(p.prob, 2) AS chance_of_surviving
FROM ML.PREDICT(MODEL ml.titanic_transform,
       (SELECT 3 AS pclass, 'male' AS sex, CAST(NULL AS FLOAT64) AS age, 1 AS sibsp, 3 AS parch)),
     UNNEST(predicted_survived_probs) AS p
WHERE p.label = TRUE;

-- Step 10 · Score both models on the same 261 passengers
SELECT 'sex only' AS model, ROUND(accuracy, 2) AS accuracy, ROUND(precision, 2) AS precision,
       ROUND(recall, 2) AS recall, ROUND(roc_auc, 2) AS roc_auc
FROM ML.EVALUATE(MODEL ml.titanic_sex_only,
       (SELECT * FROM ml.titanic WHERE MOD(passenger_id, 5) = 0))
UNION ALL
SELECT 'TRANSFORM', ROUND(accuracy, 2), ROUND(precision, 2), ROUND(recall, 2), ROUND(roc_auc, 2)
FROM ML.EVALUATE(MODEL ml.titanic_transform,
       (SELECT * FROM ml.titanic WHERE MOD(passenger_id, 5) = 0));

-- Step 11 · The three charts, row by row (then the model's Evaluation tab)
SELECT ROUND(threshold, 2) AS threshold,
       ROUND(SAFE_DIVIDE(true_positives, true_positives + false_positives), 2) AS precision,
       ROUND(recall, 2) AS recall,
       ROUND(false_positive_rate, 2) AS false_positive_rate
FROM ML.ROC_CURVE(MODEL ml.titanic_transform,
       (SELECT * FROM ml.titanic WHERE MOD(passenger_id, 5) = 0))
ORDER BY threshold;

-- Step 12 · The same for the sex-only model: only a few rows
SELECT ROUND(threshold, 2) AS threshold,
       ROUND(SAFE_DIVIDE(true_positives, true_positives + false_positives), 2) AS precision,
       ROUND(recall, 2) AS recall,
       ROUND(false_positive_rate, 2) AS false_positive_rate
FROM ML.ROC_CURVE(MODEL ml.titanic_sex_only,
       (SELECT * FROM ml.titanic WHERE MOD(passenger_id, 5) = 0))
ORDER BY threshold;
