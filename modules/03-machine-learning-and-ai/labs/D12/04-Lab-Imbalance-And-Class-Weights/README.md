# Lab 04 · When accuracy misleads: a rare Yes and class weights

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

**What you should see:** 237 TRUE and 1,233 FALSE. Only 237 ÷ 1,470 = 16% left. Saying "stays" for everyone is right 84% of the time and finds nobody who leaves: its recall is 0.

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

Why? The model sees about five stayers for every leaver, so the stayers dominate what it learns. Its probability of leaving comes out low for almost everyone, nearly always below 0.5, and at the default threshold of 0.5 almost nobody is flagged.

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

`auto_class_weights = TRUE` gives each leaver more weight in training and each stayer less, so the two groups count the same in total. BigQuery works the weights out from the training rows: here each leaver counts about five times as much as each stayer (1,233 ÷ 237 ≈ 5.2).

Now put the two models side by side:

```sql
SELECT 'plain' AS model, ROUND(accuracy, 3) AS accuracy,
       ROUND(precision, 3) AS precision, ROUND(recall, 3) AS recall,
       ROUND(roc_auc, 3) AS roc_auc
FROM ML.EVALUATE(MODEL ml.attrition_plain)
UNION ALL
SELECT 'auto weights', ROUND(accuracy, 3), ROUND(precision, 3),
       ROUND(recall, 3), ROUND(roc_auc, 3)
FROM ML.EVALUATE(MODEL ml.attrition_weighted);
```

Both models use the same table and the same columns, so BigQuery holds aside the same 20% of employees for both: a fair comparison.

**What you should see:**

| Model | Accuracy | Precision | Recall | ROC AUC |
|---|---:|---:|---:|---:|
| plain | ≈ 0.84 | — | ≈ 0 | ≈ 0.69 |
| auto weights | ≈ 0.62 | ≈ 0.25 | ≈ 0.67 | ≈ 0.69 |

The plain model flags only one or two employees, so its precision can come out anywhere from 0 to 1 (or empty, if it flags nobody) and tells you little.

Accuracy went **down**, and the model became more useful: it now finds about two in three leavers. Precision shows the price: only about one in four employees it flags really leaves. ROC AUC barely moved. The class weights did change what the model learned (its weights and its probabilities), so on other data ROC AUC can move too. Here they changed who gets flagged far more than how well the model ranks employees.

One warning: the weights push every probability of leaving up, on purpose. The weighted model's probabilities are no longer honest chances of leaving, so do not price them with a cost rule like lab 03's. For that, use the plain model and a lower threshold.

## Step 4 · A lower threshold does something similar

Back to the plain model. `ML.ROC_CURVE` shows its recall at low thresholds:

```sql
SELECT ROUND(threshold, 2) AS threshold, ROUND(recall, 2) AS recall,
       ROUND(false_positive_rate, 2) AS false_positive_rate
FROM ML.ROC_CURVE(MODEL ml.attrition_plain)
WHERE threshold BETWEEN 0.15 AND 0.25
ORDER BY threshold;
```

`false_positive_rate` is the share of stayers flagged by mistake, as in lab 03.

**What you should see:** around threshold 0.2, recall is about half, and the false positive rate is about a quarter: one stayer in four is flagged. `ML.ROC_CURVE` picks its own thresholds, so read the row nearest 0.2. The plain model was not blind; its probabilities were all low. A lower threshold finds more leavers and flags more stayers: the same trade the class weights made.

Two tools, one trade:

| | Class weights | A lower threshold |
|---|---|---|
| When | while the model trains | after training, when you use the model |
| Changes what the model learned? | yes | no |
| Changes who gets flagged? | yes | yes |

## Step 5 · Would you use it?

ROC AUC about 0.69 says the model ranks leavers above stayers more often than chance, but not by much. These eight columns do not hold the strongest reasons people leave (overtime, stock options and years since a promotion are in IBM's full dataset, not in ours).

**Think:** HR wants to use the weighted model to choose who gets a retention interview. Write three sentences: what it would do well, what it would get wrong, and what data you would ask for first.

**Think, too:** the model uses `Gender`. Would you let HR pick people from its list automatically? Or would you want a person to look at each case, and a check that the model treats men and women alike, first?

## What you saw

| Model | Accuracy | Precision | Recall | ROC AUC | False positive rate |
|---|---:|---:|---:|---:|---:|
| plain, threshold 0.5 | | | | | — |
| `AUTO_CLASS_WEIGHTS` | | | | | — |
| plain, threshold about 0.2 | — | — | | — | |

## References

IBM HR Analytics Employee Attrition & Performance (fictional data created by IBM data scientists; Kaggle), course copy of ten columns in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). BigQuery ML: [CREATE MODEL for logistic regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm) (`AUTO_CLASS_WEIGHTS`), Google Cloud.
