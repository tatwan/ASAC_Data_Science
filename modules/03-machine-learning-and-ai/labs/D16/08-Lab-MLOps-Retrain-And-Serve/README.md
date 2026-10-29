# Lab 08 · Retrain on every year, then choose how to serve the forecast

In this self-guided lab, you will retrain the births forecast on all fifteen years so that it forecasts 2015, swap it in behind the class view without changing the view's columns, save the same forecast as a table, and compare the two ways of serving it.

**When:** after class, at your own pace. Not submitted. · **Data:** `ml.us_births`, `ml.births_arima` and `ml.v_births_history_forecast` (activity 04) → `ml.births_arima_v2`, `ml.births_forecast_2015` · **SQL:** `Unsolved/mlops_retrain_and_serve.sql` to run step by step, `Solved/mlops_retrain_and_serve.sql`

## The story

In class, `ml.births_arima` learned from 2000 to 2013 and forecast 2014, a year whose real numbers are in the table. That was the point: you could score it. But a hospital planning next year's staff has no use for a forecast of last year. Once the score says the settings work, the model is trained again on every day you have, and its forecast starts the day after the data ends.

Then a second decision: the forecast reaches Power BI through a view in class. A view runs its query again on every read; a table stores the rows once. Which one should the report read? Each has a cost, and this lab puts them side by side.

## What you will learn

- Why the last step before serving a forecast is to retrain on all the data, with the settings you already scored.
- To swap a new model in behind a view, keeping its columns, so the report needs no change.
- What a view and a table each cost, and how fresh each stays, for a forecast in particular.
- What companies add on top (scheduled retraining, a model registry, online endpoints, export), and why each needs more than a sandbox.

## Before you start

You need `ml.us_births`, the model `ml.births_arima` and the view `ml.v_births_history_forecast`, all from [activity 04](../04-Evr-Births-Forecast/README.md). Check: `SELECT COUNT(*) FROM ml.us_births;` returns 5,479. If the table is missing, copy or upload it as [activity 01](../01-Evr-Diamond-Prices/README.md)'s "Before you start" shows; if the model or the view is missing, run activity 04's steps 2 and 5, or [`Resources/restart_d16.sql`](../Resources/restart_d16.sql).

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. ARIMA_PLUS is a built-in model and trains in a sandbox in a minute or two. The forecast values have not been computed outside BigQuery, so the steps tell you what to look for; the counts and dates are exact.

## Checkpoints

- **C1:** `ml.births_arima_v2` trained on all 5,479 days, and its forecast for the 365 days of 2015 (steps 2 and 3).
- **C2:** the view `ml.v_births_history_forecast` swapped to the new model, with the same columns, and counted: 5,479 actual days and 365 forecast days (step 4).
- **C3:** the forecast saved as a table too, and two sentences on when you would serve the table and when the view (step 5).

## Step 1 · What the class model forecasts

```sql
SELECT COUNT(*) AS forecast_days,
       MIN(DATE(forecast_timestamp)) AS first_day,
       MAX(DATE(forecast_timestamp)) AS last_day
FROM ML.FORECAST(MODEL ml.births_arima,
       STRUCT(365 AS horizon, 0.95 AS confidence_level));

SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift,
       seasonal_periods, has_holiday_effect
FROM ML.ARIMA_EVALUATE(MODEL ml.births_arima, STRUCT(FALSE AS show_all_candidate_models));
```

The first query shows where the class model's forecast sits in time. The second, `ML.ARIMA_EVALUATE` (D15 lab 09), shows what the model chose: the ARIMA order (p, d, q), whether it found seasons, and whether it modelled holidays.

**What you should see:** 365 days, from 2014-01-01 to 2014-12-31: a year that is already in the table. Then one row; write down the order and `seasonal_periods`. Expect `has_holiday_effect` TRUE, because the model was trained with `holiday_region = 'US'` on a daily series longer than a year.

## Step 2 · Retrain on all fifteen years (C1, part 1)

```sql
CREATE OR REPLACE MODEL ml.births_arima_v2
OPTIONS (model_type = 'ARIMA_PLUS',
         time_series_timestamp_col = 'birth_date',
         time_series_data_col = 'births',
         horizon = 365,
         holiday_region = 'US') AS
SELECT birth_date, births
FROM ml.us_births
WHERE birth_date <= '2014-12-31';

SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift,
       seasonal_periods, has_holiday_effect
FROM ML.ARIMA_EVALUATE(MODEL ml.births_arima_v2, STRUCT(FALSE AS show_all_candidate_models));
```

The options are the class model's, unchanged: the 2014 score in activity 04 was the evidence that these settings work, and changing them now would mean scoring again. Only the rows change. The `WHERE` line keeps every day, and it is written out so that anyone reading the SQL sees where the training data ends. D15 did the same with `ml.air_arima_final`.

There is no test year left for this model: every known day is in training. That is normal for the model you serve. Its honest score is the class model's score on 2014, and the real check comes when 2015's numbers arrive.

**What you should see:** the model `births_arima_v2` under `ml`, then one row. The order may be the same as the class model's or differ by one step; with one more year of data, the search can choose differently.

## Step 3 · The 2015 forecast (C1, part 2)

```sql
SELECT COUNT(*) AS forecast_days,
       MIN(DATE(forecast_timestamp)) AS first_day,
       MAX(DATE(forecast_timestamp)) AS last_day,
       ROUND(AVG(forecast_value)) AS average_forecast
FROM ML.FORECAST(MODEL ml.births_arima_v2,
       STRUCT(365 AS horizon, 0.95 AS confidence_level));

SELECT DATE(forecast_timestamp) AS day,
       FORMAT_DATE('%A', DATE(forecast_timestamp)) AS weekday,
       ROUND(forecast_value) AS forecast,
       ROUND(prediction_interval_lower_bound) AS lower_95,
       ROUND(prediction_interval_upper_bound) AS upper_95
FROM ML.FORECAST(MODEL ml.births_arima_v2,
       STRUCT(365 AS horizon, 0.95 AS confidence_level))
WHERE DATE(forecast_timestamp) IN ('2015-01-01', '2015-07-04', '2015-11-26', '2015-12-25')
ORDER BY day;
```

`FORMAT_DATE('%A', …)` writes the weekday's name. The four days are New Year's Day, Independence Day, Thanksgiving and Christmas Day of 2015.

**What you should see:** 365 days, from 2015-01-01 to 2015-12-31. The average should be close to 2014's real daily average of 10,987.8. Then 4 rows: Thursday, Saturday, Thursday and Friday. For comparison, the real 2014 numbers were 8,018 on New Year's Day, 9,278 on 4 July, 7,351 on Thanksgiving and 6,749 on Christmas Day, against a weekday average of 11,898 (Monday) to 13,122 (Tuesday) across the fifteen years. A forecast that dips on these days has learned the holidays; 4 July 2015 falls on a Saturday, a low day anyway.

**C1:** the first query's row, and the forecast for Christmas Day 2015 with its interval.

## Step 4 · Swap the model behind the view (C2)

First, the view as the class left it:

```sql
SELECT ordinal_position, column_name, data_type
FROM ml.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'v_births_history_forecast'
ORDER BY ordinal_position;

SELECT series, COUNT(*) AS days, MIN(day) AS first_day, MAX(day) AS last_day
FROM ml.v_births_history_forecast
GROUP BY series
ORDER BY series;
```

Then the swap. The statement is activity 04's, with one change: the model name.

```sql
CREATE OR REPLACE VIEW ml.v_births_history_forecast AS
SELECT birth_date AS day, 'actual' AS series,
       CAST(births AS FLOAT64) AS births,
       CAST(NULL AS FLOAT64) AS lower_95,
       CAST(NULL AS FLOAT64) AS upper_95
FROM ml.us_births
UNION ALL
SELECT DATE(forecast_timestamp), 'forecast',
       ROUND(forecast_value),
       ROUND(prediction_interval_lower_bound),
       ROUND(prediction_interval_upper_bound)
FROM ML.FORECAST(MODEL ml.births_arima_v2,
       STRUCT(365 AS horizon, 0.95 AS confidence_level));
```

Now run the two queries from the start of this step again.

The view keeps its name and its five columns, `day`, `series`, `births`, `lower_95` and `upper_95`, with the same types. A Power BI line chart built on it in class keeps working; at its next refresh, the forecast line moves from lying over 2014 to continuing after it. Lab 06 did the same for the diamond prices.

Google's pages do not say whether a view may call `ML.FORECAST`. If `CREATE OR REPLACE VIEW` gives an error, run the same `SELECT` with `CREATE OR REPLACE TABLE ml.v_births_history_forecast AS` instead; step 5 explains what you give up.

**What you should see:** before the swap, 5 columns and 2 rows: `actual` 5,479 days from 2000-01-01 to 2014-12-31, `forecast` 365 days from 2014-01-01 to 2014-12-31. After it, the same 5 columns with the same types, and `actual` 5,479 days as before, `forecast` 365 days from 2015-01-01 to 2015-12-31: 5,844 rows in all, with no day in both halves.

**C2:** the two `series` results, before and after.

## Step 5 · The same forecast as a table, and which one to serve (C3)

```sql
CREATE OR REPLACE TABLE ml.births_forecast_2015 AS
SELECT DATE(forecast_timestamp) AS day,
       ROUND(forecast_value) AS births,
       ROUND(prediction_interval_lower_bound) AS lower_95,
       ROUND(prediction_interval_upper_bound) AS upper_95
FROM ML.FORECAST(MODEL ml.births_arima_v2,
       STRUCT(365 AS horizon, 0.95 AS confidence_level));

SELECT COUNT(*) AS forecast_days FROM ml.births_forecast_2015;
SELECT COUNT(*) AS forecast_days FROM ml.v_births_history_forecast WHERE series = 'forecast';
```

Run the two counts one at a time and open **Job information** under each result: it shows the bytes the query processed. The table's count reads stored rows; the view's count runs the view's whole query, history and `ML.FORECAST` included.

What each one costs and how fresh it stays:

| | View `ml.v_births_history_forecast` | Table `ml.births_forecast_2015` |
|---|---|---|
| What is stored | the query | 365 rows |
| What a read does | runs the query again: Google's page, "the query that defines the view is run each time the view is queried" | reads the stored rows |
| When the model is retrained under the same name | the next read shows the new forecast | still holds the old forecast until you run `CREATE OR REPLACE TABLE` again |
| When `ml.us_births` gains rows | the history half shows them at the next read | not affected (it holds no history) |
| Cost per read | the view's query, each time a report refreshes | the stored rows only |

For a forecast, one fact narrows the gap. Google's `ML.FORECAST` page: "Forecasting takes place when the CREATE MODEL statement runs. ML.FORECAST just retrieves the forecasting values and computes the prediction intervals." So the view does not forecast again on every read; it fetches the same 365 values each time, until the model is retrained. The view is "fresh" only in the sense that it follows the model. The same page warns that more computation on top of `ML.FORECAST` "might lead to an out of memory error if the model size is too large", and suggests "creating a new table for the ML.FORECAST result" as the workaround: on a big model, the table is the safer choice.

One more fact applies to both in the sandbox. Google's sandbox page: "all tables, views, and partitions automatically expire after 60 days." A report that reads either one stops working about two months after you create it, unless you run its `CREATE` statement again. A company project with billing sets its own expiry or none.

**What you should see:** the table `births_forecast_2015` under `ml`, then 365 and 365. Write the bytes processed by each count in **What you saw**.

**C3:** two sentences: when would you point the report at the view, and when at the table?

## What a company adds (read only)

Nothing in this section runs in the sandbox. It shows what the steps above grow into when a team has a billed project.

**Retraining on a schedule.** Step 2, run every month as a scheduled query, so the forecast always starts after the newest data. Lab 07, step 9, has the details: scheduled queries "use features of BigQuery Data Transfer Service", which the sandbox does not support and which, Google says, needs billing "in most cases".

**A model registry.** Three `CREATE MODEL` options send a model to the Model Registry of Google's Agent Platform. Google's BigQuery pages now call Vertex AI "Gemini Enterprise Agent Platform"; the option names still say `VERTEX_AI`. For example:

```
CREATE OR REPLACE MODEL ml.births_arima_v2
OPTIONS (model_type = 'ARIMA_PLUS',
         time_series_timestamp_col = 'birth_date',
         time_series_data_col = 'births',
         horizon = 365,
         holiday_region = 'US',
         MODEL_REGISTRY = 'VERTEX_AI',
         VERTEX_AI_MODEL_ID = 'us_births_forecast',
         VERTEX_AI_MODEL_VERSION_ALIASES = ['production']) AS
SELECT birth_date, births FROM ml.us_births;
```

- `MODEL_REGISTRY = 'VERTEX_AI'` registers the model; "VERTEX_AI is the only supported model registry destination."
- `VERTEX_AI_MODEL_ID` is the registry's name for the model. "The first BigQuery ML model that you register under a given model ID displays as version 1 of that model in the Model Registry." A second BigQuery model registered with the same ID becomes version 2. This is the version history that lab 06 kept by hand in `ml.model_log`.
- `VERTEX_AI_MODEL_VERSION_ALIASES` gives a version names such as `production`: "Model aliases are helpful for fetching or deploying a particular model version by reference without needing to know the specific version ID." Lab 06 used a model label for the same job.

Google's page asks you to "Enable the Agent Platform API" and to hold the "Agent Platform Administrator (roles/aiplatform.admin)" role. It does not say whether registration works without billing, and this course does not try it in the sandbox.

**Online prediction.** Google's inference overview says BigQuery ML is built for batch prediction, many rows in one query, which is what every view and table in this course does. For faster answers one request at a time (online prediction), a registered model is deployed to an Agent Platform endpoint. Google's export tutorial asks you to verify that billing is enabled before you begin, and the registry page says ARIMA_PLUS models "can be registered in Model Registry, but they can't be deployed".

**Exporting a model.** `EXPORT MODEL ml.some_model OPTIONS (URI = 'gs://…')` writes a model to a Cloud Storage bucket, so another system can load it. Google's page lists the model types that can be exported; ARIMA_PLUS is not among them. "There is no charge for exporting BigQuery ML models", but "After the data is exported, you are charged for storing the data in Cloud Storage", so a bucket needs a billed project.

## What you saw

| Question | Your answer |
|---|---|
| The class model's ARIMA order, and v2's | |
| v2's forecast for Christmas Day 2015, and its interval | |
| Bytes processed: counting the table | |
| Bytes processed: counting the view's forecast rows | |
| View or table for the hospital's report, and why | |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 1, 1 | **365** days, **2014-01-01** to **2014-12-31** |
| 3 | 1, 4 | **365** days, **2015-01-01** to **2015-12-31** · Thursday, Saturday, Thursday, Friday |
| 4 | 5 columns, 2 rows | `actual` **5,479** days to **2014-12-31** · `forecast` **365** days from **2015-01-01** |
| 5 | 1, 1 | **365** and **365** |

## Hint

If step 4's view fails with a type error in `UNION ALL`, compare the two halves line by line: the history half must cast `births` and both bounds to FLOAT64, because `ML.FORECAST` returns FLOAT64 and `ROUND` keeps it.

## Bonus

- Ask v2 for 30 days with an 80% interval, `STRUCT(30 AS horizon, 0.8 AS confidence_level)`, and compare the interval's width on 1 January with step 3's. Can you ask it for 400 days? Why not? (D15 lab 09, step 5.)
- Add a third part to the view's query: the class model's 2014 forecast from `ml.births_arima`, labelled `'class forecast'`, so a chart can show how far it was from the real 2014. Would you put that in the hospital's report, or keep it for yourself?

## References

US births 2000–2014 from the Social Security Administration, published by FiveThirtyEight for "Some People Are Too Superstitious To Have A Baby On Friday The 13th" ([`fivethirtyeight/data`](https://github.com/fivethirtyeight/data/tree/master/births)), CC BY 4.0; course copy in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md), taken 27 October 2026. BigQuery ML: [CREATE MODEL for ARIMA_PLUS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series), [ML.FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast), [ML.ARIMA_EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-evaluate), [Introduction to logical views](https://docs.cloud.google.com/bigquery/docs/views-intro), [Try BigQuery using the sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox), [CREATE MODEL options](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create) (`MODEL_REGISTRY`, `VERTEX_AI_MODEL_ID`, `VERTEX_AI_MODEL_VERSION_ALIASES`), [Manage BigQuery ML models in Gemini Enterprise Agent Platform](https://docs.cloud.google.com/bigquery/docs/managing-models-vertex), [Model inference overview](https://docs.cloud.google.com/bigquery/docs/inference-overview), [Export a model tutorial](https://docs.cloud.google.com/bigquery/docs/export-model-tutorial), [EXPORT MODEL](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-export-model), [Export models](https://docs.cloud.google.com/bigquery/docs/exporting-models), [Scheduling queries](https://docs.cloud.google.com/bigquery/docs/scheduling-queries), Google Cloud. Pages read 27 October 2026.
