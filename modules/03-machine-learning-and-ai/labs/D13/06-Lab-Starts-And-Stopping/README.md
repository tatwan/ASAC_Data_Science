# Lab 06 · The same groups every time

In this self-guided lab, you will watch k-means train round by round, then start it from five shoppers you choose so that it gives the same groups every time you run it.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.mall` and the model `ml.mall_segments` (activity 01) · **SQL:** `Solved/starts_and_stopping.sql`

## The one idea

k-means starts from random centres, so two runs of the same statement can end in different groups. In class, about one run in three ended with a group of about 100 shoppers. Marketing will not accept segments that change every time someone presses Run. If you choose the starting centres yourself, nothing is random, and the result repeats.

## How to work through this lab

Run each query, compare with **What you should see**, and answer **Think** in one line. You need `ml.mall_segments` from activity 01. The values below were worked out outside BigQuery with the same settings.

## Step 1 · Training, round by round

```sql
SELECT iteration, ROUND(loss, 3) AS loss
FROM ML.TRAINING_INFO(MODEL ml.mall_segments)
ORDER BY iteration;
```

One row per round of assign and update, the two steps you did by hand in class. `loss` is how far the shoppers sit from their centres (in scaled units). Each round should lower it.

**What you should see:** about 4 to 6 rows. The loss falls fast and then barely moves, ending near 0.33 (or near 0.49 if your run landed in the worse split). Training stopped by itself once a round improved the loss by less than 1%.

**Think:** why does the loss fall fast at first and slowly later? (Hint: how far do the centres move in the first round, and in the last?)

## Step 2 · Start from shoppers you choose

```sql
CREATE OR REPLACE MODEL ml.mall_fixed
OPTIONS (model_type = 'KMEANS', num_clusters = 5,
         kmeans_init_method = 'CUSTOM', kmeans_init_col = 'is_start') AS
SELECT annual_income_k, spending_score,
       customer_id IN (1, 2, 41, 124, 125) AS is_start
FROM ml.mall;
```

- `kmeans_init_method = 'CUSTOM'`: we pick the starting centres.
- `kmeans_init_col = 'is_start'`: the rows where `is_start` is TRUE become the first centres. There must be exactly five of them, one per group.
- `customer_id IN (1, 2, 41, 124, 125)` is TRUE for those five shoppers and FALSE for everyone else. BigQuery does not use this column to measure distance.

The five shoppers sit in five corners of the income-and-score picture: low income with a low and a high score, the middle, high income with a high and a low score.

Now look at the groups:

```sql
SELECT centroid_id, COUNT(*) AS shoppers
FROM ML.PREDICT(MODEL ml.mall_fixed, (SELECT * FROM ml.mall))
GROUP BY centroid_id
ORDER BY shoppers DESC;
```

**What you should see:** the five usual groups, about 80 · 39 · 36 · 23 · 22.

## Step 3 · Run it again

Run both statements from step 2 again, exactly as they are.

**What you should see:** the same five sizes as before. Run it as often as you like: nothing in it is random, so the groups come back every time.

**Think:** when would a business want fixed starting centres? What could go wrong if you choose them badly? (Activity 02's bad start is one answer.)

## What you saw

| Question | Your answer |
|---|---|
| How many rounds did `ml.mall_segments` need? | |
| What makes `ml.mall_fixed` give the same groups every time? | |
| One risk of choosing the starts yourself | |

## Bonus

Stop training after one round with `max_iterations = 1` (add it to the `OPTIONS` of activity 01's model, under a new name), then compare its `mean_squared_distance` from `ML.EVALUATE` with 0.33. One round, as in activity 02, is rarely enough.

## References

Mall Customer Segmentation Data, [Kaggle](https://www.kaggle.com/datasets/vjchoudhary7/customer-segmentation-tutorial-in-python). BigQuery ML: [CREATE MODEL for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans) (`KMEANS_INIT_METHOD`, `KMEANS_INIT_COL`, `MAX_ITERATIONS`), [ML.TRAINING_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train), Google Cloud.
