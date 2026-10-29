# What is this diamond worth? Regression, start to finish

In this activity, you will upload a new table into `ml`, then take it through the same five steps every BigQuery ML model follows: look, create, evaluate, predict, save as a view.

**In class:** following along · **Data:** `ml.diamonds` (new) → `ml.diamond_price`, `ml.v_diamond_prices` · **Starter:** `Unsolved/diamond_prices.sql`

## The story

A jeweller has 53,940 diamonds on file, each with its weight in carats, its cut, colour and clarity, its measurements and the price it sold for. A customer brings in a stone and asks what it is worth. You have done this kind of question before: on D11 it was charges for an insured person, now it is the price of a diamond. The SQL is almost the same.

## What you will learn

- The five steps, in one sitting: look at the table, `CREATE MODEL`, `ML.EVALUATE`, `ML.PREDICT`, `CREATE VIEW`.
- To leave the ID out of the features with `SELECT * EXCEPT (diamond_id)`.
- To spot a prediction that makes no sense, and say why a straight line produces it.

## Before you start: upload `diamonds.csv`

Each of today's four activities starts by uploading its own file into your `ml` dataset. The four files are in the course GitHub repository, in the folder [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md).

1. **Download the file.** Open [`diamonds.csv`](../../../../../shared/datasets/ml_recap/diamonds.csv) on GitHub and click **Download raw file** (the downward arrow, top right). Do not open it in Excel and save it again.
2. **Make sure `ml` exists.** Run `CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');`. You made `ml` on D11; if it is already there, nothing changes.
3. **Upload it.** Next to `ml`, **⋮** → **Create table**. **Create table from:** Upload; choose `diamonds.csv`; **File format:** CSV. **Table:** `diamonds`. **Schema:** tick **Auto detect**. **Create table**. The steps are the same as in [Upload a CSV to BigQuery](../../../../02-sql/resources/upload-a-csv-to-bigquery.md).

**Check:** `SELECT COUNT(*) FROM ml.diamonds;` returns 53,940. The dataset [README](../../../../../shared/datasets/ml_recap/README.md) lists a check for each of the four tables.

## Step 1 · Look: one row is one diamond

```sql
SELECT COUNT(*) AS diamonds_on_file,
       MIN(price) AS cheapest, MAX(price) AS dearest,
       ROUND(AVG(price)) AS average_price
FROM ml.diamonds;
```

**What you should see:** 53,940 diamonds, from 326 to 18,823 dollars, an average of 3,933. Half the diamonds sold for 2,401 dollars or less (the median). The label is `price`, a number, so this is regression.

## Step 2 · Create the model

```sql
CREATE OR REPLACE MODEL ml.diamond_price
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['price']) AS
SELECT * EXCEPT (diamond_id)
FROM ml.diamonds;
```

`SELECT * EXCEPT (diamond_id)` passes every column but the ID. An ID is a label on a row, not a property of the stone; left in, the model would treat it as a feature (D14's warm-up). `cut`, `color` and `clarity` are text, so BigQuery turns each into one weight per category, as with `region` on D11.

**What you should see:** the model `diamond_price` under `ml`, after a minute or two.

## Step 3 · Evaluate

```sql
SELECT ROUND(mean_absolute_error) AS mae,
       ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.diamond_price);
```

With no table given, `ML.EVALUATE` scores the rows BigQuery held aside during training (the default `AUTO_SPLIT`; D11 lab 05).

**What you should see:** MAE about 740 dollars, R² about 0.92. Guessing the median price for every diamond misses by 2,808 dollars on average, so the model's typical miss is about a quarter of the guess's.

## Step 4 · Predict, and read the first rows

```sql
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(predicted_price) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price, TABLE ml.diamonds)
ORDER BY diamond_id
LIMIT 5;
```

`ML.PREDICT` adds `predicted_price` (`predicted_` plus the label's name) and passes the other columns through.

**What you should see:** five small diamonds (0.21 to 0.31 carats) that sold for 326 to 335 dollars, with predictions about −1,350, −670, 210, −830 and −3,460.

A diamond worth about minus 1,350 dollars. The model is a straight line: every extra carat adds the same amount, and every step down in colour or clarity takes the same amount off. Real prices climb faster than that as stones get bigger, so the line has to start below zero to reach the big stones. About 7 in every 100 predictions are below zero, 9 in 10 of them for stones under half a carat. D14's trees, or predicting the logarithm of the price ([lab 06](../06-Lab-MLOps-Versions-And-Promotion/README.md)), avoid it.

## Step 5 · Save the predictions as a view

```sql
CREATE OR REPLACE VIEW ml.v_diamond_prices AS
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(predicted_price) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price, TABLE ml.diamonds);

SELECT COUNT(*) AS diamonds_scored,
       COUNTIF(predicted_price < 0) AS below_zero
FROM ml.v_diamond_prices;
```

**What you should see:** the view `v_diamond_prices` under `ml`, then 53,940 diamonds, about 3,900 of them below zero. A report in Power BI can read this view by name; when the model improves, the view serves the new predictions.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 53,940 · 326 · 18,823 · 3,933 |
| 3 | 1 | MAE about 740 · R² about 0.92 |
| 4 | 5 | diamond 1: price 326, prediction below zero |
| 5 | 1 | 53,940 scored · about 3,900 below zero |

The model's numbers come from a check outside BigQuery with the same columns; yours will differ a little, because BigQuery holds aside a random set of rows.

## If something goes wrong

- **`Not found: Table ml.diamonds`:** do "Before you start" first.
- **`Not found: Dataset …:ml`:** run the `CREATE SCHEMA` line in "Before you start", then upload again.
- **The count is not 53,940:** the wrong file, or a file saved again by Excel. Download it again with **Download raw file**, delete the table and upload again.
- **`Unrecognized name: predicted_price`:** the name follows the label exactly: `predicted_` + `price`.
- **The model trains on `diamond_id`:** the `EXCEPT` is missing. Retrain.

## Hint

In step 4, sort by `predicted_price` instead of `diamond_id` to see the lowest predictions. What do those diamonds have in common?

## Bonus

Which diamonds does the model price worst? Order the view by `ABS(price - predicted_price) DESC` and look at the carats of the first ten.

## References

Diamonds: prices and attributes of 53,940 round-cut diamonds, the `diamonds` data in the ggplot2 package for R ([`tidyverse/ggplot2`](https://github.com/tidyverse/ggplot2)), MIT licence; course copy in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md), taken 27 October 2026. BigQuery ML: [CREATE MODEL for linear regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), Google Cloud.
