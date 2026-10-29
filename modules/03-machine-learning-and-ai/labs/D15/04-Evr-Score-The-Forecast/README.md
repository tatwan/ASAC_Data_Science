# Score the forecast on 1959

In this activity, you will put ARIMA_PLUS's forecast beside the twelve real months of 1959, score it with MAE and MAPE against the simple forecasts from activity 03, count the months its interval caught, and look for training months that the model found unusual.

**Time:** about 23 minutes in class, following along · **Data:** `ml.air_arima` and `ml.air_training` (activity 02), `ml.air_validation` (activity 03) · **Starter:** `Unsolved/score_the_forecast.sql`

## The story

The planner does not need a forecast that looks good; she needs one that would have been close. You have the real numbers for 1959 and a bar to clear: the seasonal naive forecast missed by 47.3 thousand passengers a month. Today's question is the D14 question in a new shape: on months the model never saw, does it beat the simple forecast, and by how much?

## What you will learn

- To join `ML.FORECAST` to the validation months on `DATE(forecast_timestamp)`.
- To compute MAE and MAPE for the model in the same units as the baselines, and to read the result as a planner would.
- To read the prediction interval: how many months fell inside it, and why it widens.
- To use `ML.EXPLAIN_FORECAST` to see the parts of each training month and find the unusual ones.

## Before you start

You need `ml.air_arima` and `ml.air_training` from [activity 02](../02-Evr-First-Forecast/README.md) and `ml.air_validation` from [activity 03](../03-Stu-Split-By-Date/README.md), step 1. Check: `SELECT COUNT(*) FROM ml.air_validation;` returns 12. If anything is missing, run [`Resources/restart_d15.sql`](../Resources/restart_d15.sql) (it needs `ml.air_passengers` uploaded).

## Step 1 · The forecast beside the real months

Ask first: one row is one ___? A validation month. How many rows will the join return?

```sql
SELECT DATE(f.forecast_timestamp) AS month_forecast, v.passengers,
       ROUND(f.forecast_value, 1) AS forecast_passengers,
       ROUND(v.passengers - f.forecast_value, 1) AS miss
FROM ML.FORECAST(MODEL ml.air_arima,
                 STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.air_validation AS v
  ON DATE(f.forecast_timestamp) = v.month
ORDER BY month_forecast;
```

`forecast_timestamp` is a TIMESTAMP and `month` is a DATE, so the join compares `DATE(f.forecast_timestamp)` with `v.month`. Miss = actual − forecast, as on D14: a positive miss means the forecast was too low.

**What you should see:** 12 rows. Computed outside BigQuery with a similar method, most misses were positive and the largest came in the summer: the forecast was low when the peak was high.

## Step 2 · The score, and the bar

```sql
SELECT ROUND(AVG(ABS(v.passengers - f.forecast_value)), 1) AS mae,
       ROUND(100 * AVG(ABS(v.passengers - f.forecast_value) / v.passengers), 1) AS mape_pct
FROM ML.FORECAST(MODEL ml.air_arima,
                 STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.air_validation AS v
  ON DATE(f.forecast_timestamp) = v.month;
```

The same MAE and MAPE as activity 03, now for the model. Then the four simple forecasts in one table, so you can rank the model among them:

```sql
SELECT 'naive: December 1958 held flat' AS forecast_method,
       ROUND(AVG(ABS(v.passengers - (SELECT passengers FROM ml.air_training ORDER BY month DESC LIMIT 1))), 1) AS mae,
       ROUND(100 * AVG(ABS(v.passengers - (SELECT passengers FROM ml.air_training ORDER BY month DESC LIMIT 1)) / v.passengers), 1) AS mape_pct
FROM ml.air_validation AS v
UNION ALL
SELECT 'seasonal naive: same month of 1958',
       ROUND(AVG(ABS(v.passengers - t.passengers)), 1),
       ROUND(100 * AVG(ABS(v.passengers - t.passengers) / v.passengers), 1)
FROM ml.air_validation AS v
JOIN ml.air_training AS t ON t.month = DATE_SUB(v.month, INTERVAL 1 YEAR)
UNION ALL
SELECT 'training mean held flat',
       ROUND(AVG(ABS(v.passengers - (SELECT AVG(passengers) FROM ml.air_training))), 1),
       ROUND(100 * AVG(ABS(v.passengers - (SELECT AVG(passengers) FROM ml.air_training)) / v.passengers), 1)
FROM ml.air_validation AS v
UNION ALL
SELECT 'training median held flat',
       ROUND(AVG(ABS(v.passengers - (SELECT DISTINCT PERCENTILE_CONT(passengers, 0.5) OVER () FROM ml.air_training))), 1),
       ROUND(100 * AVG(ABS(v.passengers - (SELECT DISTINCT PERCENTILE_CONT(passengers, 0.5) OVER () FROM ml.air_training)) / v.passengers), 1)
FROM ml.air_validation AS v
ORDER BY mae;
```

**What you should see:** the model's MAE first. Computed outside BigQuery with a similar method, it was about 27 (MAPE about 6.2%); BigQuery's own value will differ a little. The simple forecasts are exact: seasonal naive 47.3, naive 91.3, training mean 182.4, training median 194.8.

Read it as the planner would: the model missed a typical month of 1959 by roughly 27 thousand passengers, about 6% of the month's traffic, where "same month last year" missed by 47 thousand.

## Step 3 · Reading the interval

```sql
SELECT COUNTIF(v.passengers BETWEEN f.prediction_interval_lower_bound
                                AND f.prediction_interval_upper_bound) AS months_inside
FROM ML.FORECAST(MODEL ml.air_arima,
                 STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.air_validation AS v
  ON DATE(f.forecast_timestamp) = v.month;
```

The 95% prediction interval is the range the model gives for each month's real value at that level. `forecast_value` is its middle (Google's page: the average of the lower and upper bounds). The interval widens month by month: the further ahead, the more uncertainty stacks up.

**What you should see:** one number out of 12. Computed outside BigQuery, a similar interval held only about 4 of the 12 months; BigQuery's interval may hold more. If many months fall outside, the interval is too narrow for this year: the summer peaks were bigger than the model allowed for. A planner staffs to the upper bound (running short costs more than a few empty seats) and budgets on the forecast itself.

## Step 4 · Months that look unusual

```sql
SELECT DATE(time_series_timestamp) AS month_history, time_series_data,
       ROUND(trend, 1) AS trend, ROUND(seasonal_period_yearly, 1) AS season,
       spikes_and_dips, ROUND(residual, 1) AS residual
FROM ML.EXPLAIN_FORECAST(MODEL ml.air_arima,
                         STRUCT(12 AS horizon, 0.95 AS confidence_level))
WHERE time_series_type = 'history'
ORDER BY ABS(IFNULL(spikes_and_dips, 0) + IFNULL(residual, 0)) DESC
LIMIT 5;
```

`ML.EXPLAIN_FORECAST` returns every training month (`time_series_type = 'history'`) and the forecast months (`'forecast'`), each split into parts:

| Column | Read it as |
|---|---|
| `time_series_data` | the month's value |
| `trend` | the long climb |
| `seasonal_period_yearly` | that month's share of the yearly pattern |
| `spikes_and_dips` | a one-off spike or dip that ARIMA_PLUS cleaned out (`CLEAN_SPIKES_AND_DIPS` is TRUE by default); NULL when there was none |
| `residual` | what trend and season do not explain |

The months with the largest unexplained part are the unusual ones.

**What you should see:** five training months. Computed outside BigQuery, the three most unusual were April 1953 (about 26 thousand above its trend and season), February 1954 (about 20 below) and May 1953 (about 19 above). BigQuery's decomposition is its own; read the months it returns.

**Think:** is April 1953 an error to delete? Not without a reason from the business, such as a strike, a new route or a data error. The model flags the month; a person decides what it means. Google also has a function made for this, `ML.DETECT_ANOMALIES`; [lab 10](../10-Lab-Forecast-Functions/README.md) runs it, because every query that uses it is billed.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 2 | 4 | the bar, exact: seasonal naive **47.3** (MAPE **11.1**) · naive **91.3** (**19.5**) · training mean **182.4** (**41.3**) · training median **194.8** (**44.2**) |

Steps 1, 3 and 4 depend on the model BigQuery chose: 12 rows in step 1, one count out of 12 in step 3, 5 rows in step 4.

## If something goes wrong

- **`No matching signature for operator =` on the join:** the `DATE(...)` around `f.forecast_timestamp` is missing.
- **The join returns 3 rows:** the `STRUCT` is missing `12 AS horizon`.
- **Your baselines differ from 47.3 and 91.3:** check that `ml.air_validation` stops before 1960-01-01 and that `ml.air_training` has 120 rows.
- **`ML.EXPLAIN_FORECAST` fails with a message about decomposition:** the model was trained with `DECOMPOSE_TIME_SERIES = FALSE`. Train `ml.air_arima` again as in activity 02.

## Hint

Every model query in this activity has the same shape: `ML.FORECAST(...) AS f JOIN ml.air_validation AS v ON DATE(f.forecast_timestamp) = v.month`. Only the `SELECT` list changes.

## Bonus

Add `ROUND(f.prediction_interval_upper_bound - f.prediction_interval_lower_bound, 1) AS interval_width` to step 1's query. How much wider is December's interval than January's?

## References

Air Passengers: Box, Jenkins and Reinsel, *Time Series Analysis, Forecasting and Control* (1976), Series G, as listed on the [R datasets page](https://rweb.stat.umn.edu/R/library/datasets/html/AirPassengers.html); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 19 October 2026. BigQuery ML: [ML.FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast), [ML.EXPLAIN_FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-forecast), Google Cloud.
