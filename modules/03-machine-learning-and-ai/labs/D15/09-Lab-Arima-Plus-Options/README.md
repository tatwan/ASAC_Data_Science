# Lab 09 · ARIMA_PLUS, option by option

In this self-guided lab, you will walk through every option on Google's CREATE MODEL page for ARIMA_PLUS, change one option or one small group at a time, and see what each change does to the model, its forecast and its 1959 score.

**When:** after class, about 60 minutes, at your own pace. Not submitted. · **Data:** `ml.air_training` and `ml.air_arima` (activity 02), `ml.air_validation` (activity 03); `nakheel.orders` (D04 activity 03) for step 17 · **SQL:** `Unsolved/arima_plus_options.sql` to run step by step, `Solved/arima_plus_options.sql`

## The story

In class, `ml.air_arima` used four options and left about twenty at Google's defaults. It beat the seasonal naive on 1959, but its summer peaks were too low. Every default is a choice someone made for an average series. This lab shows what each option does on yours, so that when a forecast misbehaves you know which option to reach for, and which options do nothing for a monthly series.

## What you will learn

- What each ARIMA_PLUS option does, its default, and which options depend on each other.
- To read what the model chose with `ML.ARIMA_EVALUATE`.
- To compare a changed model with the default on the same 1959 months, with one scoring query.
- Why forecasting the logarithm of the series helps when the season grows with the level.

## Before you start

You need `ml.air_training` (activity 02, step 1), `ml.air_validation` (activity 03, step 1) and `ml.air_arima` (activity 02, step 2). Check: `SELECT COUNT(*) FROM ml.air_validation;` returns 12. If anything is missing, run [`Resources/restart_d15.sql`](../Resources/restart_d15.sql). Step 17 also needs the `nakheel` tables from D04.

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. ARIMA_PLUS trains in a sandbox. Each model reads 120 small rows several times; the whole lab uses a tiny share of the free monthly allowance. The ARIMA_PLUS values in this lab have not been computed outside BigQuery, apart from the ones marked "about"; the lab tells you what to look for instead of a number to match.

## Checkpoints

- **C1:** a model with every default written out, scoring the same as the class model on 1959 (step 2).
- **C2:** one changed option, its 1959 MAE beside the default's, and one sentence on why it moved or did not (any of steps 5 to 14; step 7 is a good first choice).
- **C3:** the model trained on the logarithm of the series, its 1959 MAE beside the plain one, and one sentence on why (step 15).

## Step 1 · The bar, and one scoring query

The bar from activity 03, exact:

```sql
SELECT ROUND(AVG(ABS(v.passengers - t.passengers)), 1) AS mae_seasonal_naive
FROM ml.air_validation AS v
JOIN ml.air_training AS t ON t.month = DATE_SUB(v.month, INTERVAL 1 YEAR);
```

Every model in this lab is scored the same way, on the 12 months of 1959. Here is the query once, for the class model; for any other model, change only the model name:

```sql
SELECT ROUND(AVG(ABS(v.passengers - f.forecast_value)), 1) AS validation_mae
FROM ML.FORECAST(MODEL ml.air_arima, STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.air_validation AS v ON DATE(f.forecast_timestamp) = v.month;
```

**What you should see:** 47.3, then your class model's MAE (activity 04). Write both in **What you saw** at the end.

## Step 2 · Every default, written out (C1)

```sql
CREATE OR REPLACE MODEL ml.air_defaults
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         AUTO_ARIMA = TRUE,
         AUTO_ARIMA_MAX_ORDER = 2,
         AUTO_ARIMA_MIN_ORDER = 0,
         DATA_FREQUENCY = 'AUTO_FREQUENCY',
         SEASONALITIES = ['AUTO'],
         CLEAN_SPIKES_AND_DIPS = TRUE,
         ADJUST_STEP_CHANGES = TRUE,
         DECOMPOSE_TIME_SERIES = TRUE) AS
SELECT month, passengers FROM ml.air_training;
```

Every value after `HORIZON` is the page's default, so this is the class model with its choices made visible. `HORIZON` is the one option the class changed (its default is 1,000). Options without a default value (`NON_SEASONAL_ORDER`, `HOLIDAY_REGION` and others) are left out; later steps set them.

**What you should see:** score it with step 1's query and `ml.air_defaults`. The MAE is the same as `ml.air_arima`'s.

**C1:** the two MAEs, side by side.

## Step 3 · What did the model choose?

```sql
SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift,
       ROUND(AIC, 1) AS aic, seasonal_periods,
       has_spikes_and_dips, has_step_changes, has_holiday_effect
FROM ML.ARIMA_EVALUATE(MODEL ml.air_defaults, STRUCT(FALSE AS show_all_candidate_models));
```

`ML.ARIMA_EVALUATE` reports the model ARIMA_PLUS kept. `AUTO_ARIMA = TRUE` tried several orders (p, d, q) for the trend and kept the one with the lowest AIC, a score that rewards a good fit and penalises extra terms.

| Column | Read it as |
|---|---|
| `non_seasonal_p` | how many past values the next month leans on (AR) |
| `non_seasonal_d` | how many times the series was differenced: 1 means the model works with month-to-month changes |
| `non_seasonal_q` | how many past surprises the next month leans on (MA) |
| `has_drift` | a steady climb added to the changes (only when d is 1) |
| `seasonal_periods` | the seasons found, for example `YEARLY` |

**What you should see:** one row. Computed outside BigQuery on the seasonally adjusted months, the chosen order was ARIMA(0, 1, 1) with drift; BigQuery makes its own choice. Expect `seasonal_periods` to include `YEARLY`, and `has_holiday_effect` FALSE.

## Step 4 · MODEL_TYPE, TIME_SERIES_TIMESTAMP_COL and TIME_SERIES_DATA_COL

```sql
CREATE OR REPLACE MODEL ml.air_timestamp
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month_start',
         TIME_SERIES_DATA_COL = 'passengers_float',
         HORIZON = 12) AS
SELECT TIMESTAMP(month) AS month_start, CAST(passengers AS FLOAT64) AS passengers_float
FROM ml.air_training;
```

- `MODEL_TYPE` is required. The page notes that the older `'ARIMA'` model type is deprecated; ARIMA_PLUS adds `DECOMPOSE_TIME_SERIES`, `ML.ARIMA_EVALUATE` and `ML.EXPLAIN_FORECAST`.
- `TIME_SERIES_TIMESTAMP_COL` may be a TIMESTAMP, DATE or DATETIME column. Here the same months arrive as TIMESTAMP.
- `TIME_SERIES_DATA_COL` may be INT64, NUMERIC, BIGNUMERIC or FLOAT64. Here the same values arrive as FLOAT64.

**What you should see:** score it (step 1's query, model `ml.air_timestamp`): the same MAE as step 2. The types changed; the series did not. `ML.FORECAST` returns `forecast_timestamp` as a TIMESTAMP either way.

## Step 5 · HORIZON

```sql
CREATE OR REPLACE MODEL ml.air_horizon24
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 24) AS
SELECT month, passengers FROM ml.air_training;

SELECT DATE(forecast_timestamp) AS month_forecast, ROUND(forecast_value, 1) AS forecast_value,
       ROUND(prediction_interval_upper_bound - prediction_interval_lower_bound, 1) AS interval_width
FROM ML.FORECAST(MODEL ml.air_horizon24, STRUCT(24 AS horizon, 0.95 AS confidence_level));
```

Google's `ML.FORECAST` page: "Forecasting takes place when the CREATE MODEL statement runs. ML.FORECAST just retrieves the forecasting values and computes the prediction intervals." So `HORIZON` (default 1,000, at most 10,000) is how far ahead the model prepares, and `ML.FORECAST`'s `horizon` can ask for that many months or fewer, never more.

**What you should see:** 24 rows, 1959 and 1960, with `interval_width` growing all the way. Now ask the class model, built with `HORIZON = 12`, for 24 months: `ML.FORECAST(MODEL ml.air_arima, STRUCT(24 AS horizon, 0.95 AS confidence_level))`. It stops with an error.

**Think:** why might you set `HORIZON` well above what the planner asks for today?

## Step 6 · AUTO_ARIMA_MAX_ORDER and AUTO_ARIMA_MIN_ORDER

```sql
CREATE OR REPLACE MODEL ml.air_order5
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         AUTO_ARIMA_MAX_ORDER = 5) AS
SELECT month, passengers FROM ml.air_training;

SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift, ROUND(AIC, 1) AS aic, error_message
FROM ML.ARIMA_EVALUATE(MODEL ml.air_order5, STRUCT(TRUE AS show_all_candidate_models))
ORDER BY aic;
```

`AUTO_ARIMA_MAX_ORDER` (1 to 5, default 2) caps p + q, the size of the search. `AUTO_ARIMA_MIN_ORDER` (default 0) sets its floor; the page says a floor of 1 or more "lets the model exclude some flat forecasting results", and it must stay below the maximum. A bigger search costs more: Google's pricing page says the bytes read are multiplied by the number of candidate models, which for a maximum of 5 is 21 candidates, or 42 when d is 1, against 6 or 12 at the default of 2.

**What you should see:** one row per candidate the search tried, best (lowest AIC) first. Run step 3's query on `ml.air_order5`: did a wider search pick a different order? Score it with step 1's query.

To try the floor, train `ml.air_min1` the same way with `AUTO_ARIMA_MIN_ORDER = 1` in place of `AUTO_ARIMA_MAX_ORDER = 5`, and look at its chosen order.

## Step 7 · AUTO_ARIMA, NON_SEASONAL_ORDER and INCLUDE_DRIFT

```sql
CREATE OR REPLACE MODEL ml.air_manual
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         AUTO_ARIMA = FALSE,
         NON_SEASONAL_ORDER = (1, 1, 0),
         INCLUDE_DRIFT = TRUE) AS
SELECT month, passengers FROM ml.air_training;
```

With `AUTO_ARIMA = FALSE` you choose the order yourself, and the page says you must then give `NON_SEASONAL_ORDER` as three numbers (p, d, q): p and q from 0 to 5, d from 0 to 2, no defaults. `INCLUDE_DRIFT` (default FALSE) adds the steady climb, and only when d is 1; with `AUTO_ARIMA = TRUE` you cannot set it, because the search decides.

**What you should see:** score it with step 1's query. Compare with step 2's MAE. Then try `NON_SEASONAL_ORDER = (1, 0, 0)` with `INCLUDE_DRIFT = TRUE`: the page says this "returns an invalid query error", because drift needs d = 1.

**C2:** the changed model's 1959 MAE beside the default's, and one sentence: did your order beat the search's choice, and is one year of 12 months enough to be sure?

## Step 8 · DATA_FREQUENCY

```sql
CREATE OR REPLACE MODEL ml.air_monthly
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         DATA_FREQUENCY = 'MONTHLY') AS
SELECT month, passengers FROM ml.air_training;
```

`DATA_FREQUENCY` is one of `AUTO_FREQUENCY` (the default: the model infers it), `PER_MINUTE`, `HOURLY`, `DAILY`, `WEEKLY`, `MONTHLY`, `QUARTERLY` or `YEARLY`.

**What you should see:** the same MAE as step 2. The model already inferred monthly data. Setting it yourself matters when the time points are irregular or the inference could go wrong; lab 13 sets `DAILY`.

## Step 9 · SEASONALITIES

```sql
CREATE OR REPLACE MODEL ml.air_noseason
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         SEASONALITIES = ['NO_SEASONALITY']) AS
SELECT month, passengers FROM ml.air_training;
```

`SEASONALITIES` is a list chosen from `AUTO` (the default), `NO_SEASONALITY`, `DAILY`, `WEEKLY`, `MONTHLY`, `QUARTERLY` and `YEARLY`. `AUTO` and `NO_SEASONALITY` must be used alone: `['NO_SEASONALITY', 'DAILY']` is not valid. A season finer than the data (`DAILY` on monthly data) is ignored.

**What you should see:** score it. Expect a much larger MAE than step 2's: without a season the forecast cannot rise in summer. Then train `ml.air_yearly` with `SEASONALITIES = ['YEARLY']`: expect the same MAE as step 2, because the search had found a yearly season by itself.

## Step 10 · CLEAN_SPIKES_AND_DIPS and ADJUST_STEP_CHANGES

```sql
CREATE OR REPLACE MODEL ml.air_raw
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         CLEAN_SPIKES_AND_DIPS = FALSE,
         ADJUST_STEP_CHANGES = FALSE) AS
SELECT month, passengers FROM ml.air_training;

SELECT COUNTIF(spikes_and_dips IS NOT NULL AND spikes_and_dips != 0) AS months_cleaned,
       COUNTIF(step_changes IS NOT NULL AND step_changes != 0) AS months_with_step_change
FROM ML.EXPLAIN_FORECAST(MODEL ml.air_defaults, STRUCT(12 AS horizon, 0.95 AS confidence_level))
WHERE time_series_type = 'history';
```

Both default to TRUE. With `CLEAN_SPIKES_AND_DIPS`, spikes and dips "are replaced with local linear interpolated values when they're detected", so one odd month does not bend the trend. With `ADJUST_STEP_CHANGES`, a sudden lasting jump in level is detected and adjusted.

**What you should see:** the count query tells you how many training months the default model cleaned or adjusted (possibly none). Run step 3's query on `ml.air_raw`: `has_spikes_and_dips` and `has_step_changes` are FALSE. Score it: if the default cleaned nothing, the MAE is the same.

## Step 11 · DECOMPOSE_TIME_SERIES

```sql
CREATE OR REPLACE MODEL ml.air_nodecomp
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         DECOMPOSE_TIME_SERIES = FALSE) AS
SELECT month, passengers FROM ml.air_training;

SELECT *
FROM ML.EXPLAIN_FORECAST(MODEL ml.air_nodecomp, STRUCT(12 AS horizon, 0.95 AS confidence_level));
```

`DECOMPOSE_TIME_SERIES` (default TRUE) keeps the parts of the series (trend, season, spikes, holidays) in the model so that `ML.EXPLAIN_FORECAST` can show them. FALSE saves space; Google's limit on series length is 500,000 points with it and 1,000,000 without.

**What you should see:** the model trains and `ML.FORECAST` works (score it: the same MAE as step 2), but `ML.EXPLAIN_FORECAST` stops with an error. `ML.DETECT_ANOMALIES` on the training months also needs this option left TRUE (lab 10).

## Step 12 · TREND_SMOOTHING_WINDOW_SIZE

```sql
CREATE OR REPLACE MODEL ml.air_smooth
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         TREND_SMOOTHING_WINDOW_SIZE = 12) AS
SELECT month, passengers FROM ml.air_training;

SELECT DATE(d.time_series_timestamp) AS month_history,
       ROUND(d.trend, 1) AS trend_default, ROUND(s.trend, 1) AS trend_smoothed
FROM ML.EXPLAIN_FORECAST(MODEL ml.air_defaults, STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS d
JOIN ML.EXPLAIN_FORECAST(MODEL ml.air_smooth, STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS s
  ON d.time_series_timestamp = s.time_series_timestamp
WHERE d.time_series_type = 'history' AND EXTRACT(YEAR FROM d.time_series_timestamp) = 1955
ORDER BY month_history;
```

The page: "Specifying a value for TREND_SMOOTHING_WINDOW_SIZE doesn't affect forecasting results. It only affects the smoothness of the trend component, which you can see by using the ML.EXPLAIN_FORECAST function." It is the width of a centred moving average over the history's trend (D10's moving average).

**What you should see:** 12 rows for 1955; the smoothed trend changes more evenly from month to month. Score `ml.air_smooth`: the same MAE as step 2.

## Step 13 · TIME_SERIES_LENGTH_FRACTION, MIN_TIME_SERIES_LENGTH and MAX_TIME_SERIES_LENGTH

```sql
CREATE OR REPLACE MODEL ml.air_recent_half
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         TIME_SERIES_LENGTH_FRACTION = 0.5,
         MIN_TIME_SERIES_LENGTH = 36) AS
SELECT month, passengers FROM ml.air_training;

CREATE OR REPLACE MODEL ml.air_recent_30
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         MAX_TIME_SERIES_LENGTH = 30) AS
SELECT month, passengers FROM ml.air_training;
```

These three options limit how much history the **trend** is fitted on; the season and the other parts still use every month.

| Option | Default | What it does |
|---|---|---|
| `TIME_SERIES_LENGTH_FRACTION` | all points used | the share of the series used for the trend, between 0 and 1 |
| `MIN_TIME_SERIES_LENGTH` | 20 | the fewest points the trend may use; needs `TIME_SERIES_LENGTH_FRACTION` |
| `MAX_TIME_SERIES_LENGTH` | none (the page suggests trying 30) | the most points the trend may use; cannot be combined with the other two |

**What you should see:** score both. The first fits the trend on the last 60 of 120 months, the second on the last 30. A series whose growth changed over time can gain from a recent trend; this one grew steadily, so watch whether either beats step 2.

## Step 14 · FORECAST_LIMIT_LOWER_BOUND and FORECAST_LIMIT_UPPER_BOUND

```sql
CREATE OR REPLACE MODEL ml.air_bounded
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         FORECAST_LIMIT_LOWER_BOUND = 0,
         FORECAST_LIMIT_UPPER_BOUND = 1000) AS
SELECT month, passengers FROM ml.air_training;
```

The two bounds keep forecasts inside a range: passengers cannot go below zero, and this airline's fleet cannot carry more than a set number. The page adds a rule that matters: "all values less than or equal to the FORECAST_LIMIT_LOWER_BOUND value are excluded from modeling", and the same for values at or above the upper bound. The lower bound must be below the upper bound.

**What you should see:** score it: the same MAE as step 2, because every training month lies strictly between 0 and 1,000 and no forecast comes near either bound. On a series with days of zero sales, a lower bound of 0 would drop those days from the model; lab 13 meets that case.

## Step 15 · Forecast the logarithm (C3)

In class the summer peaks came in above the forecast, because the season grows with the level and ARIMA_PLUS adds the season back as a fixed amount. ARIMA_PLUS does not take logarithms by itself, but you can give it `LN(passengers)` and convert the forecast back with `EXP`. On a log scale a season that is a share of the traffic becomes a fixed amount, which is what the model expects.

```sql
SELECT month, passengers, ROUND(LN(passengers), 3) AS log_passengers
FROM ml.air_training
ORDER BY month;

CREATE OR REPLACE MODEL ml.air_log
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'log_passengers',
         HORIZON = 12) AS
SELECT month, LN(passengers) AS log_passengers FROM ml.air_training;

SELECT ROUND(AVG(ABS(v.passengers - EXP(f.forecast_value))), 1) AS validation_mae,
       COUNTIF(v.passengers BETWEEN EXP(f.prediction_interval_lower_bound)
                                AND EXP(f.prediction_interval_upper_bound)) AS months_inside
FROM ML.FORECAST(MODEL ml.air_log, STRUCT(12 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.air_validation AS v ON DATE(f.forecast_timestamp) = v.month;
```

`EXP` undoes `LN`, for the forecast and for both bounds.

**What you should see:** 120 rows for the log series, from 4.718 (January 1949) to 5.82 (December 1958). Then the score. Computed outside BigQuery with a similar method, the log model's 1959 MAE was about 17 against about 27 for the plain one, and its 95% interval held all 12 months. BigQuery's values will differ; look for the same direction.

**C3:** the two MAEs, and one sentence on why the log model fits the summer peaks better.

## Step 16 · HOLIDAY_REGION

```sql
CREATE OR REPLACE MODEL ml.air_holiday
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'month',
         TIME_SERIES_DATA_COL = 'passengers',
         HORIZON = 12,
         HOLIDAY_REGION = 'GLOBAL') AS
SELECT month, passengers FROM ml.air_training;
```

`HOLIDAY_REGION` (no default: by default holidays are not modelled) names one region or a list of regions whose holidays the model adjusts for: `GLOBAL`, a continent such as `EMEA`, or a country code such as `AE` or `SA`. The page: "Holiday effect modeling is only applicable when the time series is daily or weekly, and longer than a year." The full list does not include Jordan.

**What you should see:** run step 3's query on `ml.air_holiday`: `has_holiday_effect` is FALSE, and the MAE is the same as step 2. A monthly series has no holiday effect to model. Lab 13 shows the page's route for holidays a region code does not cover: a custom holiday table.

## Step 17 · TIME_SERIES_ID_COL: many series in one model

```sql
CREATE OR REPLACE VIEW ml.channel_revenue AS
SELECT DATE_TRUNC(order_date, MONTH) AS order_month, channel,
       SUM(order_total) AS revenue
FROM nakheel.orders
WHERE status = 'completed'
GROUP BY order_month, channel;

SELECT channel, COUNT(*) AS months, ROUND(SUM(revenue), 2) AS total_revenue
FROM ml.channel_revenue
GROUP BY channel
ORDER BY channel;

CREATE OR REPLACE MODEL ml.channel_arima
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'order_month',
         TIME_SERIES_DATA_COL = 'revenue',
         TIME_SERIES_ID_COL = 'channel',
         HORIZON = 6) AS
SELECT order_month, channel, revenue FROM ml.channel_revenue;

SELECT channel, DATE(forecast_timestamp) AS month_forecast, ROUND(forecast_value, 2) AS forecast_value
FROM ML.FORECAST(MODEL ml.channel_arima, STRUCT(6 AS horizon, 0.95 AS confidence_level))
ORDER BY channel, month_forecast;
```

Nakheel's completed revenue by month and channel: two series, store and online, 24 months each. `TIME_SERIES_ID_COL` names the column (or columns) that tell the series apart; each value gets its own model, fitted in one query (up to 100,000,000 series). The page's rules: `AUTO_ARIMA` must stay TRUE and `NON_SEASONAL_ORDER` is not allowed, because each series needs its own search. `ML.FORECAST` and `ML.ARIMA_EVALUATE` return one block of rows per series, with the ID column first.

**What you should see:** the check query returns 2 rows of 24 months each (online 110,685.50 and store 205,338.00 dinars over the two years; order totals are before shipping). The forecast returns 12 rows, 6 per channel.

## Step 18 · HIERARCHICAL_TIME_SERIES_COLS and KMS_KEY_NAME

Two options this lab reads but does not run:

- `HIERARCHICAL_TIME_SERIES_COLS` works with `TIME_SERIES_ID_COL` when the series form a hierarchy, for example a region and the cities inside it. It lists the columns of the hierarchy, the parent first, and BigQuery adds the forecasts up from the bottom so that the cities' forecasts sum to the region's. Nakheel's channel series have one level, so there is nothing to add up here.
- `KMS_KEY_NAME` encrypts the model with a key your organisation manages. Not used in this course.

## More practice (not checked, not submitted)

- **A real forecast for 1961.** Train on all 144 months of `ml.air_passengers` with the log input of step 15, forecast 12 months, and save it as a table the way activity 08 did. This is what the planner would actually receive.
- **A wider search on the log series.** Add `AUTO_ARIMA_MAX_ORDER = 5` to `ml.air_log` and compare the chosen order and the MAE.
- **A narrower interval.** Score `ml.air_log`'s interval at `0.8 AS confidence_level`: how many of the 12 months does it hold?

## What you saw

| Model | Option changed | 1959 MAE | Same as the default? Why? |
|---|---|---:|---|
| seasonal naive | none (the bar) | 47.3 | |
| `ml.air_defaults` | none, written out | | |
| `ml.air_manual` | your own order | | |
| `ml.air_noseason` | no season | | |
| `ml.air_recent_half` | recent trend | | |
| `ml.air_log` | log input | | |

**Think:** which options changed the forecast, and which changed only what `ML.EXPLAIN_FORECAST` shows or what the model costs?

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | the bar **47.3** |
| 15 | 120 | first log value **4.718**, last **5.82** |
| 17 | 2 | **24** months per channel · online **110,685.5** · store **205,338** |

The model results in this lab depend on BigQuery's training runs; the steps say what to compare.

## Hint

When a model trains but scores exactly like the default, the option either matched what the search had already chosen (steps 8, 9) or affects something other than the forecast (steps 10 to 12, 14, 16). Run step 3's query to tell which.

## Bonus

Steps 6 and 7 both change the ARIMA order. Use `ML.ARIMA_COEFFICIENTS(MODEL ml.air_manual)` to read the AR coefficient and the drift your manual model fitted (lab 10, step 11, explains the columns).

## References

Air Passengers: Box, Jenkins and Reinsel, *Time Series Analysis, Forecasting and Control* (1976), Series G, as listed on the [R datasets page](https://rweb.stat.umn.edu/R/library/datasets/html/AirPassengers.html); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 19 October 2026. Nakheel Retail, course-owned synthetic data; see [the dataset README](../../../../../shared/datasets/nakheel/README.md). BigQuery ML: [CREATE MODEL for ARIMA_PLUS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series) (every option and its default; page updated 16 October 2026), [ML.ARIMA_EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-evaluate), [ML.FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast), [ML.EXPLAIN_FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-explain-forecast), [BigQuery ML pricing](https://cloud.google.com/bigquery/pricing#bqml) (candidate models and cost), Google Cloud.
