# A first clustering: what kinds of shoppers does the mall have?

In this activity, you will upload 200 mall shoppers, train a k-means model that sorts them into five groups, look at who landed in each group, and then read what BigQuery stored: the centre of each group and each shopper's distance to every centre.

**Data:** [`mall_customers.csv`](../../../../../shared/datasets/ml_classics/mall_customers.csv) → `ml.mall` · **Starter:** `Unsolved/first_segments.sql`

## The story

A shopping mall gives its members a card. For each member it knows the age, gender, yearly income and a **spending score** from 1 to 100 that the mall works out from how often and how much the member buys. The marketing team wants to stop sending one message to everyone. Their question: *what kinds of shoppers do we have, and does each kind deserve a different campaign?*

On D11 and D12 every row carried the answer we wanted (a salary, Churn Yes or No). Here nobody has written down which kind of shopper each member is. There is no label. A model that finds groups in rows without a label is doing **clustering**, and `KMEANS` is BigQuery's clustering model.

## What you will learn

- To train a `KMEANS` model on two columns and read its groups with `ML.PREDICT`.
- Why the `SELECT` of a k-means model lists only the columns you want compared.
- What `ML.CENTROIDS` and the distances in `ML.PREDICT` hold.

## Before you start

You need the dataset `ml` (if it is missing: `CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');`). Download [`mall_customers.csv`](../../../../../shared/datasets/ml_classics/mall_customers.csv) and upload it as the table `mall` in `ml` (**⋮** → **Create table**, Upload, CSV, **Auto detect**).

## Steps

1. **Check the upload (block 1).** 200 shoppers. Income runs from 15 to 137 (thousands of dollars a year) and the spending score from 1 to 99. The two columns are on similar scales, which keeps today's first model simple; part 3 shows what happens when they are not.

2. **Look at five rows (block 2).** One row is one shopper. Five columns: `customer_id`, `gender`, `age`, `annual_income_k`, `spending_score`. None of them says which group a shopper belongs to.

3. **Train (block 3).** Read the statement before you run it:

    - `model_type = 'KMEANS'`: clustering. There is no `input_label_cols`, because there is no label.
    - `num_clusters = 5`: we ask for five groups. Choosing this number is our decision; we come back to it after the break.
    - `kmeans_init_method = 'KMEANS++'`: how the five starting centres are picked. BigQuery's default is `RANDOM`; we write `KMEANS++` out, because it spreads the starting centres apart.
    - `standardize_features = TRUE`: puts both columns on the same scale before measuring distance. It is the default; we write it out because part 3 turns it off.
    - `SELECT annual_income_k, spending_score`: **every column you select is used to measure how alike two shoppers are.** That is why the `SELECT` lists two columns and not `*`. With `SELECT *`, `customer_id` would count as a number: shopper 1 and shopper 200 would look far apart because of their ID cards.

4. **How big is each group? (block 4).** `ML.PREDICT` adds a column `centroid_id`: the number of the group each shopper joined. Count the shoppers in each.

    The numbers 1 to 5 are labels BigQuery picked, not a ranking, and your classmate's group 1 may be your group 3. Compare sizes, not numbers. Most of you will see sizes close to **81 (or 80), 39, 35 (or 36), 23 and 22**. If one of your groups has about 100 shoppers, your run started from a less lucky place; keep it, it is exactly what we look at after the break.

5. **Look inside one group (block 5).** `WHERE centroid_id = 1` keeps the shoppers of group 1. Read their income and score: shoppers in one group look alike on both columns. Change the 1 to 2, 3, 4 and 5 and run it again.

6. **The centre of each group (block 6, after the by-hand round).** `ML.CENTROIDS` returns one row per group and feature: 5 groups × 2 features = 10 rows. A **centroid** is the average shopper of its group. BigQuery standardised the columns to train, but by default it gives the centres back in the units of the columns you selected: thousands of dollars and score points.

7. **Each shopper's distance to every centre (block 7).** `nearest_centroids_distance` is a small list inside each `ML.PREDICT` row: five pairs of a centre and its distance from the shopper, nearest first. BigQuery shows the list as five lines under each shopper. The first line is the centre the shopper joined: the smallest distance wins. These distances are in scaled units (each column divided by its standard deviation), so they are small numbers.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 200 shoppers · income 15 to 137 · score 1 to 99 |
| 4 | 5 | sizes about 81, 39, 35, 23, 22 (one shopper can sit in the 80 or the 36 instead) |
| 5 | 5 | five shoppers whose income and score look alike |
| 6 | 10 | centres near (26, 79), (26, 21), (55, 50), (87, 82), (88, 17): income, score |
| 7 | 2 | each with a list of 5 distances · shopper 3 (16, 6): nearest about 0.70 · shopper 124 (69, 91): about 0.75 |

These values were computed outside BigQuery with the same settings, before the class ran them; your sizes and centres can differ slightly, because the starting centres are random.

## If something goes wrong

- **`centroid_id` is missing:** you used `ML.EVALUATE` or forgot `MODEL`; it is a column of `ML.PREDICT`.
- **Your sizes are about 100, 39, 28, 23, 10:** not an error. Keep the model; after the break we compare runs and see which split is tighter.

## References

Mall Customer Segmentation Data (200 members of a mall's card scheme, made for teaching; from the *Machine Learning A–Z* course), [Kaggle](https://www.kaggle.com/datasets/vjchoudhary7/customer-segmentation-tutorial-in-python); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. BigQuery ML: [CREATE MODEL for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), [ML.CENTROIDS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-centroids), Google Cloud.
