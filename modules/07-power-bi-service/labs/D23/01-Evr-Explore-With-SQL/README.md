# Activity 01 · Explore Austin's trips with SQL

Before you build anything for Power BI, you find out what the data can answer. Four queries: how rides change through 2023, whether trips join their stations, how rides change with the weather, and who the riders are.

**Where you are:** **01 Explore** → 02 Views → 03 Model → 04 Connect → 05 Story. You start from three public tables; you hand on four tested queries that Activity 02 saves as views.

**Remember.** `GROUP BY` turns many rows into one per group (D04). A `LEFT JOIN` keeps every row on the left and leaves `NULL` where nothing matched, so counting the right-hand key shows how many matched (D06). A CTE names a step of a query so the next step can read it (D08).

| Step | Question | SQL you use |
|---|---|---|
| 0 | What is one row of the trips table? | The Schema and Preview tabs |
| 1 | How do rides change through the year? | `GROUP BY` a month |
| 2 | Does every trip find its station? | `LEFT JOIN` and `COUNT` of the matched key |
| 3 | Do hot or rainy days have fewer rides? | Two CTEs joined on the date |
| 4 | Who rides? | `GROUP BY` the pass type |

Open a new query tab in BigQuery. The queries read the public tables directly, so there is nothing to upload.

## 0. Meet the trips table before you query it

**Why this step.** A query is only as good as your picture of one row. Before you count anything, find out what one row of `bikeshare_trips` is and which column answers which question.

In the **Explorer** on the left, search for `austin_bikeshare`, open `bigquery-public-data` → `austin_bikeshare` and select `bikeshare_trips`.

1. Open the **Schema** tab. *Why:* it lists every column and its type, and reads no data.
2. Open the **Preview** tab. *Why:* it shows real rows for free, unlike `SELECT *`, which reads the whole table.
3. Open the **Details** tab and note the number of rows.

**C0.** Ten columns. One row is one trip. Sort them into four groups:

| Group | Columns | The question they answer |
|---|---|---|
| When | `start_time` | When was the trip? |
| Where | `start_station_id`, `start_station_name`, `end_station_id`, `end_station_name` | From which station, to which? |
| Who | `subscriber_type`, `bike_id`, `bike_type` | Which kind of rider, on which bike? |
| How long | `duration_minutes` | How long was the trip? |

`trip_id` is the key: one value per trip. Each column is explained in [Resources](../Resources/README.md#the-trips-table-column-by-column).

**What just happened.** Every query below reads one group. Step 1 reads *when*, step 2 *where*, step 3 *when* joined to the weather, step 4 *who*. Naming the group first tells you which columns to select, and therefore what the query costs.


## 1. Rides by month

 

**Why this step.** A first count tells you the size and the shape of the data before you trust any comparison. One year is enough to see a pattern.

```sql
SELECT FORMAT_DATE('%m', DATE(start_time)) AS month_number,
       COUNT(*) AS rides
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE start_time >= '2023-01-01' AND start_time < '2024-01-01'
GROUP BY month_number
ORDER BY month_number;
```

**C1.** Twelve rows that add up to 282,696 rides. October is the busiest month (38,727) and June the quietest (14,877).

Before you run it, the editor says the query will read about 23 MB. BigQuery charges by the columns it reads, and this query reads only `start_time`.

## 2. Join the stations, and count what matches

**Why this step.** A join can lose rows without telling you. `LEFT JOIN` keeps every trip; counting the station key on the right side tells you how many trips found their station.

```sql
SELECT COUNT(*) AS rides,
       COUNT(st.station_id) AS rides_with_a_station,
       COUNT(DISTINCT t.start_station_id) AS station_ids,
       COUNT(DISTINCT IF(st.station_id IS NULL, t.start_station_id, NULL)) AS ids_not_found
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS t
LEFT JOIN `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS st
  ON st.station_id = t.start_station_id
WHERE t.start_time >= '2023-01-01' AND t.start_time < '2024-01-01';
```

`COUNT(st.station_id)` counts only the rows where the right side found a match; unmatched rows have `NULL` there.

**C2.** 282,696 rides, of which 238,886 have a station. 11 of the 82 station numbers are not in the stations table. An inner join would have dropped 43,810 trips. Each trip also stores its station's name, so the views in Activity 02 use that and skip the stations table.

## 3. Join each day's rides to the day's weather

**Why this step.** The question is about days, so you first turn trips into one row per day, then join the weather for the same day. Two CTEs keep each step readable.

```sql
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
```

`max` is a column name that is also a function, so it needs backticks. A **Hot** day reached 100 °F or more without heavy rain; a **Rain** day had a quarter of an inch or more.

**C3.** Hot: 81 days, 614.8 rides on average. Rain: 26 days, 767.9. Other: 257 days, 828.5. The three day counts add up to 364, not 365: on 1 February 2023, during an ice storm, no trips were recorded.

Hot days have about a quarter fewer rides than other days. Keep that number in mind; Activity 03 tests it.

## 4. Who rides?

**Why this step.** A pattern in the totals often comes from one group of people. Knowing who rides tells you where to look.

```sql
SELECT subscriber_type, COUNT(*) AS rides
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE start_time >= '2023-01-01' AND start_time < '2024-01-01'
GROUP BY subscriber_type
ORDER BY rides DESC;
```

**C4.** `Student Membership` is first with 145,689 rides, more than half of the year. The busiest station, `21st/Speedway @ PCL`, is the University of Texas main library.

**What just happened.** You counted, joined and grouped three public tables without copying them. The data has holes: a stations table that misses 11 stations and a day with no trips. And the riders are mostly students. Hot days fall in June to September, when the university is mostly on summer break. So is it the heat, or the calendar? Activity 03 separates the two.
