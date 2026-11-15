# Austin's bikes, 2023

## The finding

Hot days averaged **622.6** rides, against 830.9 on other days.

## Method

- SQL in BigQuery
- A model in BigQuery ML
  - LINEAR_REG
- A report in Power BI

Data from [Austin open data](https://data.austintexas.gov).

## Rides by day type

| Day type | Days | Rides a day |
|---|---:|---:|
| Hot | 81 | 622.6 |
| Rain | 26 | 769.5 |
| Other | 257 | 830.9 |

## The query

```sql
SELECT day_type, COUNT(*) AS days,
       ROUND(AVG(trips), 1) AS rides_a_day
FROM bikes.v_days
GROUP BY day_type;
```
