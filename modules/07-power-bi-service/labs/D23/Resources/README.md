# D23 data · Austin bike share and the weather

D23 reads two of Google's public BigQuery datasets in place. You do not download or upload anything: your queries run in your own sandbox project, and your views keep only their SQL.

| Table | What one row is | Rows (whole table) | Used for |
|---|---|---:|---|
| `bigquery-public-data.austin_bikeshare.bikeshare_trips` | one bike trip in Austin, Texas | 2,916,659 (December 2013 to August 2026) | 2023 only: 283,964 trips |
| `bigquery-public-data.austin_bikeshare.bikeshare_stations` | one docking station | 101 | Activity 01's join check |
| `bigquery-public-data.noaa_gsod.gsod2023` | one weather station on one day | worldwide | station `722544` (Austin Camp Mabry): 365 days |

**Why 2023.** It is the last full year with one set of rider types. From 24 July 2024 the operator's new system uses different types and has no student type, and 1 to 23 July 2024 has no trips. NOAA's daily weather for Austin is complete for 2023.

## How the tables connect

```mermaid
erDiagram
    bikeshare_stations ||--o{ bikeshare_trips : "station_id = start_station_id"
    gsod2023 ||--o{ bikeshare_trips : "date = DATE(start_time)"
    bikeshare_stations {
        INT64 station_id PK
        STRING name
        INT64 number_of_docks
    }
    bikeshare_trips {
        STRING trip_id PK
        TIMESTAMP start_time
        INT64 start_station_id FK
        STRING start_station_name
        STRING subscriber_type
        FLOAT64 duration_minutes
    }
    gsod2023 {
        STRING stn
        DATE date
        FLOAT64 max
        FLOAT64 prcp
    }
```

A trip joins its station on the station number. A trip joins the weather on its date, after you keep one weather station (`stn = '722544'`). The stations table is out of date: 11 of the 82 station numbers used in 2023 are missing from it, so an inner join would drop 43,975 trips. The activities keep the station name that each trip carries instead.

## Columns you will use

| Column | Meaning |
|---|---|
| `start_time` | when the trip started, Austin local time (stored without a time zone) |
| `subscriber_type` | the rider's pass or membership, for example `Student Membership`, `Local365`, `24 Hour Walk Up Pass` |
| `duration_minutes` | trip length in minutes |
| `max` | the day's highest temperature, °F |
| `prcp` | the day's rain, inches |

## Fixed checks (2023, computed 15 November 2026)

| Check | Value |
|---|---:|
| Trips in 2023 | 283,964 |
| Days with trips | 364 (none on 1 February, during an ice storm) |
| Trips whose station is in the stations table | 239,989 |
| Hot days (100 °F or more, no rain) and their average | 81 days, 622.6 trips |
| Rain days (0.25 in or more) and their average | 26 days, 769.5 trips |
| Other days and their average | 257 days, 830.9 trips |
| Student trips | 145,890 (51.4%) |

Google refreshes the trips table every day. Past trips should stay the same. If a check is off by a few trips, rerun the query and compare.

## Source and terms

- **Austin MetroBike trips and kiosk locations:** City of Austin Open Data portal (data.austintexas.gov), published under the [City of Austin Open Data Terms of Use](https://data.austintexas.gov/stories/s/ranj-cccq); hosted by Google as `bigquery-public-data.austin_bikeshare`.
- **Weather:** NOAA National Centers for Environmental Information, Global Surface Summary of the Day (GSOD); hosted by Google as `bigquery-public-data.noaa_gsod`. The Austin station is a US station; NOAA limits only commercial reuse of non-US stations' data (WMO Resolution 40).
- Accessed 15 November 2026 through the BigQuery console. The course publishes no copy of either dataset.
