# Lab 13 (optional, self-study) · Nakheel's daily revenue

In this optional self-guided lab, you will build Nakheel's daily revenue series from its orders, split it by date, score three simple forecasts and an ARIMA_PLUS model on the days held aside, try the custom-holiday route for Jordan's Eid holidays, and save a 30-day forecast for D22.

**When:** after labs 09 to 12, at your own pace, about 45 minutes. Optional; not submitted. · **Data:** `nakheel.orders` (D04 activity 03) → the views `ml.nakheel_daily`, `ml.revenue_training`, `ml.revenue_validation` and the table `ml.revenue_forecast` · **SQL:** `Unsolved/nakheel_daily_revenue.sql` to run step by step, `Solved/nakheel_daily_revenue.sql`

## The story

Nakheel's managers ask the planner's question about their own shops: how much revenue should we expect each day next month? Air Passengers was clean, monthly and smooth. Company data is not: a day can have no orders, one wholesale customer can triple a day, and the last days of the file are still open. This lab puts the class's method on that data and shows where it holds and where it struggles.

## What you will learn

- To build a daily series from an order log: completed orders only, one row per day, zero on days without a sale.
- To spot incomplete days at the end of a snapshot, and to stop the series before them.
- To set `DATA_FREQUENCY = 'DAILY'`, and to use a custom holiday table where `HOLIDAY_REGION` has no code for your country.
- To judge a noisy forecast honestly against simple ones.

## Before you start

You need the `nakheel` tables from D04. Check: `SELECT COUNT(*) FROM nakheel.orders;` returns 3,000. If they are missing, upload the files in [`shared/datasets/nakheel`](../../../../../shared/datasets/nakheel/README.md) as its README describes.

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. The plain-SQL values are exact. The ARIMA_PLUS results on this series have not been computed outside BigQuery; the steps say what to compare.

## Step 1 · What counts as revenue

```sql
SELECT status, COUNT(*) AS order_count, MIN(order_date) AS first_day, MAX(order_date) AS last_day
FROM nakheel.orders
GROUP BY status
ORDER BY order_count DESC;
```

The Nakheel README defines the columns: `status` is `completed`, `cancelled` or `pending` ("placed, not yet delivered"), and `order_total` is "Value of the goods on the order, in dinars, before shipping". Daily revenue here is the sum of `order_total` over **completed** orders, by `order_date`. Cancelled orders never became revenue; pending ones have not yet.

**What you should see:** 3 rows: completed 2,771, cancelled 212, pending 17. All 17 pending orders were placed between 2026-08-27 and 2026-08-31, the last five days of the file.

## Step 2 · One row per day

```sql
CREATE OR REPLACE VIEW ml.nakheel_daily AS
SELECT order_day,
       IFNULL(SUM(o.order_total), 0) AS revenue,
       COUNT(o.order_id) AS completed_orders
FROM UNNEST(GENERATE_DATE_ARRAY('2024-09-01', '2026-08-31')) AS order_day
LEFT JOIN nakheel.orders AS o
  ON o.order_date = order_day AND o.status = 'completed'
GROUP BY order_day;

SELECT COUNT(*) AS days, MIN(order_day) AS first_day, MAX(order_day) AS last_day,
       COUNTIF(revenue = 0) AS days_without_revenue,
       ROUND(AVG(revenue), 2) AS average_day, MAX(revenue) AS best_day_revenue,
       ROUND(SUM(revenue), 2) AS total_revenue
FROM ml.nakheel_daily;
```

`GENERATE_DATE_ARRAY` makes one row for every day in the range, and the `LEFT JOIN` keeps the days with no completed order, with revenue 0 (D07's left join). Without it, a day with no sale would simply be missing, and ARIMA_PLUS would fill it by interpolation as if sales had happened.

**What you should see:** 730 days, 2024-09-01 to 2026-08-31; 20 days without revenue; an average day of 432.91 dinars; the best day 3,926 dinars; 316,023.50 in total.

## Step 3 · Look before you model

```sql
SELECT order_day, revenue, completed_orders
FROM ml.nakheel_daily
WHERE order_day >= '2026-08-20'
ORDER BY order_day;

SELECT FORMAT_DATE('%A', order_day) AS weekday, ROUND(AVG(revenue), 2) AS average_revenue, COUNT(*) AS days
FROM ml.nakheel_daily
WHERE order_day < '2026-08-01'
GROUP BY weekday
ORDER BY average_revenue DESC;
```

**What you should see:** first, the last 12 days: the five days from 27 August hold 163.70 dinars on average against 432.91 for the whole series, because their pending orders are not revenue yet. Those days are incomplete, not quiet. Second, 7 rows: Saturday is the best day on average (467.61), Friday the weakest (350.95), and the other days are close together. The weekly pattern is weak next to the day-to-day noise (the best day is nine times the average).

## Step 4 · Split by date

```sql
CREATE OR REPLACE VIEW ml.revenue_training AS
SELECT order_day, revenue FROM ml.nakheel_daily
WHERE order_day < '2026-08-01';

CREATE OR REPLACE VIEW ml.revenue_validation AS
SELECT order_day, revenue FROM ml.nakheel_daily
WHERE order_day >= '2026-08-01' AND order_day < '2026-08-27';

SELECT 'training' AS revenue_group, COUNT(*) AS days, ROUND(AVG(revenue), 2) AS average_day FROM ml.revenue_training
UNION ALL
SELECT 'validation', COUNT(*), ROUND(AVG(revenue), 2) FROM ml.revenue_validation;
```

The class's rule, by date: the model learns from every day before 1 August 2026 and is scored on 1 to 26 August. The five days from 27 August are left out of both, because they are incomplete. With 26 days of validation and no separate test period, this lab compares and stops; it does not make a final claim.

**What you should see:** training 699 days (average 433.42), validation 26 days (average 470.88).

## Step 5 · Three simple forecasts

```sql
SELECT 'naive: 31 July held flat' AS forecast_method,
       ROUND(AVG(ABS(v.revenue - (SELECT revenue FROM ml.revenue_training ORDER BY order_day DESC LIMIT 1))), 2) AS mae
FROM ml.revenue_validation AS v
UNION ALL
SELECT 'seasonal naive: same weekday, last training week',
       ROUND(AVG(ABS(v.revenue - t.revenue)), 2)
FROM ml.revenue_validation AS v
JOIN ml.revenue_training AS t
  ON t.order_day >= '2026-07-25'
 AND FORMAT_DATE('%A', t.order_day) = FORMAT_DATE('%A', v.order_day)
UNION ALL
SELECT 'training mean held flat',
       ROUND(AVG(ABS(v.revenue - (SELECT AVG(revenue) FROM ml.revenue_training))), 2)
FROM ml.revenue_validation AS v
ORDER BY mae;
```

The daily versions of activity 03's forecasts. The seasonal naive repeats the last training week (25 to 31 July) day of the week by day of the week: the season here is the week, not the year.

**What you should see:** 3 rows: naive 294.65, training mean 302.56, seasonal naive 475.94 dinars a day. Repeating last week does worst: one big day in that week (29 July, 1,369.50) is copied onto every later Wednesday. On noisy daily data, the flat forecasts win.

## Step 6 · ARIMA_PLUS, daily

```sql
CREATE OR REPLACE MODEL ml.revenue_arima
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'order_day',
         TIME_SERIES_DATA_COL = 'revenue',
         DATA_FREQUENCY = 'DAILY',
         HORIZON = 30) AS
SELECT order_day, revenue FROM ml.revenue_training;

SELECT non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift, seasonal_periods,
       has_spikes_and_dips, has_step_changes
FROM ML.ARIMA_EVALUATE(MODEL ml.revenue_arima, STRUCT(FALSE AS show_all_candidate_models));
```

`DATA_FREQUENCY = 'DAILY'` says what the default `AUTO_FREQUENCY` would infer; writing it makes the custom holiday route in step 8 possible. No `HOLIDAY_REGION`: Jordan (JO) is not on Google's list of holiday regions. The nearby codes (`AE`, `SA`, `EG`, `IL`, `TR` and the continental `EMEA`) are other countries' calendars.

**What you should see:** one row. Look at `seasonal_periods`: did the model find a `WEEKLY` season in this noise? Look at `has_spikes_and_dips` too: the best days are far above the rest, and the default `CLEAN_SPIKES_AND_DIPS` cleans any it detects as spikes before fitting.

## Step 7 · Score it on 1 to 26 August

```sql
SELECT ROUND(AVG(ABS(v.revenue - f.forecast_value)), 2) AS mae_arima,
       COUNTIF(v.revenue BETWEEN f.prediction_interval_lower_bound
                             AND f.prediction_interval_upper_bound) AS days_inside,
       COUNTIF(f.prediction_interval_lower_bound < 0) AS days_lower_bound_below_zero
FROM ML.FORECAST(MODEL ml.revenue_arima, STRUCT(26 AS horizon, 0.95 AS confidence_level)) AS f
JOIN ml.revenue_validation AS v ON DATE(f.forecast_timestamp) = v.order_day;
```

**What you should see:** one row. Compare `mae_arima` with step 5's three. A forecast near the series' average will score close to the training mean's 302.56; beating it by much is unlikely when single days swing from 0 to thousands. Many lower bounds will be below zero: the interval is honest about the noise, and revenue cannot be negative.

**Think:** for a manager, is a daily forecast with a miss of about 300 dinars on a 470-dinar day useful? What would you forecast instead (a week's total, a month's)?

## Step 8 · Optional: Jordan's holidays as a custom holiday table

`HOLIDAY_REGION` has no code for Jordan, but the CREATE MODEL page documents a route for it: leave `HOLIDAY_REGION` out and give the model your own holiday table. The page's words for this case: "To model only custom holidays, don't specify a value for the HOLIDAY_REGION option, and provide the new holiday metadata in the holiday_statement argument." The query's `AS` part then has two named parts, `training_data` and `custom_holiday`.

First, the dates. Eid dates follow the moon sighting, are announced shortly before each Eid, and published calendars made in advance can be a day out. Look up the first day of Eid al-Fitr and of Eid al-Adha in 2025 and in 2026 in Jordan's official public-holiday announcements, and type each one in place of a `YYYY-MM-DD` below. Until you do, BigQuery stops with an error about the date literal, which is what should happen.

```sql
CREATE OR REPLACE MODEL ml.revenue_arima_eid
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'order_day',
         TIME_SERIES_DATA_COL = 'revenue',
         DATA_FREQUENCY = 'DAILY',
         HORIZON = 30) AS (
  training_data AS (
    SELECT order_day, revenue FROM ml.revenue_training
  ),
  custom_holiday AS (
    -- Replace each YYYY-MM-DD with the first day of that Eid, from Jordan's official announcement.
    SELECT 'jordan' AS region, 'Eid_al_Fitr' AS holiday_name, DATE 'YYYY-MM-DD' AS primary_date,  -- 2025
           1 AS preholiday_days, 3 AS postholiday_days
    UNION ALL
    SELECT 'jordan', 'Eid_al_Fitr', DATE 'YYYY-MM-DD', 1, 3  -- 2026
    UNION ALL
    SELECT 'jordan', 'Eid_al_Adha', DATE 'YYYY-MM-DD', 1, 4  -- 2025
    UNION ALL
    SELECT 'jordan', 'Eid_al_Adha', DATE 'YYYY-MM-DD', 1, 4  -- 2026
  )
);

SELECT has_holiday_effect, seasonal_periods
FROM ML.ARIMA_EVALUATE(MODEL ml.revenue_arima_eid, STRUCT(FALSE AS show_all_candidate_models));
```

The page's rules for the holiday table:

| Column | Rule |
|---|---|
| `region` | Required. An upper-case region code, or "An arbitrary string" for a custom region. Lower-case `jordan` cannot clash with a real code: "Because the argument is case-sensitive, you could specify ca, California, or some other value that isn't a holiday region code." |
| `holiday_name` | Required. "The string must be a valid column name so that it can be used in ML.EXPLAIN_FORECAST output", so no spaces: `Eid_al_Fitr` |
| `primary_date` | Required. A DATE, the day the holiday falls on |
| `preholiday_days`, `postholiday_days` | Optional, default 1 and at least 1. The window runs from `primary_date` minus the first to `primary_date` plus the second; it must be at most 30 days and "the same across the given holiday" |

The windows above (one day before; three days after Eid al-Fitr, four after Eid al-Adha) are a choice, not a rule: change them to match the days off in the announcement, keeping the same window for both years of one Eid. Custom holidays work only with `DATA_FREQUENCY` `DAILY` (or `AUTO_FREQUENCY` on daily data), and such a model cannot use `TRANSFORM`. The page also says holiday effects apply only to a series "longer than a year" and are "effective only for approximately 5 years". Both 2026 Eids fall inside the training days; the page advises listing every occurrence you have, past and future.

**What you should see:** one row; read `has_holiday_effect`. If it is TRUE, `ML.EXPLAIN_FORECAST` on this model has `holiday_effect_Eid_al_Fitr` and `holiday_effect_Eid_al_Adha` columns; look at the days around the first Eid al-Fitr date you entered. Score the model with step 7's query (change the model name). Two Eids of each kind in the training days is very little evidence, so expect a small change at most.

## Step 9 · Save 30 days for D22

Train on every complete day, up to 26 August, then save the next 30 days as a table:

```sql
CREATE OR REPLACE MODEL ml.revenue_arima_final
OPTIONS (MODEL_TYPE = 'ARIMA_PLUS',
         TIME_SERIES_TIMESTAMP_COL = 'order_day',
         TIME_SERIES_DATA_COL = 'revenue',
         DATA_FREQUENCY = 'DAILY',
         HORIZON = 30) AS
SELECT order_day, revenue FROM ml.nakheel_daily
WHERE order_day < '2026-08-27';

CREATE OR REPLACE TABLE ml.revenue_forecast AS
SELECT DATE(forecast_timestamp) AS forecast_day,
       ROUND(GREATEST(forecast_value, 0), 2) AS forecast_revenue,
       ROUND(GREATEST(prediction_interval_lower_bound, 0), 2) AS lower_95,
       ROUND(prediction_interval_upper_bound, 2) AS upper_95
FROM ML.FORECAST(MODEL ml.revenue_arima_final, STRUCT(30 AS horizon, 0.95 AS confidence_level));

SELECT table_name, column_name
FROM ml.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'revenue_forecast'
  AND LOWER(table_name) = LOWER(column_name);
```

`GREATEST(…, 0)` keeps negative values out of the report. Why not `FORECAST_LIMIT_LOWER_BOUND = 0` (lab 09, step 14)? Its page says "all values less than or equal to the FORECAST_LIMIT_LOWER_BOUND value are excluded from modeling", so the 20 days with zero revenue would be dropped from training. Clipping after the forecast leaves the training data alone.

**What you should see:** `ml.revenue_forecast` with 30 rows, 27 August to 25 September 2026, and no rows from the name check. On D22 Power BI reads it beside `ml.air_forecast`.

## More practice (not checked, not submitted)

- Forecast weekly revenue instead: build a view with `DATE_TRUNC(order_day, WEEK)` and `SUM(revenue)`, train with `DATA_FREQUENCY = 'WEEKLY'`, and compare the size of the miss with the weekly total.
- Train on the logarithm of daily revenue (lab 09, step 15). What goes wrong on the 20 days with zero revenue, and how would you handle them?
- Store and online as two series in one model, with `TIME_SERIES_ID_COL = 'channel'` (lab 09, step 17), daily.

## What you saw

| Forecast | MAE on 1 to 26 August (dinars a day) |
|---|---:|
| naive | 294.65 |
| training mean | 302.56 |
| seasonal naive (last week) | 475.94 |
| ARIMA_PLUS | |
| ARIMA_PLUS with Eid holidays | |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 3 | completed **2,771** · cancelled **212** · pending **17**, from **2026-08-27** to **2026-08-31** |
| 2 | 1 | **730** days · **20** without revenue · average **432.91** · best day **3,926** · total **316,023.5** |
| 3 | 12 and 7 | Saturday **467.61** · Friday **350.95** |
| 4 | 2 | training **699** days, average **433.42** · validation **26** days, average **470.88** |
| 5 | 3 | naive **294.65** · training mean **302.56** · seasonal naive **475.94** |

## Hint

If a model's forecast hugs the average, look at the noise before blaming the model: step 3's best day is nine times the average day. A forecast can only be as steady as what it forecasts.

## Bonus

Which day was the best day of the two years, and was it near an Eid? (`SELECT order_day, revenue FROM ml.nakheel_daily ORDER BY revenue DESC LIMIT 5`. The best day is 2 June 2026, with 3,926 dinars.)

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026; see [the dataset README](../../../../../shared/datasets/nakheel/README.md) for `status` and `order_total`. BigQuery ML: [CREATE MODEL for ARIMA_PLUS](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series) (`DATA_FREQUENCY`, `HOLIDAY_REGION` and its list, custom holidays, `FORECAST_LIMIT_LOWER_BOUND`), [ML.FORECAST](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-forecast), [ML.ARIMA_EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-arima-evaluate), Google Cloud. All pages read 19 October 2026.
