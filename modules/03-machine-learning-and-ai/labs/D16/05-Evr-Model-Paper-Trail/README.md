# A model's paper trail, and a view as the contract

In this activity, you will look up what BigQuery keeps about the diamond model you trained in activity 01, then compare the view you saved with a table of the same rows, so you can say why a report should read a view.

**In class:** following along · **Data:** `ml.diamond_price` and `ml.v_diamond_prices` (activity 01) → `ml.diamond_prices_snapshot` · **Starter:** `Unsolved/model_paper_trail.sql`

## The story

The jeweller's pricing team builds a report on your diamond prices. In a month they open it and ask three questions. Which model made these numbers? When was it trained, and on which rows? And are the numbers still right, now that the shop sells different stones?

A model saved in a dataset cannot answer those questions by itself. The habits and tools that can are what people call MLOps. This activity tries two of them that work in the sandbox: the record BigQuery keeps about every model, and a view that always serves the current model's predictions.

## What you will learn

- Where BigQuery shows a model's type, options, training rows and scores, and what `ML.TRAINING_INFO` adds.
- The difference between saving predictions as a table (a snapshot) and as a view (the query runs again every time someone reads it).
- Why a report should read a view name that stays the same while the model behind it is retrained or replaced.

## Before you start

You need the model `ml.diamond_price` and the view `ml.v_diamond_prices`, made in [activity 01](../01-Evr-Diamond-Prices/README.md) (steps 2 and 5). Check: `SELECT COUNT(*) FROM ml.v_diamond_prices;` returns 53,940.

If they are missing, make them now. First upload `diamonds.csv` into `ml` as activity 01's "Before you start" shows (the file is in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md); table `diamonds`, **Auto detect**; 53,940 rows). Then run:

```sql
CREATE OR REPLACE MODEL ml.diamond_price
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['price']) AS
SELECT * EXCEPT (diamond_id)
FROM ml.diamonds;

CREATE OR REPLACE VIEW ml.v_diamond_prices AS
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(predicted_price) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price, TABLE ml.diamonds);
```

Training takes a minute or two.

Everything here runs in a sandbox: the model is linear, and views are allowed.

## Step 1 · What BigQuery kept about the model

In the **Explorer**, open `ml`, then **Models**, then click `diamond_price`. Look at the tabs:

- **Details:** the model type (linear regression), when it was created, the label (`price`) and the options you set.
- **Training:** how training went, round by round.
- **Evaluation:** the scores on the rows BigQuery held aside (MAE about 740, R² about 0.92).
- **Schema:** the columns the model expects at prediction (`carat`, `cut`, `color`, `clarity` and the rest) and what it returns.

**Think:** which of the pricing team's three questions can you already answer from these tabs?

## Step 2 · ML.TRAINING_INFO

```sql
SELECT training_run, iteration, ROUND(loss) AS loss, duration_ms
FROM ML.TRAINING_INFO(MODEL ml.diamond_price)
ORDER BY iteration;
```

`ML.TRAINING_INFO` returns one row per round of training. `training_run` is 0 for a new model. `loss` is the training error; `duration_ms` is how long the round took.

**What you should see:** one row, or a few. A linear model often finishes in one round. Trees take many rounds.

## Step 3 · A table of the same rows

You saved the predictions as a view in activity 01. Now save the same rows as a table, the way you saved results in the SQL weeks:

```sql
CREATE OR REPLACE TABLE ml.diamond_prices_snapshot AS
SELECT * FROM ml.v_diamond_prices;

SELECT
  (SELECT ROUND(AVG(predicted_price)) FROM ml.v_diamond_prices)        AS view_average,
  (SELECT ROUND(AVG(predicted_price)) FROM ml.diamond_prices_snapshot) AS table_average;
```

**What you should see:** a table `diamond_prices_snapshot` under `ml` (its icon differs from the view's), then the same average twice. Today they agree.

## Step 4 · Table or view?

| | `ml.diamond_prices_snapshot` (table) | `ml.v_diamond_prices` (view) |
|---|---|---|
| What is stored | 53,940 rows, written once | the query |
| When the model is retrained | still shows the old predictions | shows the new model's predictions at the next read |
| Cost of reading it | reads the stored rows | runs `ML.PREDICT` again, every time |

Google's page on views: "the query that defines the view is run each time the view is queried."

**Think, and answer in Slack:** the pricing team's report reads `ml.v_diamond_prices`. You retrain `ml.diamond_price` next month with the same name. What changes in the report, and what does the pricing team have to do?

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 2 | 1 or a few | `training_run` is 0 |
| 3 | 1 | the two averages are equal |

## If something goes wrong

- **`Not found: Model ml.diamond_price`:** do activity 01, step 2 first.
- **`Not found: Table ml.v_diamond_prices`:** do activity 01, step 5 first.
- **The view is created but reading it fails:** a view must name the dataset in front of every table and model (`ml.diamond_price`, not `diamond_price`).

## Hint

For the Think question in step 4: a report reads a name. What sits behind the name is your decision.

## Bonus

Lab 06 trains a second version of the diamond model that never prices a stone below zero, and points the view at it. Before you swap, what would you check?

## References

Diamonds: the `diamonds` data in the ggplot2 package for R ([`tidyverse/ggplot2`](https://github.com/tidyverse/ggplot2)), MIT licence; course copy in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md). BigQuery: [ML.TRAINING_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), [Introduction to logical views](https://docs.cloud.google.com/bigquery/docs/views-intro), [Get model metadata](https://docs.cloud.google.com/bigquery/docs/getting-model-metadata), Google Cloud.
