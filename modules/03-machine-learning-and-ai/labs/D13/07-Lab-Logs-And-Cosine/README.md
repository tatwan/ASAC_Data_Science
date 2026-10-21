# Lab 07 · Heavy tails and logs: a wholesaler's clients

In this self-guided lab, you will cluster 440 clients of a food wholesaler twice: once on their spending as recorded, and once on the logarithm of their spending, and see why a few very large clients can spoil the groups.

**When:** after class, at your own pace. Not submitted. · **Data:** [`wholesale_customers.csv`](../../../../../shared/datasets/ml_classics/wholesale_customers.csv) → `ml.wholesale` · **SQL:** `Solved/logs_and_cosine.sql`

## The story

A wholesale distributor in Portugal sells to hotels, restaurants and cafés (the trade calls them **Horeca**) and to shops (**Retail**). For each client it records a year's spending, in its own monetary units, on six kinds of product: fresh food, milk products, grocery, frozen food, detergents and paper, and delicatessen. The sales director asks: *which kinds of client do we serve, so that each gets the right delivery plan and the right offers?*

## The one idea

When most values are small and a few are huge (a **heavy tail**), k-means spends its groups on the giants. Scaling does not fix this; taking the logarithm does. Scaling and logs fix different problems, and you often need both.

## How to work through this lab

Upload [`wholesale_customers.csv`](../../../../../shared/datasets/ml_classics/wholesale_customers.csv) as the table `wholesale` in `ml` (**⋮** → **Create table**, Upload, CSV, **Auto detect**). It has 440 rows; `channel` is Horeca or Retail.

Run each query, compare with **What you should see**, and answer **Think** in one line. The values were worked out outside BigQuery. This data moves more between runs than the mall's, so compare the kind of groups you get, not exact sizes.

## Step 1 · Look at the spending first

```sql
SELECT MIN(fresh) AS min_fresh,
       ROUND(AVG(fresh)) AS avg_fresh,
       MAX(fresh) AS max_fresh
FROM ml.wholesale;
```

**What you should see:** fresh food from 3 to 112,151, with an average of about 12,000. Half the clients spend less than about 8,500; a few spend ten times that and pull the average up. Most values small, a long thin tail of large ones: a heavy tail. The other five columns look the same.

## Step 2 · Scaled, but not logged

```sql
CREATE OR REPLACE MODEL ml.wholesale_scaled
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++',
         standardize_features = TRUE) AS
SELECT fresh, milk, grocery, frozen, detergents_paper, delicatessen
FROM ml.wholesale;

SELECT centroid_id, COUNT(*) AS clients,
       ROUND(COUNTIF(channel = 'Retail') / COUNT(*), 2) AS share_retail,
       ROUND(AVG(fresh)) AS avg_fresh,
       ROUND(AVG(grocery)) AS avg_grocery
FROM ML.PREDICT(MODEL ml.wholesale_scaled, (SELECT * FROM ml.wholesale))
GROUP BY centroid_id
ORDER BY clients DESC;
```

**What you should see:** one very large group (often about 300 of the 440) and, in most runs, at least one group of 10 clients or fewer: the biggest spenders, alone. Scaling put the six columns on the same scale, but inside each column the giants are still far from everyone else, so the groups are about them.

**Think:** would the sales director get anything useful from a group of five giant clients?

## Step 3 · Logs first, then scaling

`LN(1 + x)` is the natural logarithm of one more than the value. Ten times more spending adds about 2.3, whatever the starting amount, so 1,000 against 10,000 counts the same as 10,000 against 100,000. The `1 +` keeps a spend of 0 from breaking it. A view keeps the logged columns next to the originals:

```sql
CREATE OR REPLACE VIEW ml.wholesale_logs AS
SELECT *,
       LN(1 + fresh) AS log_fresh,
       LN(1 + milk) AS log_milk,
       LN(1 + grocery) AS log_grocery,
       LN(1 + frozen) AS log_frozen,
       LN(1 + detergents_paper) AS log_detergents_paper,
       LN(1 + delicatessen) AS log_delicatessen
FROM ml.wholesale;

CREATE OR REPLACE MODEL ml.wholesale_log_model
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++',
         standardize_features = TRUE) AS
SELECT log_fresh, log_milk, log_grocery, log_frozen, log_detergents_paper, log_delicatessen
FROM ml.wholesale_logs;
```

Profile the groups in plain units, with the original columns the view kept:

```sql
SELECT centroid_id, COUNT(*) AS clients,
       ROUND(COUNTIF(channel = 'Retail') / COUNT(*), 2) AS share_retail,
       ROUND(AVG(fresh)) AS avg_fresh,
       ROUND(AVG(grocery)) AS avg_grocery
FROM ML.PREDICT(MODEL ml.wholesale_log_model, (SELECT * FROM ml.wholesale_logs))
GROUP BY centroid_id
ORDER BY clients DESC;
```

**What you should see:** four groups of usable size; in almost every run the smallest has 20 clients or more. Typically two groups are nearly all Horeca (lots of fresh food) and two are mostly Retail (lots of grocery). The model never saw `channel`, and still found most of that split.

**Think:** scaling fixed one problem in step 2 and not another. Say both problems in your own words.

## What you saw

| Fix | The problem it solves | Where you write it |
|---|---|---|
| Scaling | | `standardize_features = TRUE` (the default) |
| Logs | | `LN(1 + x)` in a view or the `SELECT` |

## Bonus · Group by the mix, not the size

Add `distance_type = 'COSINE'` to step 2's `OPTIONS` (with `num_clusters = 2` and `standardize_features = FALSE`), train it under a new name, and count `channel` in each group. Cosine distance compares what clients buy (the mix), not how much: a client who buys 1,000 of everything and one who buys 10,000 of everything count as alike. Expect two groups that line up closely with Horeca and Retail.

## References

Wholesale customers (Cardoso, 2013), UCI Machine Learning Repository, [doi:10.24432/C5030X](https://doi.org/10.24432/C5030X), [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026 (channel and region codes written out as words; `client_id` added). BigQuery ML: [CREATE MODEL for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans) (`DISTANCE_TYPE`, `STANDARDIZE_FEATURES`), Google Cloud.
