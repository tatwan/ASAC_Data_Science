# How many babies will be born each day? A forecast, start to finish

In this activity, you will forecast a whole year of daily US births from the fourteen years before it, score the forecast against what really happened, and save the history and the forecast together in one view, ready for a line chart.

**In class:** following along · **Data:** `ml.us_births` (uploaded in "Before you start") → `ml.births_arima`, `ml.v_births_history_forecast` · **Starter:** `Unsolved/births_forecast.sql`

## The story

Hospitals plan staff by the day. FiveThirtyEight published the number of births registered in the United States on every day from 2000 to 2014, for a story about Friday the 13th. The pattern inside is strong: far fewer babies are born at weekends and on holidays, because planned births (inductions and caesareans) are scheduled on working days. A forecast that knows the weekly rhythm and the holidays can tell a hospital what next year looks like, day by day.

This is the same model as D15's Air Passengers, on daily data. If you skipped the forecasting part of D15, this activity is a short version of it.

## What you will learn

- The same five steps for a time series: the label is the series itself, and the split is by date.
- That `HOLIDAY_REGION` lets ARIMA_PLUS model holidays in a daily series.
- To append the forecast to the history with `UNION ALL`, so one view holds both.

## Before you start: upload `us_births.csv`

Each of today's four activities starts by uploading its own file into your `ml` dataset. The four files are in the course GitHub repository, in the folder [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md).

1. **Download the file.** Open [`us_births.csv`](../../../../../shared/datasets/ml_recap/us_births.csv) on GitHub and click **Download raw file** (the downward arrow, top right). Do not open it in Excel and save it again.
2. **Upload it.** Next to `ml`, **⋮** → **Create table**. **Create table from:** Upload; choose `us_births.csv`; **File format:** CSV. **Table:** `us_births`. **Schema:** tick **Auto detect**. **Create table**. The steps are the same as in [Upload a CSV to BigQuery](../../../../02-sql/resources/upload-a-csv-to-bigquery.md).

**Check:** `SELECT COUNT(*) FROM ml.us_births;` returns 5,479, and `birth_date` is a DATE in the table's **Schema** tab.

## Step 1 · Look: one row is one day

```sql
SELECT day_name, ROUND(AVG(births)) AS average_births
FROM ml.us_births
GROUP BY day_name
ORDER BY average_births;
```

**What you should see:** seven rows. Sunday about 7,518 and Saturday 8,563; the weekdays between 11,898 (Monday) and 13,122 (Tuesday). And the story's point: the 25 Fridays that fell on the 13th average 11,950 births, against 12,618 for the other Fridays.

## Step 2 · Create the model on 2000 to 2013

```sql
CREATE OR REPLACE MODEL ml.births_arima
OPTIONS (model_type = 'ARIMA_PLUS',
         time_series_timestamp_col = 'birth_date',
         time_series_data_col = 'births',
         horizon = 365,
         holiday_region = 'US') AS
SELECT birth_date, births
FROM ml.us_births
WHERE birth_date < '2014-01-01';
```

The model trains on 5,114 days and keeps 2014 aside: a time series is split by date, never at random (D15). `horizon = 365` asks for a year of days. `holiday_region = 'US'` adds the US holidays; Google's page applies it only to daily or weekly series longer than a year, which this is.

**What you should see:** the model `births_arima` under `ml`, after a minute or two.

## Step 3 · Evaluate on 2014

```sql
SELECT ROUND(mean_absolute_error) AS mae,
       ROUND(mean_absolute_percentage_error, 1) AS mape_pct
FROM ML.EVALUATE(MODEL ml.births_arima,
       (SELECT birth_date, births FROM ml.us_births
        WHERE birth_date >= '2014-01-01'),
       STRUCT(TRUE AS perform_aggregation, 365 AS horizon));
```

`ML.EVALUATE` forecasts the 365 days of 2014 and compares them with the real ones.

**What you should see:** one row: the average miss in births a day, and the same as a percentage. Compare it with 316, the average miss of a simple forecast, "the same weekday a year earlier". That is a strong bar for daily births, because the weekly rhythm repeats so exactly. If the model misses by less, it has earned its place. If it misses by more, that is a finding too: for this series, last year's same weekday is hard to beat, and a planner could use it. Step 4 shows where the model can still help: holidays, which the simple forecast gets wrong whenever a holiday moves to a different weekday.

## Step 4 · Forecast three days to check

```sql
SELECT DATE(f.forecast_timestamp) AS day,
       ROUND(f.forecast_value) AS forecast,
       b.births AS actual
FROM ML.FORECAST(MODEL ml.births_arima,
       STRUCT(365 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.us_births AS b ON b.birth_date = DATE(f.forecast_timestamp)
WHERE DATE(f.forecast_timestamp) IN ('2014-06-13', '2014-07-04', '2014-12-25')
ORDER BY day;
```

`forecast_timestamp` is a TIMESTAMP; `DATE(…)` turns it back into a day so it joins `birth_date`.

**What you should see:** three rows. The actual births were 11,651 on Friday 13 June, 9,278 on 4 July and 6,749 on Christmas Day. A forecast that dips on 4 July and Christmas has learned the holidays; one that gives a normal weekday there has not.

## Step 5 · History and forecast in one view

```sql
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
```

`UNION ALL` stacks the forecast under the history. Both halves need the same columns in the same order and types, so the history gets empty bounds and `births` becomes a FLOAT64 to match the forecast. The column `series` says which half a row comes from: in Power BI it becomes the legend of a line chart, with the forecast line laid over the real 2014.

**What you should see:** two rows. `actual`: 5,479 days, 2000-01-01 to 2014-12-31. `forecast`: 365 days, 2014-01-01 to 2014-12-31.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 7 | Sunday about 7,518 · Tuesday about 13,122 |
| 3 | 1 | compare the MAE with 316 |
| 4 | 3 | actual 11,651 · 9,278 · 6,749 |
| 5 | 2 | actual 5,479 days · forecast 365 days |

## If something goes wrong

- **`CREATE MODEL` complains about the timestamp column:** `birth_date` arrived as text. Check the table's schema; delete the table and upload again with **Auto detect** ticked.
- **Step 4 returns no rows or a type error:** the join compares a TIMESTAMP with a DATE; keep `DATE(f.forecast_timestamp)` on both lines.
- **Step 5 complains about the types in `UNION ALL`:** keep the `CAST` lines in the first half, so both halves have the same types in the same order.

## Hint

In step 4, look at the forecast for Christmas Day first. Did the model dip, and by how much?

## Bonus

`ML.EXPLAIN_FORECAST(MODEL ml.births_arima, STRUCT(365 AS horizon))` splits each day into trend, weekly and yearly season and holiday effect (D15 lab 10). Which holiday pulls births down most? [Lab 08](../08-Lab-MLOps-Retrain-And-Serve/README.md) retrains on all fifteen years and forecasts 2015.

## References

US births 2000–2014 from the Social Security Administration, published by FiveThirtyEight for "Some People Are Too Superstitious To Have A Baby On Friday The 13th" ([`fivethirtyeight/data`](https://github.com/fivethirtyeight/data/tree/master/births)), CC BY 4.0; course copy in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md), taken 27 October 2026. BigQuery ML: [CREATE MODEL for ARIMA_PLUS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series) (`HOLIDAY_REGION`), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [ML.FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast), Google Cloud.
