-- D16 · How many babies will be born each day? A forecast, start to finish · Solved (every query from the README, in order)
-- Run one statement at a time, in order. CREATE MODEL and the ML. functions run in BigQuery only.

-- Step 1 · Look: one row is one day
SELECT day_name, ROUND(AVG(births)) AS average_births
FROM ml.us_births
GROUP BY day_name
ORDER BY average_births;

-- Step 2 · Create the model on 2000 to 2013
CREATE OR REPLACE MODEL ml.births_arima
OPTIONS (model_type = 'ARIMA_PLUS',
         time_series_timestamp_col = 'birth_date',
         time_series_data_col = 'births',
         horizon = 365,
         holiday_region = 'US') AS
SELECT birth_date, births
FROM ml.us_births
WHERE birth_date < '2014-01-01';

-- Step 3 · Evaluate on 2014
SELECT ROUND(mean_absolute_error) AS mae,
       ROUND(mean_absolute_percentage_error, 1) AS mape_pct
FROM ML.EVALUATE(MODEL ml.births_arima,
       (SELECT birth_date, births FROM ml.us_births
        WHERE birth_date >= '2014-01-01'),
       STRUCT(TRUE AS perform_aggregation, 365 AS horizon));

-- Step 4 · Forecast three days to check
SELECT DATE(f.forecast_timestamp) AS day,
       ROUND(f.forecast_value) AS forecast,
       b.births AS actual
FROM ML.FORECAST(MODEL ml.births_arima,
       STRUCT(365 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.us_births AS b ON b.birth_date = DATE(f.forecast_timestamp)
WHERE DATE(f.forecast_timestamp) IN ('2014-06-13', '2014-07-04', '2014-12-25')
ORDER BY day;

-- Step 5 · History and forecast in one view
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
FROM ML.FORECAST(MODEL ml.births_arima,
       STRUCT(365 AS horizon, 0.95 AS confidence_level));

SELECT series, COUNT(*) AS days, MIN(day) AS first_day, MAX(day) AS last_day
FROM ml.v_births_history_forecast
GROUP BY series;
