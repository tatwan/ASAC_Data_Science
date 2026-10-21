# Lab 04 · When the Yes is rare: class weights

In this self-guided lab, you will train a classifier on employees where only 16% left, watch it learn to say "stays" for almost everyone, and fix that with one option, `AUTO_CLASS_WEIGHTS`.

**When:** after class, at your own pace. Not submitted. · **Data:** [`employee_data.csv`](../../../../../shared/datasets/ml_classics/employee_data.csv) → `ml.employees` · **SQL:** `Solved/imbalance_and_class_weights.sql`

## The one idea

When one answer is rare, a model can score high accuracy by never predicting it. Accuracy then hides the very people we wanted to find. Class weights tell the model, while it trains, that each rare case matters more.

## How to work through this lab

Run each query, compare with **What you should see**, and answer **Think** in one line.

## The data

1,470 employees of a fictional company created by IBM's data scientists. One row is one employee. The label is `Attrition`: did the employee leave? The file says Yes or No; **Auto detect** reads it as BOOLEAN, so TRUE means left. Features: age, gender, distance from home, job level, department, monthly income, performance rating, job satisfaction. `EmployeeID` is an identifier and stays out of the model.

Upload `employee_data.csv` as `employees` in the `ml` dataset (**⋮** → **Create table**, Upload, CSV, **Auto detect**).

## Step 1 · How rare is a leaver?

```sql
SELECT Attrition, COUNT(*) AS employee_count
FROM ml.employees
GROUP BY Attrition;
```

**What you should see:** 237 TRUE and 1,233 FALSE. Only 237 ÷ 1,470 = 16% left. Saying "stays" for everyone is right 84% of the time and finds nobody who leaves.

## Step 2 · A model without help

```sql
CREATE OR REPLACE MODEL ml.attrition_plain
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Attrition'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT Age, Gender, DistanceFromHome, JobLevel, Department, MonthlyIncome,
       PerformanceRating, JobSatisfaction, Attrition
FROM ml.employees;

SELECT ROUND(accuracy, 3) AS accuracy, ROUND(recall, 3) AS recall,
       ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.attrition_plain);
```

**What you should see:** accuracy about 0.84 and recall close to **0**. The model flags almost nobody, so its accuracy is just the "stays for everyone" guess from step 1.

Why? Training tries to be wrong as rarely as possible across all rows. With 84% staying, the easiest way to be right most of the time is to give everyone a probability below 0.5.

**Think:** is the model useless, or is 0.5 the wrong threshold for it? Keep your answer for step 4.

## Step 3 · `AUTO_CLASS_WEIGHTS`: make the rare class count

The same model, with one new option:

```sql
CREATE OR REPLACE MODEL ml.attrition_weighted
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['Attrition'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2,
         auto_class_weights = TRUE) AS
SELECT Age, Gender, DistanceFromHome, JobLevel, Department, MonthlyIncome,
       PerformanceRating, JobSatisfaction, Attrition
FROM ml.employees;
```

`auto_class_weights = TRUE` makes the 237 leavers count as much in training as the 1,233 who stayed: each leaver counts about five times (1,233 ÷ 237).

Now put the two models side by side:

```sql
SELECT 'plain' AS model, ROUND(accuracy, 3) AS accuracy,
       ROUND(recall, 3) AS recall, ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.attrition_plain)
UNION ALL
SELECT 'auto weights', ROUND(accuracy, 3), ROUND(recall, 3), ROUND(roc_auc, 3)
FROM ML.EVALUATE(MODEL ml.attrition_weighted);
```

Both models use the same table and the same columns, so BigQuery holds aside the same 20% of employees for both: a fair comparison.

**What you should see:**

| Model | Accuracy | Recall | ROC AUC |
|---|---:|---:|---:|
| plain | ≈ 0.84 | ≈ 0 | ≈ 0.69 |
| auto weights | ≈ 0.62 | ≈ 0.67 | ≈ 0.69 |

Accuracy went **down**, and the model became more useful: it now finds about two in three leavers, at the price of many false alarms. ROC AUC did not move. The weights changed where the model draws the line between "leaves" and "stays", not how well it ranks employees.

## Step 4 · A lower threshold does something similar

Back to the plain model. `ML.ROC_CURVE` shows its recall at low thresholds:

```sql
SELECT ROUND(threshold, 2) AS threshold, ROUND(recall, 2) AS recall
FROM ML.ROC_CURVE(MODEL ml.attrition_plain)
WHERE threshold BETWEEN 0.15 AND 0.25
ORDER BY threshold;
```

**What you should see:** around threshold 0.2, recall is roughly half or more. The plain model was not blind; its probabilities were all low. Class weights and a lower threshold are two routes to the same trade: more leavers found, more false alarms.

## Step 5 · Would you use it?

ROC AUC about 0.69 says the model ranks leavers above stayers more often than chance, but not by much. These eight columns do not hold the strongest reasons people leave (overtime, stock options and years since a promotion are in IBM's full dataset, not in ours).

**Think:** HR wants to use the weighted model to choose who gets a retention interview. Write three sentences: what it would do well, what it would get wrong, and what data you would ask for first.

## What you saw

| Model | Accuracy | Recall | ROC AUC |
|---|---:|---:|---:|
| plain, threshold 0.5 | | | |
| `AUTO_CLASS_WEIGHTS` | | | |
| plain, threshold about 0.2 | — | | — |

## References

IBM HR Analytics Employee Attrition & Performance (fictional data created by IBM data scientists; Kaggle), course copy of ten columns in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). BigQuery ML: [CREATE MODEL for logistic regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm) (`AUTO_CLASS_WEIGHTS`), Google Cloud.
