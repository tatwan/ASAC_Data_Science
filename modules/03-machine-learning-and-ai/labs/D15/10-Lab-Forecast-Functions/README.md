# Lab 10 · Every function that reads an ARIMA_PLUS model

In this self-guided lab, you will run each function that reads an ARIMA_PLUS model (`ML.FORECAST`, `ML.EXPLAIN_FORECAST`, `ML.DETECT_ANOMALIES`, `ML.ARIMA_EVALUATE`, `ML.ARIMA_COEFFICIENTS` and `ML.EVALUATE`), change each of its arguments, and read every column it returns. Then you will score forecasts with `ML.METRICS`, which needs no model at all.

**When:** after class, about 60 minutes, at your own pace. Not submitted. · **Data:** `ml.air_arima` and `ml.air_training` (activity 02), `ml.air_validation` (activity 03) · **SQL:** `Unsolved/forecast_functions.sql` to run step by step, `Solved/forecast_functions.sql`

## The story

In class you used two functions on `ml.air_arima`: `ML.FORECAST` for the numbers and `ML.EXPLAIN_FORECAST` for the unusual months. The planner's analyst will meet the others the first time something looks wrong: which order did the model choose, what are its coefficients, is this month's figure an anomaly, and does BigQuery's own score agree with yours? This lab answers each question with the function made for it.

## What you will learn

- Every argument of `ML.FORECAST` and `ML.EXPLAIN_FORECAST`, and every column they return.
- What `ML.DETECT_ANOMALIES` returns for the training months and for new months, what `anomaly_prob_threshold` changes, and why it is billed.
- To read the chosen model with `ML.ARIMA_EVALUATE` and `ML.ARIMA_COEFFICIENTS`.
- To score a forecast with `ML.EVALUATE` and with `ML.METRICS`, and check both against your own MAE.

## Before you start

You need `ml.air_arima` (activity 02, step 2), `ml.air_training` (activity 02, step 1) and `ml.air_validation` (activity 03, step 1). Check: `SELECT COUNT(*) FROM ml.air_validation;` returns 12. If anything is missing, run [`Resources/restart_d15.sql`](../Resources/restart_d15.sql).

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. Steps 7 to 9 use `ML.DETECT_ANOMALIES`, which is billed even in a sandbox (step 7 explains); if your project has no billing account, read those steps and their expected output without running them.

## Step 1 · ML.FORECAST with its defaults

```sql
SELECT *
FROM ML.FORECAST(MODEL ml.air_arima);
```

With no `STRUCT`, every argument takes its default: `horizon` 3 and `confidence_level` 0.95.

**What you should see:** 3 rows, January to March 1959, with eight columns: `forecast_timestamp`, `forecast_value`, `standard_error`, `confidence_level`, `prediction_interval_lower_bound`, `prediction_interval_upper_bound`, `confidence_interval_lower_bound`, `confidence_interval_upper_bound`, in time order. `confidence_level` is 0.95 on every row.

## Step 2 · horizon

```sql
SELECT DATE(forecast_timestamp) AS month_forecast, ROUND(forecast_value, 1) AS forecast_passengers,
       ROUND(standard_error, 2) AS standard_error
FROM ML.FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon));
```

`horizon` (INT64, default 3) is how many points to return, at most the `HORIZON` set in `CREATE MODEL` (12 for `ml.air_arima`), or 1,000 if that option was not set. Google's page: "Forecasting takes place when the CREATE MODEL statement runs. ML.FORECAST just retrieves the forecasting values and computes the prediction intervals."

**What you should see:** 12 rows, with `standard_error` growing every month: each month further ahead adds uncertainty. Change `12` to `13`: the query stops with an error.

## Step 3 · confidence_level

```sql
SELECT DATE(f80.forecast_timestamp) AS month_forecast,
       ROUND(f80.prediction_interval_upper_bound - f80.prediction_interval_lower_bound, 1) AS width_80,
       ROUND(f95.prediction_interval_upper_bound - f95.prediction_interval_lower_bound, 1) AS width_95,
       ROUND(f99.prediction_interval_upper_bound - f99.prediction_interval_lower_bound, 1) AS width_99
FROM ML.FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.8 AS confidence_level)) AS f80
JOIN ML.FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f95
  ON f80.forecast_timestamp = f95.forecast_timestamp
JOIN ML.FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.99 AS confidence_level)) AS f99
  ON f80.forecast_timestamp = f99.forecast_timestamp
ORDER BY month_forecast;
```

`confidence_level` (FLOAT64, default 0.95) sets the width of the intervals; the page gives its valid range as [0, 1): 0 is allowed, 1 is not.

**What you should see:** 12 rows; on every row the 80% interval is the narrowest and the 99% the widest. A higher level buys more certainty that the real value falls inside, at the price of a wider range.

## Step 4 · The other columns

```sql
SELECT DATE(forecast_timestamp) AS month_forecast,
       ROUND(forecast_value, 1) AS forecast_passengers,
       ROUND(forecast_value - (prediction_interval_lower_bound + prediction_interval_upper_bound) / 2, 6) AS gap_to_middle,
       ROUND(prediction_interval_upper_bound - prediction_interval_lower_bound, 1) AS prediction_width,
       ROUND(confidence_interval_upper_bound - confidence_interval_lower_bound, 1) AS confidence_width
FROM ML.FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.95 AS confidence_level));
```

| Column | Read it as |
|---|---|
| `forecast_value` | per the page, "the average of the prediction_interval_lower_bound and prediction_interval_upper_bound values" |
| `standard_error` | how variable the estimate is |
| `prediction_interval_*` | the range for the month's actual value |
| `confidence_interval_*` | a second pair of bounds the function returns; compare its width with the prediction interval's |
| `time_series_id_col` | only for a model with several series (lab 09, step 17) |

**What you should see:** `gap_to_middle` is 0 on every row. Compare the two widths month by month and note which interval is wider. The prediction interval is the one a planner reads: it is about where the actual value will fall.

## Step 5 · ML.EXPLAIN_FORECAST: history and forecast rows

```sql
SELECT time_series_type, COUNT(*) AS months,
       MIN(DATE(time_series_timestamp)) AS first_month, MAX(DATE(time_series_timestamp)) AS last_month,
       COUNTIF(confidence_level IS NULL) AS rows_without_level
FROM ML.EXPLAIN_FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.95 AS confidence_level))
GROUP BY time_series_type;
```

`ML.EXPLAIN_FORECAST` takes the same two arguments as `ML.FORECAST` (`horizon`, default 3; `confidence_level`, default 0.95) and returns "a superset of the results of ML.FORECAST": the forecast months and every history month. It only works when the model kept its decomposition (`DECOMPOSE_TIME_SERIES`, TRUE by default; lab 09, step 11).

**What you should see:** two rows. `history`: the training months, 1949-01 to 1958-12 (120 rows when no month is missing), with no confidence level. `forecast`: 12 rows for 1959, each with its level.

## Step 6 · The parts add up

```sql
SELECT DATE(time_series_timestamp) AS month_history,
       time_series_data,
       ROUND(time_series_adjusted_data, 1) AS adjusted,
       ROUND(trend, 1) AS trend,
       ROUND(seasonal_period_yearly, 1) AS yearly,
       spikes_and_dips, step_changes,
       ROUND(residual, 1) AS residual,
       ROUND(time_series_data
             - (trend + IFNULL(seasonal_period_yearly, 0) + IFNULL(seasonal_period_quarterly, 0)
                + IFNULL(seasonal_period_monthly, 0) + IFNULL(seasonal_period_weekly, 0)
                + IFNULL(seasonal_period_daily, 0) + IFNULL(holiday_effect, 0)
                + IFNULL(spikes_and_dips, 0) + IFNULL(step_changes, 0) + IFNULL(residual, 0)), 6) AS left_over
FROM ML.EXPLAIN_FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.95 AS confidence_level))
WHERE time_series_type = 'history' AND EXTRACT(YEAR FROM time_series_timestamp) = 1958
ORDER BY month_history;
```

For history months the page gives: `time_series_data = trend + seasonal_period_yearly + seasonal_period_quarterly + seasonal_period_monthly + seasonal_period_weekly + seasonal_period_daily + holiday_effect + spikes_and_dips + step_changes + residual`. A part the model did not find is NULL, so `IFNULL(…, 0)` treats it as zero. `time_series_adjusted_data` is the month after cleaning: trend plus seasons plus holiday effect.

**What you should see:** 12 rows for 1958 with `left_over` 0. For a monthly series without holidays, `seasonal_period_quarterly`, `_monthly`, `_weekly`, `_daily` and `holiday_effect` are NULL. On forecast rows `spikes_and_dips`, `step_changes` and `residual` are always NULL: a forecast has no surprises yet.

## Step 7 · ML.DETECT_ANOMALIES on the training months

Before you run it: Google's page says "All queries that use the ML.DETECT_ANOMALIES function are billable, regardless of the pricing model." That means it is billed even in a sandbox project. If your project has no billing account, the query may not run; read the expected output below instead. This is why the class looked for unusual months with `ML.EXPLAIN_FORECAST`.

```sql
SELECT DATE(month) AS month_history, passengers, is_anomaly,
       ROUND(lower_bound, 1) AS lower_bound, ROUND(upper_bound, 1) AS upper_bound,
       ROUND(anomaly_probability, 3) AS anomaly_probability
FROM ML.DETECT_ANOMALIES(MODEL ml.air_arima)
WHERE is_anomaly
ORDER BY anomaly_probability DESC;
```

With only the model, `ML.DETECT_ANOMALIES` checks every training month against the bounds the model expected. The page: to do this "the DECOMPOSE_TIME_SERIES training option must be set as its default value of TRUE". The output columns take the training columns' names: `month` (always a TIMESTAMP, hence `DATE(month)`) and `passengers` (always FLOAT64), then:

| Column | Read it as |
|---|---|
| `is_anomaly` | TRUE when `anomaly_probability` is above the threshold, that is, the value is outside the bounds |
| `lower_bound`, `upper_bound` | the range the model expected for that month |
| `anomaly_probability` | 0.95 means "a 95% probability that the given time series data value is an anomaly" |

**What you should see (expected output, for learners without billing):** of the 120 training months, a handful with `is_anomaly` TRUE, each with its value outside its bounds and `anomaly_probability` above 0.95. Computed outside BigQuery as the largest remainders after trend and season, the most unusual months were April 1953 (235 passengers, about 26 above expectation), February 1954 (188, about 20 below) and May 1953 (229, about 19 above). BigQuery's bounds are its own; expect these or months near them.

## Step 8 · anomaly_prob_threshold

```sql
SELECT 0.8 AS threshold, COUNTIF(is_anomaly) AS months_flagged
FROM ML.DETECT_ANOMALIES(MODEL ml.air_arima, STRUCT(0.8 AS anomaly_prob_threshold))
UNION ALL
SELECT 0.95, COUNTIF(is_anomaly)
FROM ML.DETECT_ANOMALIES(MODEL ml.air_arima, STRUCT(0.95 AS anomaly_prob_threshold))
UNION ALL
SELECT 0.99, COUNTIF(is_anomaly)
FROM ML.DETECT_ANOMALIES(MODEL ml.air_arima, STRUCT(0.99 AS anomaly_prob_threshold))
ORDER BY threshold;
```

`anomaly_prob_threshold` (FLOAT64, default 0.95, range [0, 1)): the page says "a larger threshold value results in a larger interval size". A wider interval flags fewer months.

**What you should see (expected output):** 3 rows; the count of flagged months falls as the threshold rises. This query runs the function three times, so it is billed three times.

## Step 9 · ML.DETECT_ANOMALIES on new months

First, the months you will pass, in plain SQL:

```sql
SELECT month, passengers
FROM ml.air_validation
ORDER BY month;
```

Then check them against the model:

```sql
SELECT DATE(month) AS month_new, passengers, is_anomaly,
       ROUND(lower_bound, 1) AS lower_bound, ROUND(upper_bound, 1) AS upper_bound
FROM ML.DETECT_ANOMALIES(MODEL ml.air_arima,
  STRUCT(0.95 AS anomaly_prob_threshold),
  (SELECT month, passengers FROM ml.air_validation))
ORDER BY month_new;
```

The third argument is a query (or a table) of new rows. The page's rules: the threshold "must be specified to detect anomalies in new time-series data"; the input columns must have the training names (`month`, `passengers`); and the four result columns are NULL for a month outside the model's forecast horizon or off its monthly frequency.

**What you should see (expected output):** 12 rows for 1959. The bounds are the model's expected range for each month, so they behave like activity 04's 95% interval. Computed outside BigQuery, an interval of similar width held only about 4 of the 12 months, so expect several summer months flagged as anomalies. Here an "anomaly" is the growing season again, not a broken month: a flag says the model did not expect the value, and a person decides why.

## Step 10 · ML.ARIMA_EVALUATE

```sql
SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift,
       ROUND(log_likelihood, 1) AS log_likelihood, ROUND(AIC, 1) AS aic, ROUND(variance, 1) AS variance,
       seasonal_periods, has_holiday_effect, has_spikes_and_dips, has_step_changes, error_message
FROM ML.ARIMA_EVALUATE(MODEL ml.air_arima)
ORDER BY aic;

SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift, ROUND(AIC, 1) AS aic
FROM ML.ARIMA_EVALUATE(MODEL ml.air_arima, STRUCT(FALSE AS show_all_candidate_models));
```

`ML.ARIMA_EVALUATE` needs no input data. Its one argument, `show_all_candidate_models`, defaults to TRUE for a single series: every order the search tried, with any fitting error in `error_message`. FALSE returns only the best, the one with the lowest AIC.

**What you should see:** the first query lists the candidates, lowest AIC first; the second returns one row, the same as the first query's top row. Computed outside BigQuery on the seasonally adjusted months, the chosen order was (0, 1, 1) with drift. `has_spikes_and_dips` and the other `has_` columns are filled only because the model kept its decomposition.

## Step 11 · ML.ARIMA_COEFFICIENTS

```sql
SELECT ar_coefficients, ma_coefficients, intercept_or_drift
FROM ML.ARIMA_COEFFICIENTS(MODEL ml.air_arima);
```

`ML.ARIMA_COEFFICIENTS` takes only the model.

| Column | Read it as |
|---|---|
| `ar_coefficients` | one weight per past value (p of them) |
| `ma_coefficients` | one weight per past surprise (q of them) |
| `intercept_or_drift` | the constant: "called intercept when non-seasonal d is 0, and drift when non-seasonal d is 1"; always 0 when d is 2 |

The columns `processed_input`, `weight` and `category_weights` are for models with extra input columns (`ARIMA_PLUS_XREG`) and stay empty here.

**What you should see:** one row whose array lengths match the p and q from step 10. For an order (0, 1, 1) with drift: an empty AR array, one MA weight, and a drift, the average monthly climb of the adjusted series.

## Step 12 · ML.EVALUATE, one score for the series

```sql
SELECT ROUND(mean_absolute_error, 1) AS mae,
       ROUND(root_mean_squared_error, 1) AS rmse,
       ROUND(mean_absolute_percentage_error, 2) AS mape,
       ROUND(symmetric_mean_absolute_percentage_error, 2) AS smape,
       ROUND(mean_absolute_scaled_error, 2) AS mase
FROM ML.EVALUATE(MODEL ml.air_arima,
  (SELECT month, passengers FROM ml.air_validation),
  STRUCT(TRUE AS perform_aggregation, 12 AS horizon));

SELECT ROUND(AVG(ABS(v.passengers - t.passengers)), 1) AS mae_seasonal_naive
FROM ml.air_validation AS v
JOIN ml.air_training AS t ON t.month = DATE_SUB(v.month, INTERVAL 1 YEAR);
```

`ML.EVALUATE` compares the forecast with real values you pass in. Its arguments: `perform_aggregation` (default TRUE: one row for the series), `horizon` (default the model's `HORIZON`) and `confidence_level` (step 13). The page: "If no input data is provided, use ML.ARIMA_EVALUATE instead. The support of ML.EVALUATE without input data is deprecated."

**What you should see:** one row. `mae` matches your MAE from activity 04. Compare `mape` with activity 04's MAPE: if one shows 6.2 and the other 0.062, they are the same value, written as a percentage and as a fraction. The second query is the bar, 47.3.

## Step 13 · ML.EVALUATE, month by month

```sql
SELECT DATE(month) AS month_scored, passengers,
       ROUND(forecasted_passengers, 1) AS forecasted_passengers,
       ROUND(lower_bound, 1) AS lower_bound, ROUND(upper_bound, 1) AS upper_bound,
       ROUND(absolute_error, 1) AS absolute_error,
       ROUND(absolute_percentage_error, 2) AS absolute_percentage_error
FROM ML.EVALUATE(MODEL ml.air_arima,
  (SELECT month, passengers FROM ml.air_validation),
  STRUCT(FALSE AS perform_aggregation, 0.9 AS confidence_level, 12 AS horizon))
ORDER BY month_scored;
```

With `perform_aggregation = FALSE` you get one row per month: the actual, `forecasted_<data column>` (here `forecasted_passengers`), the bounds at `confidence_level` (0.9 here; it applies only to this month-by-month form) and the two errors.

**What you should see:** 12 rows; `absolute_error` matches activity 04's misses without their signs, and the bounds are narrower than activity 04's because the level is 0.9.

## Step 14 · ML.METRICS: score any forecast, with or without a model

Activity 03 scored the naive and seasonal naive forecasts with hand-written `AVG(ABS(…))`. `ML.METRICS` computes a whole set of scores from any table or query that holds actual and predicted values, with no model involved. Google marks `ML.METRICS` as **Preview**, a pre-release feature that its page says is available "as is" and "might have limited support".

First, the two forecasts beside the actual months, in plain SQL. `CAST(… AS FLOAT64)` matters: the page says "The PREDICTED_COL and ACTUAL_COL columns must have the same data type."

```sql
CREATE OR REPLACE VIEW ml.air_baselines_1959 AS
SELECT v.month,
       CAST(v.passengers AS FLOAT64) AS actual_passengers,
       CAST((SELECT passengers FROM ml.air_training ORDER BY month DESC LIMIT 1) AS FLOAT64) AS naive_forecast,
       CAST(t.passengers AS FLOAT64) AS seasonal_naive_forecast
FROM ml.air_validation AS v
JOIN ml.air_training AS t ON t.month = DATE_SUB(v.month, INTERVAL 1 YEAR);
```

Then score each forecast. The arguments are named, written `name => 'value'`: the predicted column, the actual column, and `task_type`, here `'regression'` (the other value is `'classification'`):

```sql
SELECT 'naive' AS forecast_method,
       ROUND(mean_absolute_error, 1) AS mae, ROUND(mean_squared_error, 1) AS mse,
       ROUND(mean_squared_log_error, 4) AS msle, ROUND(median_absolute_error, 1) AS median_ae,
       ROUND(r2_score, 3) AS r2, ROUND(explained_variance, 3) AS explained_variance
FROM ML.METRICS((SELECT actual_passengers, naive_forecast FROM ml.air_baselines_1959),
                predicted_col => 'naive_forecast', actual_col => 'actual_passengers',
                task_type => 'regression')
UNION ALL
SELECT 'seasonal naive',
       ROUND(mean_absolute_error, 1), ROUND(mean_squared_error, 1),
       ROUND(mean_squared_log_error, 4), ROUND(median_absolute_error, 1),
       ROUND(r2_score, 3), ROUND(explained_variance, 3)
FROM ML.METRICS((SELECT actual_passengers, seasonal_naive_forecast FROM ml.air_baselines_1959),
                predicted_col => 'seasonal_naive_forecast', actual_col => 'actual_passengers',
                task_type => 'regression');
```

The page lists the six regression columns by name only. Read them as:

| Column | Read it as |
|---|---|
| `mean_absolute_error` | the average miss, activity 03's MAE |
| `mean_squared_error` | the average squared miss: big misses count much more |
| `mean_squared_log_error` | the same on the logarithm of 1 + each value: a miss counts as a share, not a number of passengers |
| `median_absolute_error` | the middle miss: half the months missed by less |
| `r2_score` | 1 − (squared misses ÷ squared distances from the 1959 average); below 0 means worse than predicting the 1959 average every month |
| `explained_variance` | like `r2_score`, but a constant miss (always too low by the same amount) is not counted against the forecast |

The same six numbers by hand, so you can check the function against the definitions:

```sql
WITH pairs AS (
  SELECT 'naive' AS forecast_method, actual_passengers AS actual, naive_forecast AS predicted
  FROM ml.air_baselines_1959
  UNION ALL
  SELECT 'seasonal naive', actual_passengers, seasonal_naive_forecast
  FROM ml.air_baselines_1959
),
misses AS (
  SELECT forecast_method, actual,
         actual - predicted AS miss,
         LN(1 + actual) - LN(1 + predicted) AS log_miss,
         AVG(actual) OVER (PARTITION BY forecast_method) AS mean_actual,
         AVG(actual - predicted) OVER (PARTITION BY forecast_method) AS mean_miss,
         PERCENTILE_CONT(ABS(actual - predicted), 0.5) OVER (PARTITION BY forecast_method) AS middle_miss
  FROM pairs
)
SELECT forecast_method,
       ROUND(AVG(ABS(miss)), 1) AS mae,
       ROUND(AVG(miss * miss), 1) AS mse,
       ROUND(AVG(log_miss * log_miss), 4) AS msle,
       ROUND(MAX(middle_miss), 1) AS median_ae,
       ROUND(1 - SUM(miss * miss) / SUM(POW(actual - mean_actual, 2)), 3) AS r2,
       ROUND(1 - SUM(POW(miss - mean_miss, 2)) / SUM(POW(actual - mean_actual, 2)), 3) AS explained_variance
FROM misses
GROUP BY forecast_method
ORDER BY forecast_method;
```

**What you should see:** two rows from each query, the same numbers.

| Forecast | `mae` | `mse` | `msle` | `median_ae` | `r2` | `explained_variance` |
|---|---:|---:|---:|---:|---:|---:|
| naive | 91.3 | 12,811.7 | 0.0742 | 69.5 | -1.866 | 0 |
| seasonal naive | 47.3 | 2,426.0 | 0.0150 | 50.0 | 0.457 | 0.958 |

`mae` is activity 03's 91.3 and 47.3. The naive forecast's R² is below zero: one flat line scores worse than the 1959 average would. Its explained variance is 0 (BigQuery may print a tiny number such as -2E-16): a flat line explains none of the month-to-month movement. The seasonal naive's explained variance (0.958) is far above its R² (0.457): it follows the shape of the year well, but every month is too low by about the same amount, because 1959 grew. That gap is the growth the seasonal naive does not know about.

Now the model's forecast, joined to the actual months:

```sql
SELECT ROUND(mean_absolute_error, 1) AS mae, ROUND(median_absolute_error, 1) AS median_ae,
       ROUND(r2_score, 3) AS r2, ROUND(explained_variance, 3) AS explained_variance
FROM ML.METRICS(
  (SELECT CAST(v.passengers AS FLOAT64) AS actual_passengers, f.forecast_value
   FROM ML.FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
   JOIN ml.air_validation AS v ON DATE(f.forecast_timestamp) = v.month),
  predicted_col => 'forecast_value', actual_col => 'actual_passengers', task_type => 'regression');
```

**What you should see:** one row. `mae` should equal step 12's `mae` from `ML.EVALUATE` and activity 04's MAE: computed outside BigQuery with a similar method, about 27. Compare its R² with the seasonal naive's 0.457.

**Think:** `ML.EVALUATE` needs the model; `ML.METRICS` needs only two columns. When would you have forecasts but no model to pass to `ML.EVALUATE`?

## More practice (not checked, not submitted)

- Run steps 5 and 6 on `ml.air_log` from lab 09: the decomposition is on the log scale, so the season is a share, not a number of passengers.
- Run step 10 on `ml.channel_arima` from lab 09, step 17: one block of rows per channel, with `channel` first.

## What you saw

| Function | One thing it told you about `ml.air_arima` |
|---|---|
| `ML.FORECAST` | |
| `ML.EXPLAIN_FORECAST` | |
| `ML.DETECT_ANOMALIES` | |
| `ML.ARIMA_EVALUATE` | |
| `ML.ARIMA_COEFFICIENTS` | |
| `ML.EVALUATE` | |
| `ML.METRICS` | |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 9 | 12 | the months passed: January **360**, July **548** |
| 12 | 1 | the bar **47.3** |
| 14 | 2 | naive **91.3**, **12,811.7**, **0.0742**, **69.5**, **-1.866**, **0** · seasonal naive **47.3**, **2,426.0**, **0.0150**, **50.0**, **0.457**, **0.958** |

The other steps read the model BigQuery trained; each step says how many rows to expect.

## Hint

Every function in this lab takes `MODEL ml.air_arima` first. Arguments go in one `STRUCT`, each written `value AS name`; new data, where a function takes it, goes in its own parentheses as a query.

## Bonus

`ML.FORECAST` and `ML.EXPLAIN_FORECAST` return the same forecast months. Join them on the timestamp and check that `forecast_value` equals `time_series_data` on every forecast row.

## References

Air Passengers: Box, Jenkins and Reinsel, *Time Series Analysis, Forecasting and Control* (1976), Series G, as listed on the [R datasets page](https://rweb.stat.umn.edu/R/library/datasets/html/AirPassengers.html); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 19 October 2026. BigQuery ML: [ML.FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast), [ML.EXPLAIN_FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-forecast), [ML.DETECT_ANOMALIES](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-detect-anomalies), [ML.ARIMA_EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-evaluate), [ML.ARIMA_COEFFICIENTS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-coefficients), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate) (time series tab), [ML.METRICS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-metrics) (Preview), Google Cloud. All pages read 19 October 2026.
