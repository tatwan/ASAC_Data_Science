# Austin's bikes, 2023

**Finding:** WRITE YOUR FINDING IN ONE SENTENCE, WITH ITS NUMBER.

![Story page: average rides by month and by day type](images/story-page.png)

*WRITE ONE LINE SAYING WHAT TO LOOK AT IN THE SCREENSHOT.*

## The question

Austin's bike-share riders took 283,964 trips in 2023, and hot days had fewer rides than other days. Is it the heat?

## The data

- Austin MetroBike trips, City of Austin Open Data, read in BigQuery as `bigquery-public-data.austin_bikeshare` ([terms of use](https://data.austintexas.gov/stories/s/ranj-cccq)).
- Daily weather for Austin Camp Mabry (station 722544), NOAA Global Surface Summary of the Day, `bigquery-public-data.noaa_gsod`.
- Calendar year 2023: 364 days with trips.

## Method

1. SQL in BigQuery to count rides by day and join each day to its weather.
2. Views (`v_days`, `v_trips`) as the hand-off to Power BI.
3. A linear regression in BigQuery ML on day type, weekday and month, tested on days it never saw.
4. A Power BI report: the views in Import and DirectQuery, one story page, published.

All the SQL is in [sql/d23_bigquery.sql](sql/d23_bigquery.sql).

## More findings

- WRITE A SECOND FINDING WITH ITS NUMBER.
- WRITE A THIRD FINDING WITH ITS NUMBER.

## Limits

- WRITE ONE THING THIS ANALYSIS CANNOT SAY, AND WHY.
- WRITE A SECOND LIMIT.

## Tools

SQL · BigQuery · BigQuery ML · Power BI (Power Query, DAX, DirectQuery)
