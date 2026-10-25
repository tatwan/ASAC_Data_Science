# Lab 05 · Choosing k: why five groups?

In this self-guided lab, you will train the mall model with three and four groups, compare four values of k on BigQuery's score and on their profiles, and see where the score stops and the business decision starts.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.mall` · **SQL:** `Solved/choosing_k_and_tuning.sql`

## The one idea

The number of groups, k, is our choice. A score can tell us which k gives tighter, better-separated groups. It cannot tell us how many campaigns marketing can run. Both matter.

## How to work through this lab

Run each query, compare with **What you should see**, and answer **Think** in one line.

You need `ml.mall_segments` (k = 5, activity 01) and `ml.mall_k6` (k = 6, activity 04, block 3). If either is missing, run that block first. The values below were worked out outside BigQuery with the same settings; random starts move them a little.

## Step 1 · Train with three and with four groups

The same statement as in class, with a different `num_clusters`:

```sql
CREATE OR REPLACE MODEL ml.mall_k3
OPTIONS (model_type = 'KMEANS', num_clusters = 3, kmeans_init_method = 'KMEANS++') AS
SELECT annual_income_k, spending_score
FROM ml.mall;

CREATE OR REPLACE MODEL ml.mall_k4
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++') AS
SELECT annual_income_k, spending_score
FROM ml.mall;
```

`standardize_features` is left out: its default is `TRUE`, the same as in class.

## Step 2 · Score each k

Run this once for each model: `ml.mall_k3`, `ml.mall_k4`, `ml.mall_segments` (k = 5) and `ml.mall_k6`. Change only the model name.

```sql
SELECT ROUND(davies_bouldin_index, 2) AS davies_bouldin,
       ROUND(mean_squared_distance, 2) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.mall_k3);
```

**What you should see:**

| k | Davies–Bouldin | Mean squared distance |
|---:|---:|---:|
| 3 | ≈ 0.72 | ≈ 0.78 |
| 4 | ≈ 0.71 | ≈ 0.54 |
| 5 | ≈ 0.57 | ≈ 0.33 |
| 6 | ≈ 0.63–0.67 | ≈ 0.27–0.29 |

Mean squared distance usually falls as k grows. In theory it would reach 0 with one group per shopper, which is no use to marketing, so it cannot choose k. The Davies–Bouldin index also looks at how far apart the groups are, and it can rise again: here it is lowest at 5. If one of your rows is much higher than the table, that run landed in a worse split; train it again.

**Think:** the index prefers 5. Name one business reason to choose 4, and one to choose 6.

## Step 3 · What do four groups look like?

The profile query from activity 04, on the four-group model:

```sql
SELECT centroid_id, COUNT(*) AS shoppers,
       ROUND(AVG(annual_income_k), 1) AS avg_income_k,
       ROUND(AVG(spending_score), 1) AS avg_score,
       ROUND(AVG(age), 1) AS avg_age
FROM ML.PREDICT(MODEL ml.mall_k4, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY avg_income_k;
```

**What you should see:** about 23 · 100 · 39 · 38 shoppers. The young, low-income big spenders and the middle group have merged into one group of about 100. Compare with the five profiles from activity 04.

**Think:** would marketing lose anything useful by running four campaigns instead of five?

## Step 4 · k is a hyperparameter

A **hyperparameter** is a setting you choose before training; the model does not learn it from the data. You have met one before: L2 regularisation (D11 lab 07). Tree depth comes on D14. The method is always the same: try a few values, compare them on a score that fits the question, and let the people who will use the result make the final call.

BigQuery can also try many values of k for you (hyperparameter tuning). With only 200 shoppers its scores are too noisy to trust, so we leave it for larger tables.

## What you saw

| Question | Your answer |
|---|---|
| Which score keeps falling as k grows? | |
| Which k did the Davies–Bouldin index prefer? | |
| Which k would you give marketing, and why? | |

## References

Mall Customer Segmentation Data, [Kaggle](https://www.kaggle.com/datasets/vjchoudhary7/customer-segmentation-tutorial-in-python). BigQuery ML: [CREATE MODEL for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans) (`NUM_CLUSTERS`), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), Google Cloud.
