-- D23 · Austin bike share and the weather, BigQuery to Power BI
-- Every statement the D23 activities run, in order. Run them in your own BigQuery sandbox project.
-- Data: bigquery-public-data.austin_bikeshare (City of Austin) and noaa_gsod (NOAA), read in place.

-- Activity 01 · Step 1: trips in 2023, by month
SELECT FORMAT_DATE('%m', DATE(start_time)) AS month_number,
       COUNT(*) AS rides
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE start_time >= '2023-01-01' AND start_time < '2024-01-01'
GROUP BY month_number
ORDER BY month_number;

-- Activity 01 · Step 2: how many trips find their station in the stations table?
SELECT COUNT(*) AS rides,
       COUNT(st.station_id) AS rides_with_a_station,
       COUNT(DISTINCT t.start_station_id) AS station_ids,
       COUNT(DISTINCT IF(st.station_id IS NULL, t.start_station_id, NULL)) AS ids_not_found
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS t
LEFT JOIN `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS st
  ON st.station_id = t.start_station_id
WHERE t.start_time >= '2023-01-01' AND t.start_time < '2024-01-01';

-- Activity 01 · Step 3: rides per day joined to the day's weather
WITH daily AS (
  SELECT DATE(start_time) AS day, COUNT(*) AS rides
  FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips`
  WHERE start_time >= '2023-01-01' AND start_time < '2024-01-01'
  GROUP BY day
),
weather AS (
  SELECT date AS day, `max` AS max_temp_f, prcp AS rain_in
  FROM `bigquery-public-data.noaa_gsod.gsod2023`
  WHERE stn = '722544'                      -- Austin Camp Mabry
)
SELECT CASE WHEN rain_in >= 0.25 THEN 'Rain'
            WHEN max_temp_f >= 100 THEN 'Hot'
            ELSE 'Other' END AS day_type,
       COUNT(*) AS days,
       ROUND(AVG(rides), 1) AS average_rides
FROM daily JOIN weather USING (day)
GROUP BY day_type
ORDER BY average_rides;

-- Activity 01 · Step 4: who rides?
SELECT subscriber_type, COUNT(*) AS rides
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE start_time >= '2023-01-01' AND start_time < '2024-01-01'
GROUP BY subscriber_type
ORDER BY rides DESC;

-- Activity 02 · Step 1: your dataset, in the US like the public data
CREATE SCHEMA IF NOT EXISTS bikes OPTIONS (location = 'US');

-- Activity 02 · Step 2: one row per day
CREATE OR REPLACE VIEW bikes.v_days AS
WITH daily AS (
  SELECT DATE(start_time) AS day, COUNT(*) AS trips
  FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips`
  WHERE start_time >= '2023-01-01' AND start_time < '2024-01-01'
  GROUP BY day
),
weather AS (
  SELECT date AS day, `max` AS max_temp_f, prcp AS rain_in
  FROM `bigquery-public-data.noaa_gsod.gsod2023`
  WHERE stn = '722544'
)
SELECT day, trips, max_temp_f, rain_in,
       CASE WHEN rain_in >= 0.25 THEN 'Rain'
            WHEN max_temp_f >= 100 THEN 'Hot'
            ELSE 'Other' END AS day_type,
       FORMAT_DATE('%a', day) AS weekday,
       FORMAT_DATE('%b', day) AS month_name,
       IF(MOD(UNIX_DATE(day), 5) = 0, 'test', 'train') AS split
FROM daily JOIN weather USING (day);

SELECT COUNT(*) AS days, SUM(trips) AS trips FROM bikes.v_days;

-- Activity 02 · Step 3: one row per trip, with three rider groups
CREATE OR REPLACE VIEW bikes.v_trips AS
SELECT trip_id,
       DATE(start_time) AS day,
       EXTRACT(HOUR FROM start_time) AS start_hour,
       start_station_name,
       CASE WHEN subscriber_type LIKE '%Student%' THEN 'Student'
            WHEN subscriber_type IN ('Local31', 'Local365', 'Annual', 'Local365+Guest Pass') THEN 'Member'
            ELSE 'Pass or single ride' END AS rider_group,
       bike_type,
       duration_minutes
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE start_time >= '2023-01-01' AND start_time < '2024-01-01';

SELECT rider_group, COUNT(*) AS rides FROM bikes.v_trips GROUP BY rider_group ORDER BY rides DESC;

-- Activity 03 · Step 1: the fixed split
SELECT split, COUNT(*) AS days FROM bikes.v_days GROUP BY split;

-- Activity 03 · Step 2: train on the train days
CREATE OR REPLACE MODEL bikes.trips_model
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['trips'],
         data_split_method = 'NO_SPLIT') AS
SELECT trips, day_type, weekday, month_name
FROM bikes.v_days
WHERE split = 'train';

-- Activity 03 · Step 3: score the test days, against a median guess
SELECT ROUND(mean_absolute_error, 1) AS model_mae,
       ROUND(r2_score, 2) AS r2
FROM ML.EVALUATE(MODEL bikes.trips_model,
                 (SELECT * FROM bikes.v_days WHERE split = 'test'));

WITH guess AS (
  SELECT APPROX_QUANTILES(trips, 2)[OFFSET(1)] AS median_trips
  FROM bikes.v_days WHERE split = 'train'
)
SELECT ANY_VALUE(median_trips) AS median_guess,
       ROUND(AVG(ABS(trips - median_trips)), 1) AS guess_mae
FROM bikes.v_days, guess
WHERE split = 'test';

-- Activity 03 · Step 4: read the weights
SELECT w.processed_input AS feature, cw.category, ROUND(cw.weight, 1) AS weight
FROM ML.WEIGHTS(MODEL bikes.trips_model) AS w, UNNEST(w.category_weights) AS cw
ORDER BY feature, weight;

-- Activity 03 · Step 5: save the predictions as a view
CREATE OR REPLACE VIEW bikes.v_predictions AS
SELECT day, split, day_type, trips, ROUND(predicted_trips) AS predicted_trips
FROM ML.PREDICT(MODEL bikes.trips_model, (SELECT * FROM bikes.v_days));

SELECT SUM(trips) AS actual, SUM(predicted_trips) AS predicted
FROM bikes.v_predictions WHERE split = 'test';
