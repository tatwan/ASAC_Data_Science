-- D16 · Restart: the four recap tables, models and views in one run
-- Use it if you missed the class activities, or a later lab says a table, model or view is missing.
-- First upload the four CSVs from shared/datasets/ml_recap (GitHub) into ml as diamonds, titanic,
-- pokemon and us_births: Create table, Upload, CSV, Auto detect (activity 01's "Before you start").
-- Every model here is built in (linear, logistic, k-means, ARIMA_PLUS), so it runs in a sandbox.
-- Run the whole file, or one block at a time. The four CREATE MODEL statements take a few minutes together.

CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');

-- Check the uploads: 53,940 · 1,309 · 1,215 · 5,479
SELECT (SELECT COUNT(*) FROM ml.diamonds) AS diamonds, (SELECT COUNT(*) FROM ml.titanic) AS titanic,
       (SELECT COUNT(*) FROM ml.pokemon) AS pokemon, (SELECT COUNT(*) FROM ml.us_births) AS us_births;

-- Regression (activity 01)
CREATE OR REPLACE MODEL ml.diamond_price
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['price']) AS
SELECT * EXCEPT (diamond_id) FROM ml.diamonds;

CREATE OR REPLACE VIEW ml.v_diamond_prices AS
SELECT diamond_id, carat, cut, color, clarity, price,
       ROUND(predicted_price) AS predicted_price
FROM ML.PREDICT(MODEL ml.diamond_price, TABLE ml.diamonds);

-- Classification (activity 02)
CREATE OR REPLACE MODEL ml.titanic_survival
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['survived']) AS
SELECT * EXCEPT (passenger_id) FROM ml.titanic;

CREATE OR REPLACE VIEW ml.v_titanic_scored AS
SELECT passenger_id, pclass, sex, age, survived, predicted_survived,
       ROUND(p.prob, 3) AS survival_chance
FROM ML.PREDICT(MODEL ml.titanic_survival, TABLE ml.titanic),
     UNNEST(predicted_survived_probs) AS p
WHERE p.label = TRUE;

-- Clustering (activity 03)
CREATE OR REPLACE MODEL ml.pokemon_groups
OPTIONS (model_type = 'KMEANS', num_clusters = 4) AS
SELECT hp, attack, defense, sp_attack, sp_defense, speed FROM ml.pokemon;

CREATE OR REPLACE VIEW ml.v_pokemon_groups AS
SELECT pokemon_id, name, form, type1, type2, generation,
       hp, attack, defense, sp_attack, sp_defense, speed, total,
       centroid_id
FROM ML.PREDICT(MODEL ml.pokemon_groups, TABLE ml.pokemon);

-- Forecast (activity 04)
CREATE OR REPLACE MODEL ml.births_arima
OPTIONS (model_type = 'ARIMA_PLUS',
         time_series_timestamp_col = 'birth_date',
         time_series_data_col = 'births',
         horizon = 365,
         holiday_region = 'US') AS
SELECT birth_date, births FROM ml.us_births WHERE birth_date < '2014-01-01';

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

-- Check: four views, with 53,940 · 1,309 · 1,215 · 5,844 rows
SELECT 'v_diamond_prices' AS view_name, COUNT(*) AS row_count FROM ml.v_diamond_prices
UNION ALL SELECT 'v_titanic_scored', COUNT(*) FROM ml.v_titanic_scored
UNION ALL SELECT 'v_pokemon_groups', COUNT(*) FROM ml.v_pokemon_groups
UNION ALL SELECT 'v_births_history_forecast', COUNT(*) FROM ml.v_births_history_forecast;
