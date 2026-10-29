# The test year, once

In this activity, you will retrain the chosen model on every month before 1960, forecast 1960, and score it once against the same-month-last-year forecast.

**Time:** about 8 minutes in class, following along · **Data:** `ml.air_passengers` (activity 01), `ml.air_validation` and `ml.air_test` (activity 03) → the model `ml.air_arima_final` · **Starter:** `Unsolved/test_year_once.sql`

## The story

You chose ARIMA_PLUS on 1959 and wrote down why. The planner now asks the last question: how far off will it be on a year nobody has looked at? That is the test year, 1960, and it is used once. If you changed the model after seeing 1960 and ran it again, 1960 would become a second validation year and stop being an honest preview of the future.

## What you will learn

- To retrain on training and validation months together once the choice is made, and why.
- To score the test year once, against the bar that a planner at the end of 1959 would have had.
- To compare the test score with the validation score.

## Before you start

You need `ml.air_passengers` (activity 01) and the views `ml.air_validation` and `ml.air_test` (activity 03, step 1). Check: `SELECT COUNT(*) FROM ml.air_test;` returns 12. If a view is missing, run activity 03's step 1 or [`Resources/restart_d15.sql`](../Resources/restart_d15.sql). Do this activity only after the three sentences of activity 05 are written.

## Step 1 · Retrain on every month before the test

```sql
CREATE OR REPLACE MODEL ml.air_arima_final
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12) AS
SELECT month, passengers FROM ml.air_passengers
WHERE month < '1960-01-01';
```

The same options as `ml.air_arima`; only the cutoff moves, from 1959-01-01 to 1960-01-01, so the model learns from 132 months instead of 120. The choice was made on validation; now validation's twelve months are the most recent history the model can have, and a forecast of 1960 without them would be a year out of date.

## Step 2 · Forecast 1960 and score it, once

```sql
SELECT ROUND(AVG(ABS(te.passengers - f.forecast_value)), 1) AS mae_arima,
       ROUND(100 * AVG(ABS(te.passengers - f.forecast_value) / te.passengers), 1) AS mape_arima_pct,
       ROUND(AVG(ABS(te.passengers - v.passengers)), 1) AS mae_seasonal_naive,
       COUNTIF(te.passengers BETWEEN f.prediction_interval_lower_bound
                                 AND f.prediction_interval_upper_bound) AS months_inside
FROM ML.FORECAST(MODEL ml.air_arima_final,
                 STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.air_test AS te ON DATE(f.forecast_timestamp) = te.month
JOIN ml.air_validation AS v ON v.month = DATE_SUB(te.month, INTERVAL 1 YEAR);
```

Run it once.

**What you should see:** one row. `mae_seasonal_naive` is 47.8: each month of 1960 compared with the same month of 1959. Computed outside BigQuery with a similar method, the model's 1960 MAE was about 18 (MAPE about 3.8%), with about 7 of the 12 months inside the 95% interval; BigQuery's values will differ a little.

**Think:** the model beat the seasonal naive on 1959 and again on 1960, by a similar margin. What does that agreement tell the planner that the 1959 score alone did not?

## Step 3 · The bar for 1960, in full

Still part of the one look at 1960: the two simple forecasts a planner would have had at the end of 1959. The naive forecast holds December 1959 flat; the seasonal naive uses each month of 1959.

```sql
SELECT 'seasonal naive: same month of 1959' AS forecast_method,
       ROUND(AVG(ABS(te.passengers - v.passengers)), 1) AS mae,
       ROUND(100 * AVG(ABS(te.passengers - v.passengers) / te.passengers), 1) AS mape_pct
FROM ml.air_test AS te
JOIN ml.air_validation AS v ON v.month = DATE_SUB(te.month, INTERVAL 1 YEAR)
UNION ALL
SELECT 'naive: December 1959 held flat',
       ROUND(AVG(ABS(te.passengers - (SELECT passengers FROM ml.air_validation ORDER BY month DESC LIMIT 1))), 1),
       ROUND(100 * AVG(ABS(te.passengers - (SELECT passengers FROM ml.air_validation ORDER BY month DESC LIMIT 1)) / te.passengers), 1)
FROM ml.air_test AS te
ORDER BY mae;
```

**What you should see:** seasonal naive 47.8 (MAPE 10.0%), naive 76.0 (14.3%). Both forecasts are built from months before 1960; only their scores read the test months.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 3 | 2 | seasonal naive **47.8** (MAPE **10.0**) · naive **76.0** (MAPE **14.3**) |

Step 2 depends on the model BigQuery chose; its `mae_seasonal_naive` column must equal step 3's 47.8.

## If something goes wrong

- **You ran step 2 before choosing:** note it. A test score that has influenced a choice is no longer a preview of new data.
- **Step 2 returns no rows:** `ml.air_test` is empty or the model is `ml.air_arima` (which forecasts 1959, not 1960). Check the model name.
- **Your step 3 values differ:** check that `ml.air_test` starts at 1960-01-01 and `ml.air_validation` stops before it.

## Hint

The test months join the forecast on `DATE(f.forecast_timestamp) = te.month` and join 1959 on `v.month = DATE_SUB(te.month, INTERVAL 1 YEAR)`, the same one-year shift as activity 03.

## Bonus

The seasonal naive built only from training months (each 1960 month compared with the same month of 1958) misses 1960 by 95.2. Why is it fair to give the seasonal naive 1959's months here, when the model also saw them?

## References

Air Passengers: Box, Jenkins and Reinsel, *Time Series Analysis, Forecasting and Control* (1976), Series G, as listed on the [R datasets page](https://rweb.stat.umn.edu/R/library/datasets/html/AirPassengers.html); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 19 October 2026. BigQuery ML: [CREATE MODEL for ARIMA_PLUS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series), [ML.FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast), Google Cloud.
