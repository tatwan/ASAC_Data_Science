# Lab 06 · Solution: who rides when

## Answers

| Check | Value | Why |
|---|---:|---|
| C1 Student share, whole year | 51.4% | 145,890 student rides of 283,964 |
| C2 September | 66.3% | 23,420 of 35,320 |
| C2 October | 64.9% | 25,135 of 38,728 |
| C2 May | 24.6% | 4,294 of 17,460 |
| C2 June | 26.6% | 4,292 of 16,144 |
| C2 December | 49.0% | 8,696 of 17,746; the term ends on 11 December |

The measure's filter, `v_trips[rider_group] = "Student"`, replaces any filter on `rider_group` and keeps the month filter that arrives from `v_days` through the relationship. The denominator keeps the month filter too, so each month's share is that month's students over that month's rides.

## The same numbers in BigQuery

| Power BI | BigQuery SQL |
|---|---|
| `COUNTROWS ( v_trips )` by month | `COUNT(*) … GROUP BY` the month |
| `CALCULATE ( …, v_trips[rider_group] = "Student" )` | `COUNTIF(rider_group = 'Student')` |
| `DIVIDE` | `SAFE_DIVIDE` |

```sql
SELECT FORMAT_DATE('%m', day) AS month_number,
       COUNT(*) AS rides,
       COUNTIF(rider_group = 'Student') AS student_rides,
       ROUND(100 * SAFE_DIVIDE(COUNTIF(rider_group = 'Student'), COUNT(*)), 1) AS student_share_pct
FROM bikes.v_trips
GROUP BY month_number
ORDER BY month_number;
```

## A finding that works

*In September and October about two thirds of rides are students'; in May and June about a quarter are. The quiet months follow the university calendar, so plan maintenance and station moves for the summer break.*
