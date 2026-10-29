# Lab 11 (optional, self-study) · Nakheel's spend, with trees

In this optional self-guided lab, you will take Nakheel's customer view from D11, fix three groups of customers, compare a line, boosted trees and a forest on the same validation customers, test your choice once, and see why 82 customers are not enough to be sure.

**When:** after labs 07–10, at your own pace, about 40 minutes. Optional; not submitted. · **Data:** `ml.customer_features` (D11 lab 08, step 3) · **SQL:** `Solved/nakheel_trees.sql`

## The story

D11's optional lab 08 asked Nakheel's question: *how much will each customer spend in the six months after the 1 March cutoff?* The line it trained had two problems: it predicted negative spending for about 1 customer in 8, and its score swung wildly between random splits. A forest's predictions are averages of the spend it saw, so they cannot go below zero, and trees handle a few huge customers differently from a line. Do they help on company data that is small, skewed and messy?

## What you will learn

- To run the day's fair comparison (fixed groups, the same validation customers, the test once) on company data.
- Why trees avoid the line's negative predictions.
- Why 82 validation customers cannot settle a choice between models.

## Before you start

You need the view `ml.customer_features` from [D11 lab 08](../../D11/08-Lab-Nakheel-End-To-End/README.md), step 3. If you have not done it, run that step first: it needs only the `nakheel` tables from D04. Check: `SELECT COUNT(*) FROM ml.customer_features;` returns 412.

Work like the other labs: run each query, compare with **What you should see**, and answer **Think** in one line. Values computed outside BigQuery with BigQuery's settings; tree models may differ a little from yours.

## Step 1 · Three fixed groups of customers

```sql
CREATE OR REPLACE VIEW ml.customer_groups AS
SELECT *,
       CASE MOD(ROW_NUMBER() OVER (ORDER BY customer_id), 5)
         WHEN 3 THEN 'validation'
         WHEN 4 THEN 'test'
         ELSE 'train'
       END AS split
FROM ml.customer_features;

SELECT split, COUNT(*) AS customers, ROUND(AVG(revenue_next_6m), 2) AS avg_next_6m
FROM ml.customer_groups
GROUP BY split
ORDER BY customers DESC;
```

**What you should see:** training 248 customers (average 208.40 dinars), validation 82 (226.38), test 82 (251.29).

## Step 2 · Three models, the same features

```sql
CREATE OR REPLACE MODEL ml.spend_linear
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['revenue_next_6m'], data_split_method = 'NO_SPLIT') AS
SELECT segment, city, orders_before, revenue_before, avg_order_value,
       days_since_last, tenure_days, online_share, revenue_next_6m
FROM ml.customer_groups WHERE split = 'train';

CREATE OR REPLACE MODEL ml.spend_boosted
OPTIONS (model_type = 'BOOSTED_TREE_REGRESSOR', input_label_cols = ['revenue_next_6m'], data_split_method = 'NO_SPLIT') AS
SELECT segment, city, orders_before, revenue_before, avg_order_value,
       days_since_last, tenure_days, online_share, revenue_next_6m
FROM ml.customer_groups WHERE split = 'train';

CREATE OR REPLACE MODEL ml.spend_forest
OPTIONS (model_type = 'RANDOM_FOREST_REGRESSOR', input_label_cols = ['revenue_next_6m'], data_split_method = 'NO_SPLIT') AS
SELECT segment, city, orders_before, revenue_before, avg_order_value,
       days_since_last, tenure_days, online_share, revenue_next_6m
FROM ml.customer_groups WHERE split = 'train';
```

## Step 3 · Score them on the same 82 customers

```sql
SELECT 'linear' AS model, ROUND(mean_absolute_error) AS mae, ROUND(r2_score, 2) AS r2
FROM ML.EVALUATE(MODEL ml.spend_linear, (SELECT * FROM ml.customer_groups WHERE split = 'validation'))
UNION ALL
SELECT 'boosted trees', ROUND(mean_absolute_error), ROUND(r2_score, 2)
FROM ML.EVALUATE(MODEL ml.spend_boosted, (SELECT * FROM ml.customer_groups WHERE split = 'validation'))
UNION ALL
SELECT 'random forest', ROUND(mean_absolute_error), ROUND(r2_score, 2)
FROM ML.EVALUATE(MODEL ml.spend_forest, (SELECT * FROM ml.customer_groups WHERE split = 'validation'));
```

**What you should see:**

| Model | Validation MAE (dinars) | Validation R² |
|---|---:|---:|
| linear | ≈ 226 | ≈ −0.61 |
| boosted trees | ≈ 152 | ≈ 0.58 |
| random forest | ≈ 147 (144 to 151) | ≈ 0.57 (0.56 to 0.59) |

For comparison, D11's guesses: the training average (208.40) misses these customers by about 281, the training median (39.50) by about 224. The line's R² is below zero: on these 82 customers it does worse than guessing the average.

## Step 4 · Below zero

```sql
SELECT 'linear' AS model, COUNTIF(predicted_revenue_next_6m < 0) AS negative_predictions
FROM ML.PREDICT(MODEL ml.spend_linear, (SELECT * FROM ml.customer_groups))
UNION ALL
SELECT 'random forest', COUNTIF(predicted_revenue_next_6m < 0)
FROM ML.PREDICT(MODEL ml.spend_forest, (SELECT * FROM ml.customer_groups));
```

**What you should see:** about 50 of the 412 customers for the line; none for the forest. A forest's prediction is an average of training customers' spend, so it stays within what it saw. (Boosted trees add corrections round by round and can dip a little below zero for a handful of customers.)

## Step 5 · Choose, then test once

On validation, the forest has the lowest average miss, no negative predictions, and a much smaller gap between training and validation than the boosted trees (training R² about 0.76 against about 0.99). Write your choice down, then:

```sql
SELECT ROUND(mean_absolute_error) AS mae, ROUND(r2_score, 2) AS r2
FROM ML.EVALUATE(MODEL ml.spend_forest, (SELECT * FROM ml.customer_groups WHERE split = 'test'));
```

**What you should see:** MAE about 212 dinars, R² about 0.52. The median guess misses the same test customers by about 259, the average guess by about 351.

## Step 6 · Why 82 customers are not enough

After the choice, for learning only (this is not a second chance to choose): on the same test customers, the line scores R² about 0.84 and MAE about 174, better than the forest. On validation it was the worst of the three.

Two groups of 82 customers gave opposite answers. A few wholesale customers spend thousands while most spend little or nothing; whichever group they land in decides the score. In class, on 1,338 insured people, validation and test agreed within 0.02. Here they disagree by more than 1.0.

**Think:** what would you tell Nakheel's marketing team about any of these three models? Name one thing that would make the comparison trustworthy (more customers, more deals as in activity 06, a label with less extreme values).

## What you saw

| Step | What you found |
|---|---|
| Three models on 82 validation customers | |
| Negative predictions | |
| The test, once | |
| Validation against test | |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026; see [the dataset README](../../../../../shared/datasets/nakheel/README.md). BigQuery ML: [CREATE MODEL for boosted trees](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-boosted-tree), [for random forests](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-random-forest), Google Cloud.
