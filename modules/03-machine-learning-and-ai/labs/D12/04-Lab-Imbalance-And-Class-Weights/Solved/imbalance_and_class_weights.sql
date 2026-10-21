-- D12 · Lab 04 · When accuracy misleads: a rare Yes and class weights · Solved
-- Attrition is BOOLEAN: TRUE = left, FALSE = stayed.

-- Step 1 · How rare is a leaver?
SELECT Attrition, COUNT(*) AS employee_count
FROM ml.employees
GROUP BY Attrition;

-- Step 2 · A model without help
CREATE OR REPLACE MODEL ml.attrition_plain
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Attrition'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT Age, Gender, DistanceFromHome, JobLevel, Department, MonthlyIncome,
       PerformanceRating, JobSatisfaction, Attrition
FROM ml.employees;

SELECT ROUND(accuracy, 3) AS accuracy, ROUND(recall, 3) AS recall,
       ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.attrition_plain);

-- Step 3 · The same model, with each leaver counting more in training
CREATE OR REPLACE MODEL ml.attrition_weighted
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Attrition'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         auto_class_weights = TRUE) AS
SELECT Age, Gender, DistanceFromHome, JobLevel, Department, MonthlyIncome,
       PerformanceRating, JobSatisfaction, Attrition
FROM ml.employees;

SELECT 'plain' AS model, ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision, ROUND(recall, 3) AS recall,
       ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.attrition_plain)
UNION ALL
SELECT 'auto weights', ROUND(accuracy, 3), ROUND(precision, 3),
       ROUND(recall, 3), ROUND(roc_auc, 3)
FROM ML.EVALUATE(MODEL ml.attrition_weighted);

-- Step 4 · The plain model at low thresholds: leavers found, stayers flagged
SELECT ROUND(threshold, 2) AS threshold, ROUND(recall, 2) AS recall,
       ROUND(false_positive_rate, 2) AS false_positive_rate
FROM ML.ROC_CURVE(MODEL ml.attrition_plain)
WHERE threshold BETWEEN 0.15 AND 0.25
ORDER BY threshold;
