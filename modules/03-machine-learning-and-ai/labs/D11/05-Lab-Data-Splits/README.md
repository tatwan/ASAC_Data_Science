# Lab 05 · Which rows are held aside? The data split options

In this self-guided lab, you will train the same model on the cars data five times, changing only how BigQuery splits the rows, and watch how much the score depends on which rows it is measured on.

**When:** after class, at your own pace. Not submitted. · **Data:** [`mpg.csv`](../../../../../shared/datasets/ml_classics/mpg.csv) → `ml.cars` · **SQL:** `Solved/data_splits.sql` (every query is also in this page)

## How to work through this lab

Each step gives you a query, tells you what to look for, and asks you one question. Run the query, compare what you see with **What you should see**, and write your answer to **Think** in one line, in a file or on paper. Nothing here needs to be solved from scratch: the point is to see what each option does.

The options come from Google's reference page for linear and logistic regression: [The CREATE MODEL statement for generalized linear models](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm). Keep it open in another tab.

## The data

398 car models from the 1970s and early 1980s. One row is one car model. The label is `mpg`, miles per gallon: higher is more fuel efficient (10 mpg is about 4.3 km per litre). The features are `cylinders`, `displacement` (engine size, cubic inches), `horsepower`, `weight` (pounds) and `acceleration` (seconds from 0 to 60 mph).

## Step 1 · Upload, and check every column's type

Upload `mpg.csv` to the `ml` dataset as `cars` (**⋮** → **Create table**, Upload, CSV, **Auto detect**). Then open the table's **Schema** tab.

**What you should see:** six columns. Five are numbers (INTEGER or FLOAT). `horsepower` is **STRING**.

Find out why:

```sql
SELECT horsepower, COUNT(*) AS car_count
FROM ml.cars
WHERE SAFE_CAST(horsepower AS FLOAT64) IS NULL
GROUP BY horsepower;
```

**What you should see:** one row: `?`, 6 cars. Six question marks made the whole column text. A model would treat text as categories: about 94 separate horsepower "values", each with its own weight, and no idea that 150 is more than 100.

`SAFE_CAST` tries the conversion and gives `NULL` instead of an error when it cannot. Save a clean version as a view, so every model below reads the same columns:

```sql
CREATE OR REPLACE VIEW ml.cars_clean AS
SELECT mpg, cylinders, displacement,
       SAFE_CAST(horsepower AS FLOAT64) AS horsepower,
       weight, acceleration
FROM ml.cars;
```

BigQuery fills a `NULL` number with the column's average when it trains, so the six cars stay in.

**Think:** what would you have trained if you had not looked at the types first?

## Step 2 · The default: `AUTO_SPLIT`

Leave the split out entirely:

```sql
CREATE OR REPLACE MODEL ml.cars_auto
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg']) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_auto);
```

**What you should see:** MAE ≈ 3.24, R² ≈ 0.705.

`DATA_SPLIT_METHOD` defaults to `AUTO_SPLIT`. With fewer than 500 rows, it holds **nothing** aside, so this score was measured on the 398 cars the model learned from.

**Think:** is 0.705 a fair score to report to a manager? Why not?

## Step 3 · `RANDOM`, with `DATA_SPLIT_EVAL_FRACTION`

```sql
CREATE OR REPLACE MODEL ml.cars_random
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT * FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_random);
```

**What you should see:** MAE about 3.3, R² about 0.7. About 80 cars were held aside.

Try `data_split_eval_fraction = 0.4`, then `0.1`. Each time, note the R².

**Think:** compare the R² you got with 0.4, 0.2 and 0.1. With 0.1 the score rests on only about 40 cars: why is that risky? And what does the model lose when you hold aside 40%?

## Step 4 · `CUSTOM`: you choose the evaluation rows

With `CUSTOM`, you add a TRUE/FALSE column and name it in `DATA_SPLIT_COL`. TRUE rows are held aside for evaluation; the column itself is not used as a feature.

**A bad choice first.** Hold aside every heavy car:

```sql
CREATE OR REPLACE MODEL ml.cars_heavy_aside
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'CUSTOM', data_split_col = 'is_eval') AS
SELECT *, weight > 3900 AS is_eval
FROM ml.cars_clean;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_heavy_aside);
```

**What you should see:** 70 heavy cars held aside; MAE ≈ 5.3 and an R² far **below zero**, about −10.

A negative R² means the model did worse on those cars than guessing their own average. The model learned from lighter cars only and is now asked about cars heavier than any it has seen. And every heavy car has a low mpg (about 14 on average), so "guess their average" is hard to beat on that group.

**A fair choice.** Store a random split in a table once, so it never changes between runs:

```sql
CREATE OR REPLACE TABLE ml.cars_split AS
SELECT *, RAND() < 0.2 AS is_eval
FROM ml.cars_clean;

CREATE OR REPLACE MODEL ml.cars_custom
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['mpg'],
         data_split_method = 'CUSTOM', data_split_col = 'is_eval') AS
SELECT * FROM ml.cars_split;

SELECT ROUND(mean_absolute_error, 2) AS mae, ROUND(r2_score, 3) AS r2
FROM ML.EVALUATE(MODEL ml.cars_custom);
```

**What you should see:** close to step 3: MAE about 3.3, R² about 0.7.

**Think:** the model in the bad split was not worse at learning. What was wrong was the question the evaluation asked. Write one sentence about what an evaluation group should look like.

## Step 5 · `NO_SPLIT`, `SEQ` and `DATA_SPLIT_TEST_FRACTION` (read, then decide)

- **`NO_SPLIT`** trains on every row and holds nothing aside. Use it when you made your groups yourself and pass only the training rows in the `SELECT`.
- **`SEQ`** sorts the rows by `DATA_SPLIT_COL` and holds aside the last part. That is the right split for data in time order: train on the past, evaluate on the most recent rows. Cars have no time order, so step 4's heavy-car result shows what happens when a sorted split is used on the wrong column. You will meet `SEQ` again with forecasting.
- **`DATA_SPLIT_TEST_FRACTION`** holds aside a third group, a test set, but only when BigQuery tunes the model's settings for you (hyperparameter tuning, with `NUM_TRIALS`). For a single model, one evaluation group is what you get.

**Think:** for monthly sales data, which split method would you use, and why not `RANDOM`?

## What you saw

Fill in the table as you go. It is your summary of this lab.

| Model | Split | Rows held aside | MAE | R² |
|---|---|---:|---:|---:|
| `cars_auto` | AUTO_SPLIT (fewer than 500 rows) | 0 | ≈ 3.24 | ≈ 0.705 |
| `cars_random` | RANDOM, 0.2 | ≈ 80 | | |
| `cars_heavy_aside` | CUSTOM, weight above 3,900 | 70 | ≈ 5.3 | ≈ −10 |
| `cars_custom` | CUSTOM, stored random 20% | ≈ 80 | | |

## References

Auto MPG, UCI Machine Learning Repository (Quinlan, 1993), CC BY 4.0; course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). BigQuery ML: [CREATE MODEL for linear regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [ML.TRAINING_INFO](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-train), Google Cloud.
