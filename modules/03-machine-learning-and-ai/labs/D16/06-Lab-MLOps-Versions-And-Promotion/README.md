# Lab 06 · Two versions of a model, and one promoted

In this self-guided lab, you will train two versions of the diamond price model on the same fixed rows, score them in dollars on the same validation diamonds, record both in a model log, label the winner, and put it behind the view the report reads without changing the view's columns.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.diamonds` (activity 01) → `ml.diamonds_groups`, `ml.diamond_price_v1`, `ml.diamond_price_v2`, `ml.model_log`, `ml.v_diamond_prices` · **SQL:** `Unsolved/mlops_versions_and_promotion.sql` to run step by step, `Solved/mlops_versions_and_promotion.sql`

## The story

In class, `ml.diamond_price` priced about 7 in every 100 diamonds below zero, and the view `ml.v_diamond_prices` serves those predictions to anyone who reads it. Suppose a Power BI report already reads that view. A second version of the model, which predicts the logarithm of the price, can never go below zero. Before anyone swaps it in, the jeweller's team asks for four things: proof that the new version is better on the same diamonds, a written record of both versions, a mark on the model that says which one is live, and a report that keeps working the next morning without anyone opening Power BI.

That is a small release, done the way a team would do it. Every step works in the sandbox.

## What you will learn

- To compare two versions fairly: the same training rows, the same validation rows, the same unit (dollars).
- To train on the logarithm of a label and turn the predictions back with `EXP`, and why that keeps every prediction above zero.
- To keep a model log as a table written with `CREATE OR REPLACE TABLE … AS SELECT … UNION ALL`, because the sandbox has no `INSERT`.
- To mark a model with `ALTER MODEL … SET OPTIONS (description = …, labels = …)`.
- To promote a model by replacing the view behind a report, keeping the view's column names and types.

## Before you start

You need `ml.diamonds` from [activity 01](../01-Evr-Diamond-Prices/README.md), "Before you start". Check: `SELECT COUNT(*) FROM ml.diamonds;` returns 53,940. If it is missing, upload it as activity 01 shows. The view `ml.v_diamond_prices` from activity 01, step 5, is useful for step 8 but not required: step 8 creates it either way.

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. Both models are linear regressions, which BigQuery trains itself, so they run in a sandbox in a minute or two each. The model values marked "about" were computed outside BigQuery with the same rows and columns; yours will be close but not identical. The counts are exact.

## Checkpoints

- **C1:** both versions scored on the same 10,788 validation diamonds, in dollars, with how many predictions fall below zero (step 4).
- **C2:** the model log with two rows, and `ml.v_diamond_prices` serving version 2 with the same columns as before (steps 6 and 8).
- **C3:** the promoted version's score on the test diamonds, run once (step 9).

## Step 1 · Fix the groups

```sql
CREATE OR REPLACE VIEW ml.diamonds_groups AS
SELECT *,
       CASE MOD(diamond_id, 5)
         WHEN 0 THEN 'test'
         WHEN 1 THEN 'validation'
         ELSE 'train'
       END AS split
FROM ml.diamonds;

SELECT split, COUNT(*) AS diamond_count, ROUND(AVG(price), 1) AS average_price
FROM ml.diamonds_groups
GROUP BY split
ORDER BY diamond_count DESC;
```

In class, `ml.diamond_price` used BigQuery's default split, which holds aside a random set of rows. D14 showed why that is a problem when you compare models: Google's page says a random split depends on the data *including the column names*, so a model with a different label (as version 2 will have) can hold aside different diamonds. Here you choose the rows yourself, as on D14. `MOD(diamond_id, 5)` is the remainder after dividing the ID by 5: remainder 0 goes to test, 1 to validation, and 2, 3 and 4 to training. Everyone gets the same groups, every time. (D14 used remainders 3 and 4 for validation and test; any fixed choice works, as long as every model uses the same one.)

**What you should see:** 3 rows: train 32,364 diamonds, validation 10,788, test 10,788. The average prices are 3,932.8, 3,932.1 and 3,933.5 dollars: the three groups are alike.

## Step 2 · Version 1: the class model, on the training rows

```sql
CREATE OR REPLACE MODEL ml.diamond_price_v1
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['price'],
         data_split_method = 'NO_SPLIT') AS
SELECT * EXCEPT (diamond_id, split)
FROM ml.diamonds_groups
WHERE split = 'train';
```

The same model as in class, with two changes: it learns from the 32,364 training diamonds only, and `data_split_method = 'NO_SPLIT'` tells BigQuery not to hold any more rows aside, because you already did. `split` is left out with the ID: it says which group a row is in, not anything about the stone.

Models cannot be renamed in BigQuery (Google's page: "You cannot change the name of an existing model"), so the version goes in the name from the start.

**What you should see:** the model `diamond_price_v1` under `ml`.

## Step 3 · Version 2: predict the logarithm of the price

```sql
SELECT ROUND(MIN(LN(price)), 3) AS lowest_log_price,
       ROUND(MAX(LN(price)), 3) AS highest_log_price
FROM ml.diamonds_groups
WHERE split = 'train';

CREATE OR REPLACE MODEL ml.diamond_price_v2
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['log_price'],
         data_split_method = 'NO_SPLIT') AS
SELECT * EXCEPT (diamond_id, split, price),
       LN(price) AS log_price
FROM ml.diamonds_groups
WHERE split = 'train';
```

`LN` is the natural logarithm. On the log scale, adding a fixed amount means multiplying the price by a fixed factor, so a straight line on `log_price` says "each extra step of carat or clarity multiplies the price". That fits diamonds better than "adds the same number of dollars". The other columns are the same as version 1; only the label changed, and `price` itself is left out so the model cannot see the answer.

To get dollars back, take `EXP` of the prediction. `EXP` of any number is above zero, so version 2 cannot price a diamond below zero.

**What you should see:** first 5.787 and 9.843 (the training prices run from 326 to 18,818 dollars), then the model `diamond_price_v2` under `ml`.

## Step 4 · Score both in dollars, on the same validation rows (C1)

```sql
SELECT 'ml.diamond_price_v1' AS model_name,
       ROUND(AVG(ABS(price - predicted_price)), 1) AS validation_mae,
       COUNTIF(predicted_price < 0) AS below_zero
FROM ML.PREDICT(MODEL ml.diamond_price_v1,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'))
UNION ALL
SELECT 'ml.diamond_price_v2',
       ROUND(AVG(ABS(price - EXP(predicted_log_price))), 1),
       COUNTIF(EXP(predicted_log_price) < 0)
FROM ML.PREDICT(MODEL ml.diamond_price_v2,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'));
```

`ML.PREDICT` adds `predicted_` plus the label's name: `predicted_price` for version 1 and `predicted_log_price` for version 2. It passes the other columns through, so `price` is still there to compare with. The MAE is computed here by hand, because `ML.EVALUATE` would score version 2 in log units, and a miss of about 0.11 in `log_price` cannot be put beside a miss of 742 dollars.

**What you should see:** 2 rows. Version 1: about 742 dollars, about 780 diamonds below zero. Version 2: about 492 dollars, and 0 below zero (that one is exact, because of `EXP`). For scale, guessing the training median, 2,401 dollars, for every validation diamond misses by 2,807.3 on average.

**C1:** the two rows. Which version would you promote, and is there anything in these two numbers that makes you hesitate?

## Step 5 · The same diamonds, side by side

```sql
SELECT v1.diamond_id, v1.carat, v1.cut, v1.color, v1.clarity, v1.price,
       ROUND(v1.predicted_price) AS version_1,
       ROUND(EXP(v2.predicted_log_price)) AS version_2
FROM ML.PREDICT(MODEL ml.diamond_price_v1,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation')) AS v1
JOIN ML.PREDICT(MODEL ml.diamond_price_v2,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'validation')) AS v2
  ON v1.diamond_id = v2.diamond_id
ORDER BY v1.diamond_id
LIMIT 5;
```

**What you should see:** diamonds 1, 6, 11, 16 and 21: small stones (0.23 to 0.32 carats) that sold for 326 to 351 dollars. Version 1 prices them at about −1,300 to −3,600 dollars; version 2 at about 320 to 360.

**Think:** the jeweller's staff see one of these numbers on a report. Which of the two mistakes would they notice first?

## Step 6 · The model log (C2, part 1)

```sql
CREATE OR REPLACE TABLE ml.model_log AS
SELECT 'ml.diamond_price_v1' AS model_name,
       1 AS version,
       CURRENT_DATE() AS trained_on,
       (SELECT ROUND(AVG(ABS(price - predicted_price)), 1)
        FROM ML.PREDICT(MODEL ml.diamond_price_v1,
               (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'))) AS validation_mae,
       'archived' AS stage,
       'LINEAR_REG on price; every column except diamond_id; trained on split = train' AS note
UNION ALL
SELECT 'ml.diamond_price_v2',
       2,
       CURRENT_DATE(),
       (SELECT ROUND(AVG(ABS(price - EXP(predicted_log_price))), 1)
        FROM ML.PREDICT(MODEL ml.diamond_price_v2,
               (SELECT * FROM ml.diamonds_groups WHERE split = 'validation'))),
       'production',
       'LINEAR_REG on LN(price), predictions EXP(predicted_log_price); same columns and rows as v1';

SELECT * FROM ml.model_log ORDER BY version;
```

BigQuery keeps a record of each model (activity 05 showed its tabs), but you cannot list models with a query: Google's page says "Getting information about models by querying the INFORMATION_SCHEMA views is unsupported." A small table you write yourself fills the gap: which versions exist, when each was trained, how each scored, and which one is live.

The sandbox does not run `INSERT`, so the whole log is written in one statement, one `SELECT` per version, stacked with `UNION ALL`. When a version 3 arrives, add a third `SELECT` and run the statement again. Two things to know about it:

- `CURRENT_DATE()` is the day the statement runs. Write the log on the day you train; for an older model, type its date instead, for example `DATE '2026-10-29'`.
- The log is a table on purpose. A view would score the models again every time someone reads it, and would stop working the day `ml.diamond_price_v1` is deleted. The log should keep what was true when you decided.

**What you should see:** 2 rows, with today's date, about 742 and about 492, `archived` and `production`.

## Step 7 · Label the models

```sql
ALTER MODEL ml.diamond_price_v2
SET OPTIONS (description = 'Diamond price, version 2: LINEAR_REG on LN(price). Validation MAE about 492 dollars. Served by ml.v_diamond_prices.',
             labels = [('stage', 'production'), ('version', '2')]);

ALTER MODEL ml.diamond_price_v1
SET OPTIONS (description = 'Diamond price, version 1: LINEAR_REG on price. Replaced by version 2.',
             labels = [('stage', 'archived'), ('version', '1')]);
```

`ALTER MODEL … SET OPTIONS` changes a model's details without training it again. `description` is a sentence of text. `labels` is a list of key and value pairs; Google's page describes it as "an ARRAY<STRUCT<STRING, STRING>> value that specifies any labels for the model as key,value pairs". Labels are how a team filters models later, in the console or with the `bq` command-line tool.

The same statement can also set `expiration_timestamp`, the moment BigQuery deletes the model. Google's page: "If you don't set an expiration time on a model, the model never expires and you must delete the model manually." The sandbox page says tables and views expire after 60 days; it does not mention models.

**What you should see:** both statements succeed. In the **Explorer**, open `ml`, then **Models**, then `diamond_price_v2`: its details show the description and the labels `stage: production` and `version: 2`.

## Step 8 · Promote version 2 behind the view (C2, part 2)

First, the view's columns as they are now. `INFORMATION_SCHEMA.COLUMNS` lists the columns of every table and view in a dataset:

```sql
SELECT ordinal_position, column_name, data_type
FROM ml.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'v_diamond_prices'
ORDER BY ordinal_position;
```

Then the promotion. Same view name, same columns in the same order, a different model behind it:

```sql
CREATE OR REPLACE VIEW ml.v_diamond_prices AS
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(EXP(predicted_log_price)) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price_v2, TABLE ml.diamonds);

SELECT COUNT(*) AS diamonds_scored,
       COUNTIF(predicted_price < 0) AS below_zero
FROM ml.v_diamond_prices;
```

Run the `INFORMATION_SCHEMA` query again and compare. A Power BI report finds its columns by name and type. If `predicted_price` had become `predicted_log_price`, or a number had become text, the report's visuals would break at the next refresh. With the same names and types, the report shows version 2's prices at its next refresh and nobody edits it. This is what "the view is the contract" means: the name and the columns stay fixed, and you decide what sits behind them.

Google's pages do not say whether a view may call `ML.PREDICT`. If `CREATE OR REPLACE VIEW` gives an error, or you saved a table in class because the view failed, run the same `SELECT` with `CREATE OR REPLACE TABLE ml.v_diamond_prices AS` instead. The report reads it the same way, but a table keeps its rows until you write it again, so it will not follow the next model by itself.

**What you should see:** before and after, the same 7 rows: `diamond_id`, `carat`, `cut`, `color`, `clarity`, `price`, `predicted_price`, with the same types (`predicted_price` is FLOAT64 in both). Then 53,940 diamonds scored and 0 below zero. If you had no view before, the first query returns no rows; run it after the promotion to see the 7 columns.

**C2:** the model log from step 6, and the two `INFORMATION_SCHEMA` results side by side.

## Step 9 · The test diamonds, once (C3)

```sql
SELECT ROUND(AVG(ABS(price - EXP(predicted_log_price))), 1) AS test_mae,
       COUNTIF(EXP(predicted_log_price) < 0) AS below_zero,
       COUNT(*) AS test_diamonds
FROM ML.PREDICT(MODEL ml.diamond_price_v2,
       (SELECT * FROM ml.diamonds_groups WHERE split = 'test'));
```

You chose version 2 on the validation diamonds. The test diamonds have not been used for any decision, so their score is the honest estimate of how far off version 2 will be on stones it has never seen. Run it once, for the promoted version only. If you went back and changed the model after seeing it, the test group would become a second validation group, and you would have no honest estimate left.

**What you should see:** 1 row: about 485 dollars, 0 below zero, 10,788 test diamonds. Close to the validation MAE, which is what you hope for.

**C3:** the test MAE, and one sentence on why you run it only for the version you promoted.

## What you saw

| Version | Validation MAE (dollars) | Below zero (validation) | Test MAE (dollars) | Stage |
|---|---:|---:|---:|---|
| `ml.diamond_price_v1` | | | not run | archived |
| `ml.diamond_price_v2` | | | | production |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 3 | train **32,364** · validation **10,788** · test **10,788** |
| 3 | 1 | **5.787** and **9.843** |
| 4 | 2 | v1 about **742**, about **780** below zero · v2 about **492**, **0** below zero |
| 8 | 7, 1 | the same 7 columns before and after · **53,940** scored, **0** below zero |
| 9 | 1 | about **485** · **0** below zero · **10,788** diamonds |

The MAEs were computed outside BigQuery with the same groups and columns; BigQuery's will be within a few dollars.

## Hint

Each model's prediction column is named after its label: `predicted_price` for version 1, `predicted_log_price` for version 2. If a query says `Unrecognized name`, check which model it reads.

## Bonus

- Find version 2's biggest miss on the validation diamonds: order step 5's join by `ABS(v1.price - EXP(v2.predicted_log_price)) DESC` (and change `LIMIT 5` to `LIMIT 3`). Look at the size columns of the first row. What went wrong, and is it the model's fault?
- Version 2 still uses `carat` as it is. Train a version 3 with `LN(carat) AS log_carat` in place of `carat`, score it with step 4's query, and add it to the log with a third `SELECT`. Would you promote it?

## References

Diamonds: prices and attributes of 53,940 round-cut diamonds, the `diamonds` data in the ggplot2 package for R ([`tidyverse/ggplot2`](https://github.com/tidyverse/ggplot2)), MIT licence; course copy in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md), taken 27 October 2026. BigQuery ML: [CREATE MODEL for linear regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm) (`DATA_SPLIT_METHOD`), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), [ALTER MODEL](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-alter-model), [Update model metadata](https://docs.cloud.google.com/bigquery/docs/updating-model-metadata), [Get model metadata](https://docs.cloud.google.com/bigquery/docs/getting-model-metadata) (no INFORMATION_SCHEMA for models), [Manage models](https://docs.cloud.google.com/bigquery/docs/managing-models) (models cannot be renamed), [Introduction to logical views](https://docs.cloud.google.com/bigquery/docs/views-intro), [Try BigQuery using the sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox), Google Cloud. Pages read 27 October 2026.
