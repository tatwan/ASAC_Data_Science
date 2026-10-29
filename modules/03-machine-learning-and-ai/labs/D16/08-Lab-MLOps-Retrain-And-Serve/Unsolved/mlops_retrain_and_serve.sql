-- D16 · Lab 08 · Retrain on every year, then choose how to serve the forecast · Starter
-- Self-guided: run one statement at a time, after reading its step in the README.
-- The README explains each step: read it first, run the SQL, then compare with "What you should see".

-- Step 1 · What the class model forecasts
SELECT COUNT(*) AS forecast_days,
       MIN(DATE(forecast_timestamp)) AS first_day,
       MAX(DATE(forecast_timestamp)) AS last_day
FROM ML.FORECAST(MODEL ml.births_arima,
       STRUCT(365 AS horizon, 0.95 AS confidence_level));

SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift,
       seasonal_periods, has_holiday_effect
FROM ML.ARIMA_EVALUATE(MODEL ml.births_arima, STRUCT(FALSE AS show_all_candidate_models));

-- Step 2 · Retrain on all fifteen years (C1, part 1)
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

-- Step 3 · The 2015 forecast (C1, part 2)
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

-- Step 4 · Swap the model behind the view (C2)
SELECT ordinal_position, column_name, data_type
FROM ml.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'v_births_history_forecast'
ORDER BY ordinal_position;

SELECT series, COUNT(*) AS days, MIN(day) AS first_day, MAX(day) AS last_day
FROM ml.v_births_history_forecast
GROUP BY series
ORDER BY series;

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

-- Step 5 · The same forecast as a table, and which one to serve (C3)
CREATE OR REPLACE TABLE ml.births_forecast_2015 AS
SELECT DATE(forecast_timestamp) AS day,
       ROUND(forecast_value) AS births,
       ROUND(prediction_interval_lower_bound) AS lower_95,
       ROUND(prediction_interval_upper_bound) AS upper_95
FROM ML.FORECAST(MODEL ml.births_arima_v2,
       STRUCT(365 AS horizon, 0.95 AS confidence_level));

SELECT COUNT(*) AS forecast_days FROM ml.births_forecast_2015;
SELECT COUNT(*) AS forecast_days FROM ml.v_births_history_forecast WHERE series = 'forecast';
