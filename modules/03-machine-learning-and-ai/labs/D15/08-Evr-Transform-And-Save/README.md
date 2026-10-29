# Fix the leak with TRANSFORM, then save predictions for Power BI

In this activity, you will measure the small leak in D14 lab 10's BMI bands, train a model whose `TRANSFORM` clause computes the bands from training rows only, and save a forecast and a set of scored people as tables that Power BI can read.

**Time:** about 15 minutes in class, following along · **Data:** `ml.insurance_groups` (D14 activity 01), `ml.air_arima_final` (activity 06) and `ml.air_test` (activity 03) → `ml.ins_transform`, `ml.air_forecast`, `ml.insurance_scored` · **Starter:** `Unsolved/transform_and_save.sql`

## The story

On D14 lab 10, `ML.QUANTILE_BUCKETIZE(bmi, 4) OVER ()` cut BMI into four bands over all 1,338 people, so the test people's BMI helped choose the cut points. That is a leak: information from rows you score on found its way into training. Then there is the last question of the day: the planner and the pricing team will look at these numbers in Power BI, not in BigQuery. Power BI reads tables, so the predictions have to be saved as tables.

## What you will learn

- To measure a preprocessing leak: cut points from all rows against cut points from training rows.
- To put preprocessing inside the model with `TRANSFORM`, so the statistics come from training rows and are reused at prediction.
- To save `ML.FORECAST` and `ML.PREDICT` output with `CREATE OR REPLACE TABLE`, and to check that no table shares its name with one of its columns.

## Before you start

You need `ml.insurance_groups` (D14 activity 01; check: `SELECT COUNT(*) FROM ml.insurance_groups;` returns 1,338), `ml.air_arima_final` (activity 06, step 1) and `ml.air_test` (activity 03, step 1). If any is missing, run [`Resources/restart_d15.sql`](../Resources/restart_d15.sql); it needs `ml.air_passengers` and `ml.insurance` uploaded.

Every model here is built-in (linear and ARIMA_PLUS), so this activity runs in a sandbox. The sandbox does not run `INSERT` or `UPDATE`, which is why the tables are written with `CREATE OR REPLACE TABLE … AS SELECT`.

## Step 1 · The leak, and TRANSFORM

First the leak, in numbers. `PERCENTILE_CONT(bmi, 0.25) OVER ()` is the BMI a quarter of the way up; 0.5 and 0.75 give the other two cut points.

```sql
SELECT DISTINCT 'all 1,338 people' AS rows_used,
       ROUND(PERCENTILE_CONT(bmi, 0.25) OVER (), 2) AS cut_1,
       ROUND(PERCENTILE_CONT(bmi, 0.5) OVER (), 2) AS cut_2,
       ROUND(PERCENTILE_CONT(bmi, 0.75) OVER (), 2) AS cut_3
FROM ml.insurance_groups
UNION ALL
SELECT DISTINCT 'the 803 training people',
       ROUND(PERCENTILE_CONT(bmi, 0.25) OVER (), 2),
       ROUND(PERCENTILE_CONT(bmi, 0.5) OVER (), 2),
       ROUND(PERCENTILE_CONT(bmi, 0.75) OVER (), 2)
FROM ml.insurance_groups
WHERE split = 'train';
```

**What you should see:** two rows. All rows: 26.3, 30.4, 34.69. Training rows only: 26.27, 30.25, 34.36.

How many people land in a different band? A person's band is 1 plus the number of cut points at or below their BMI.

```sql
WITH cuts_all AS (
  SELECT DISTINCT PERCENTILE_CONT(bmi, 0.25) OVER () AS c1,
         PERCENTILE_CONT(bmi, 0.5) OVER () AS c2,
         PERCENTILE_CONT(bmi, 0.75) OVER () AS c3
  FROM ml.insurance_groups
),
cuts_train AS (
  SELECT DISTINCT PERCENTILE_CONT(bmi, 0.25) OVER () AS c1,
         PERCENTILE_CONT(bmi, 0.5) OVER () AS c2,
         PERCENTILE_CONT(bmi, 0.75) OVER () AS c3
  FROM ml.insurance_groups
  WHERE split = 'train'
)
SELECT g.split,
       COUNTIF(IF(g.bmi >= a.c1, 1, 0) + IF(g.bmi >= a.c2, 1, 0) + IF(g.bmi >= a.c3, 1, 0)
            != IF(g.bmi >= t.c1, 1, 0) + IF(g.bmi >= t.c2, 1, 0) + IF(g.bmi >= t.c3, 1, 0)) AS people_changing_band
FROM ml.insurance_groups AS g
CROSS JOIN cuts_all AS a
CROSS JOIN cuts_train AS t
GROUP BY g.split
ORDER BY g.split;
```

**What you should see:** test 7, train 15, validation 5. Small here; on other data it can be large. The habit matters: anything computed from rows (cut points, averages, scales) must come from the training rows only.

`TRANSFORM` puts that preprocessing inside the model:

```sql
CREATE OR REPLACE MODEL ml.ins_transform
TRANSFORM (ML.QUANTILE_BUCKETIZE(bmi, 4) OVER () AS bmi_band,
           age, sex, children, smoker, region, charges)
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['charges'],
         data_split_method = 'NO_SPLIT') AS
SELECT age, sex, bmi, children, smoker, region, charges
FROM ml.insurance_groups
WHERE split = 'train';
```

Read it from the bottom: the `SELECT` gives the model the 803 training people. `TRANSFORM` then computes the four BMI bands from those rows and trains on `bmi_band` in place of `bmi`. Google's guide: "When you use ML analytic functions inside the TRANSFORM clause during training, the same statistics are automatically applied to the input in prediction." At prediction you pass the raw `bmi`, and the model applies the training cut points itself; nobody has to remember them. `ML.QUANTILE_BUCKETIZE` takes the column and the number of buckets, and needs an empty `OVER ()`.

**What you should see:** the model trains. BigQuery computes its own quantiles, so its cut points can differ a little from the ones above.

## Step 2 · Save the forecast

```sql
CREATE OR REPLACE TABLE ml.air_forecast AS
SELECT DATE(f.forecast_timestamp) AS month,
       ROUND(f.forecast_value, 1) AS forecast_passengers,
       ROUND(f.prediction_interval_lower_bound, 1) AS lower_95,
       ROUND(f.prediction_interval_upper_bound, 1) AS upper_95,
       te.passengers AS actual_passengers
FROM ML.FORECAST(MODEL ml.air_arima_final,
                 STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
LEFT JOIN ml.air_test AS te ON te.month = DATE(f.forecast_timestamp);
```

`DATE(...)` turns the forecast's TIMESTAMP back into a month, so a report can line it up with the history. The `LEFT JOIN` puts the real 1960 value beside each forecast month. With real future months there would be no actual yet, and the column would be empty.

**What you should see:** the table `air_forecast` under `ml`, 12 rows, one per month of 1960.

## Step 3 · Save the scored people

```sql
CREATE OR REPLACE TABLE ml.insurance_scored AS
SELECT age, sex, bmi, children, smoker, region, charges, split,
       ROUND(predicted_charges, 2) AS predicted_charges
FROM ML.PREDICT(MODEL ml.ins_transform,
  (SELECT * FROM ml.insurance_groups));
```

`ML.PREDICT` passes columns the model does not use, such as `split`, through to its output (Google's page: "If there are unused columns from the query, they are passed through as output columns"), so the report can filter on the test people. You pass the raw `bmi`; `TRANSFORM` turns it into a band with the training cut points.

**What you should see:** the table `insurance_scored` under `ml`, 1,338 rows, one per person.

## Step 4 · Check the names

A table may not share its name with one of its columns: in BigQuery a table name can also stand for a whole row, so a table `month` with a column `month` invites mistakes, in SQL and in Power BI.

```sql
SELECT table_name, column_name
FROM ml.INFORMATION_SCHEMA.COLUMNS
WHERE table_name IN ('air_forecast', 'insurance_scored')
  AND LOWER(table_name) = LOWER(column_name);
```

`INFORMATION_SCHEMA.COLUMNS` lists every column of every table in the dataset.

**What you should see:** no rows. On D22 Power BI connects to `ml.air_forecast` and `ml.insurance_scored`.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 and 3 | all rows **26.3**, **30.4**, **34.69** · training rows **26.27**, **30.25**, **34.36** · bands changing: train **15**, validation **5**, test **7** |
| 4 | 0 | no table shares a name with one of its columns |

Steps 2 and 3 write 12 and 1,338 rows; check with `SELECT COUNT(*) FROM ml.air_forecast;` and the same for `ml.insurance_scored`.

## If something goes wrong

- **`Not found: Model ml.air_arima_final`:** run activity 06, step 1, or `Resources/restart_d15.sql`.
- **`ML.QUANTILE_BUCKETIZE` complains about the window:** the `OVER ()` must be empty and must follow the function directly.
- **Step 3 fails with a missing column:** `ML.PREDICT` needs every column the `TRANSFORM` clause uses: `age`, `sex`, `bmi`, `children`, `smoker`, `region`.

## Hint

`TRANSFORM` sits between the model name and `OPTIONS`. Everything in it is computed during training, from the rows the `SELECT` returns.

## Bonus

Score `ml.ins_transform` on the validation people with `ML.EVALUATE(MODEL ml.ins_transform, (SELECT * FROM ml.insurance_groups WHERE split = 'validation'))`. [Lab 12](../12-Lab-Transform-Functions/README.md) trains the same model with D14's leaky bands and compares the two.

## References

Medical Cost Personal Datasets (Kaggle, `mirichoi0218/insurance`), from Brett Lantz, *Machine Learning with R* (Packt, 2013); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. Air Passengers: Box, Jenkins and Reinsel, *Time Series Analysis, Forecasting and Control* (1976), Series G, as listed on the [R datasets page](https://rweb.stat.umn.edu/R/library/datasets/html/AirPassengers.html); course copy taken 19 October 2026. BigQuery ML: [the TRANSFORM clause](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create#transform), [ML.QUANTILE_BUCKETIZE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-quantile-bucketize), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), [manual preprocessing](https://docs.cloud.google.com/bigquery/docs/manual-preprocessing), Google Cloud.
