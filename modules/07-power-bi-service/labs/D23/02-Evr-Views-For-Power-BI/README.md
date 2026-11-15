# Activity 02 · Save two views for Power BI

Power BI should not have to know how you cleaned and joined the data. You save the work as two views in your own dataset: one row per day with its weather, and one row per trip with a simple rider group. Power BI reads the views as if they were tables.

| Step | What you need | SQL |
|---|---|---|
| 1 | A dataset of your own, in the same location as the public data | `CREATE SCHEMA` |
| 2 | One row per day: rides, weather, day type | `CREATE VIEW` |
| 3 | One row per trip with three rider groups | `CREATE VIEW` |

## 1. Create the `bikes` dataset

**Why this step.** A view lives in a dataset. The public data is stored in the US, and a query cannot join tables from different locations, so your dataset must be in the US too.

```sql
CREATE SCHEMA IF NOT EXISTS bikes OPTIONS (location = 'US');
```

**C1.** Refresh the Explorer: `bikes` appears under your project.

## 2. The day view, `bikes.v_days`

**Why this step.** Activity 01's day-and-weather query becomes a view, with four more columns that the model and the report need. A view stores the query, not the rows, so it uses none of your 10 GiB of sandbox storage, and it shows new trips whenever the source changes.

```sql
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
```

`split` marks every fifth day as a test day. `UNIX_DATE` numbers the days, so the split is fixed: it is the same every time anyone runs the view. Activity 03 explains why the model needs it.

```sql
SELECT COUNT(*) AS days, SUM(trips) AS trips FROM bikes.v_days;
```

**C2.** 364 days and 283,964 trips, the same total as Activity 01.

## 3. The trip view, `bikes.v_trips`

**Why this step.** The report also needs trip-level detail: which hour, which station, which kind of rider. 2023 has 11 pass types; three groups are easier to read. The view keeps `day` as a date and the hour as a number, because Power BI's DirectQuery cannot use BigQuery's date-and-time columns (Activity 04).

```sql
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
```

```sql
SELECT rider_group, COUNT(*) AS rides
FROM bikes.v_trips
GROUP BY rider_group
ORDER BY rides DESC;
```

**C3.** Student 145,890; Member 70,299; Pass or single ride 67,775. They add up to 283,964.

**What just happened.** Your dataset holds two views and no data. Each time Power BI, or you, reads `bikes.v_days`, BigQuery runs its query against the public tables. That is why the view costs nothing to store, and also why reading it reads the source again: about 146 MB for `v_days`, 200 MB for all of `v_trips`. Sandbox views expire after 60 days; rerun the `CREATE` statements if yours has gone.
