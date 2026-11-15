# D23 · Austin's bikes, from BigQuery to a published report

Austin, Texas, has a public bike-share system with about 80 docking stations. In 2023 its riders took 283,964 trips. On the hottest days there were fewer of them. Is it the heat? Today you answer that question end to end: SQL in BigQuery, views for Power BI, one BigQuery ML model, the BigQuery connector in Import and DirectQuery, a story page, and a published report that refreshes without a gateway.

| Activity | Where | What you build | Check |
|---|---|---|---|
| [01 Explore with SQL](01-Evr-Explore-With-SQL/README.md) | BigQuery | Four queries on trips, stations and weather | Hot days average 622.6 trips |
| [02 Views for Power BI](02-Evr-Views-For-Power-BI/README.md) | BigQuery | `bikes.v_days` and `bikes.v_trips` | 364 days, 283,964 trips |
| [03 Train and score a model](03-Evr-Train-And-Score-A-Model/README.md) | BigQuery ML | `bikes.trips_model` and `bikes.v_predictions` | Test error 171.4 against 271.1 |
| [04 Connect: Import and DirectQuery](04-Evr-Connect-Import-And-DirectQuery/README.md) | Power BI Desktop | Two views imported, one queried live | Both cards show 283,964 |
| [05 Story page and publish](05-Evr-Story-Page-And-Publish/README.md) | Power BI | One story page in My workspace | No gateway needed |
| [06 Lab: who rides when](06-Lab-Who-Rides-When/README.md) | Power BI | The student share by month (after class) | September 66.3% |

## Before you start

- **BigQuery:** your sandbox project from the SQL weeks. Open the [BigQuery console](https://console.cloud.google.com/bigquery) signed in with the same Google account. Nothing to upload: the data is public ([what the tables are](Resources/README.md)).
- **Power BI Desktop**, signed in with your course account. Activities 04 and 05 use Desktop: the BigQuery connector, DirectQuery and the storage-mode switch are Desktop features. If you work on a Mac with the browser only, follow Tarek's screen for 04 and 05; Activity 05's publishing steps work the same on your free account once you have a file.
- The whole SQL is in [d23_bigquery.sql](Resources/d23_bigquery.sql) if you fall behind: copy the part you need.

**Check:** in BigQuery, run ``SELECT COUNT(*) FROM `bigquery-public-data.austin_bikeshare.bikeshare_stations`;`` and get 101.

## Your account

| Step | Free account | Trial or Pro |
|---|---|---|
| Activities 01–03 in the BigQuery sandbox | Yes | Yes |
| Connect, Import and DirectQuery in Desktop | Yes | Yes |
| Publish to My workspace and set the credentials | Yes | Yes |
| Share the report with a classmate | No | Yes |

**Cost.** The sandbox gives you 1 TiB of queries a month. Every query today reads between 1 MB and about 200 MB. The whole day uses about 2 GB.
