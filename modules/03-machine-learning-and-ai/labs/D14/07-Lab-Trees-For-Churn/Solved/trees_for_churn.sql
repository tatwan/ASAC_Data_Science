-- D14 · Lab 07 · Trees for a category: Telco churn, fairly compared · Solved (every query from the README, in order)
-- Self-guided: run one statement at a time.

-- Step 1 · The same customers for every model
CREATE OR REPLACE VIEW ml.telco_groups AS
SELECT *,
       CASE MOD(ROW_NUMBER() OVER (ORDER BY customerID), 5)
         WHEN 3 THEN 'validation'
         WHEN 4 THEN 'test'
         ELSE 'train'
       END AS split
FROM ml.telco;

SELECT split, COUNT(*) AS customers, ROUND(COUNTIF(Churn = TRUE) / COUNT(*), 3) AS churn_rate
FROM ml.telco_groups
GROUP BY split
ORDER BY customers DESC;

-- Step 2 · Three classifiers, one set of features
CREATE OR REPLACE MODEL ml.telco_logistic
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.telco_boosted
OPTIONS (model_type = 'BOOSTED_TREE_CLASSIFIER', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.telco_forest
OPTIONS (model_type = 'RANDOM_FOREST_CLASSIFIER', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

-- Step 3 · Score all three on the same validation customers
SELECT 'logistic' AS model, ROUND(roc_auc, 3) AS roc_auc, ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision, ROUND(recall, 3) AS recall, ROUND(log_loss, 3) AS log_loss
FROM ML.EVALUATE(MODEL ml.telco_logistic, (SELECT * FROM ml.telco_groups WHERE split = 'validation'))
UNION ALL
SELECT 'boosted trees', ROUND(roc_auc, 3), ROUND(accuracy, 3), ROUND(precision, 3), ROUND(recall, 3), ROUND(log_loss, 3)
FROM ML.EVALUATE(MODEL ml.telco_boosted, (SELECT * FROM ml.telco_groups WHERE split = 'validation'))
UNION ALL
SELECT 'random forest', ROUND(roc_auc, 3), ROUND(accuracy, 3), ROUND(precision, 3), ROUND(recall, 3), ROUND(log_loss, 3)
FROM ML.EVALUATE(MODEL ml.telco_forest, (SELECT * FROM ml.telco_groups WHERE split = 'validation'));

SELECT ROUND(COUNTIF(Churn = FALSE) / COUNT(*), 3) AS majority_guess_accuracy
FROM ml.telco_groups
WHERE split = 'validation';

-- Step 4 · What the boosted trees leaned on
SELECT feature, importance_weight,
       ROUND(importance_weight * importance_gain
             / SUM(importance_weight * importance_gain) OVER (), 3) AS share_of_gain
FROM ML.FEATURE_IMPORTANCE(MODEL ml.telco_boosted)
ORDER BY share_of_gain DESC;

-- Step 5 · One engineered feature
CREATE OR REPLACE MODEL ml.telco_logistic_log
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, LN(1 + tenure) AS log_tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups
WHERE split = 'train';

SELECT ROUND(roc_auc, 3) AS roc_auc, ROUND(accuracy, 3) AS accuracy
FROM ML.EVALUATE(MODEL ml.telco_logistic_log,
  (SELECT *, LN(1 + tenure) AS log_tenure FROM ml.telco_groups WHERE split = 'validation'));

-- Step 6 · A second deal
CREATE OR REPLACE VIEW ml.telco_groups_deal2 AS
SELECT *,
       CASE MOD(ROW_NUMBER() OVER (ORDER BY customerID), 5)
         WHEN 0 THEN 'validation'
         WHEN 4 THEN 'test'
         ELSE 'train'
       END AS split
FROM ml.telco;

CREATE OR REPLACE MODEL ml.telco_logistic_d2
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups_deal2
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.telco_logistic_log_d2
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Churn'], data_split_method = 'NO_SPLIT') AS
SELECT tenure, LN(1 + tenure) AS log_tenure, MonthlyCharges, Contract, InternetService, PaymentMethod,
       SeniorCitizen, PaperlessBilling, TechSupport, Churn
FROM ml.telco_groups_deal2
WHERE split = 'train';

SELECT 'without log_tenure' AS model, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.telco_logistic_d2,
  (SELECT * FROM ml.telco_groups_deal2 WHERE split = 'validation'))
UNION ALL
SELECT 'with log_tenure', ROUND(roc_auc, 3)
FROM ML.EVALUATE(MODEL ml.telco_logistic_log_d2,
  (SELECT *, LN(1 + tenure) AS log_tenure FROM ml.telco_groups_deal2 WHERE split = 'validation'));

-- Step 7 · The test, once
SELECT ROUND(roc_auc, 3) AS roc_auc, ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision, ROUND(recall, 3) AS recall
FROM ML.EVALUATE(MODEL ml.telco_logistic_log,
  (SELECT *, LN(1 + tenure) AS log_tenure FROM ml.telco_groups WHERE split = 'test'));

SELECT ROUND(COUNTIF(Churn = FALSE) / COUNT(*), 3) AS majority_guess_accuracy
FROM ml.telco_groups
WHERE split = 'test';
