# D23 · Austin's bikes, from BigQuery to a published report

Austin, Texas, has a public bike-share system with about 80 docking stations. In 2023 its riders took 282,696 trips. On the hottest days there were fewer of them. Is it the heat? Today you answer that question end to end: SQL in BigQuery, views for Power BI, one BigQuery ML model, the BigQuery connector in Import and DirectQuery, a story page, and a published report that refreshes without a gateway.

| Activity | Where | What you build | Check |
|---|---|---|---|
| [01 Explore with SQL](01-Evr-Explore-With-SQL/README.md) | BigQuery | Four queries on trips, stations and weather | Hot days average 614.8 trips |
| [02 Views for Power BI](02-Evr-Views-For-Power-BI/README.md) | BigQuery | `bikes.v_days` and `bikes.v_trips` | 364 days, 282,696 trips |
| [03 Train and score a model](03-Evr-Train-And-Score-A-Model/README.md) | BigQuery ML | `bikes.trips_model` and `bikes.v_predictions` | Test error about 171 against 274 |
| [04 Connect: Import and DirectQuery](04-Evr-Connect-Import-And-DirectQuery/README.md) | Power BI Desktop | Two views imported, one queried live | Both cards show 282,696 |
| [05 Story page and publish](05-Evr-Story-Page-And-Publish/README.md) | Power BI | One story page in My workspace | No gateway needed |
| [06 Lab: who rides when](06-Lab-Who-Rides-When/README.md) | Power BI | The student share by month (after class) | September 66.3% |

## The route, end to end

Each activity takes the previous one's result and hands on its own. If you lose the thread, find your step here.

| Step | You start with | You make | Why it is needed | The idea, and where you met it |
|---|---|---|---|---|
| 01 Explore | three public tables | four answers in SQL | to know what the data can answer before building anything | GROUP BY, LEFT JOIN, CTEs (D04–D08) |
| 02 Views | Activity 01's queries | `v_days` (one row per day) and `v_trips` (one row per trip) | Power BI and the model need clean tables at the right grain | views (D08) |
| 03 Model | `v_days` | `trips_model`, its weights and `v_predictions` | to separate the heat from the school calendar | linear regression, MAE, a fixed test split (D11, D12, D14) |
| 04 Connect | the three views | a Power BI model: two tables imported, one in DirectQuery | to read BigQuery from Power BI and see both storage modes | storage modes (D22), relationships (D18) |
| 05 Story | the Power BI model | one story page, published, refreshing with no gateway | to tell the finding to a reader | a supported finding (D21), gateways (D22) |
| 06 Lab | the published report | the student share by month | to test the model's claim with the data | CALCULATE and DIVIDE (D19) |

The question all day: **Austin's riders took fewer trips on the hottest days. Is it the heat?**

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
