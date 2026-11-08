# Solution: activity 02, the dates table

## The answers

| Step | Value |
|---|---|
| 1 | `dates`: 1,096 rows, 2024-01-01 to 2026-12-31, type **Date** |
| 2 | six columns: `date`, `year`, `month_no`, `month`, `year_month`, `fiscal_year`; 2025-09-01 → 2025-26; 2024-01-01 → 2023-24 |
| 3 | `month` sorted by `month_no`: January first |
| 4 | `dates` marked on `date`; Auto date/time off |

Bonus: until activity 03 relates `dates` to `sales_lines`, a month on the axis cannot filter the lines, so every bar shows the same total, 316,023.50.

## Why this route works

**Mark as date table** validates unique dates, no blanks, no missing days and, for a Date/Time column, the same time component on every value. `sales_lines[order_date]` repeats dates (7,516 rows for 714 dates) and has 16 missing days within the sales period, so it cannot be the calendar. Building `dates` in Power Query keeps it with the other tables; DAX's `CALENDAR` is another way to generate a date table.

**If dates do not match:** check for a time component. A Date/Time at midnight can match a date; another time on that day will not. Set both relationship columns to **Date** in Power Query so they match by calendar day.

## The same work in SQL (BigQuery)

| Power Query step | SQL |
|---|---|
| `List.Dates` → To Table | `UNNEST(GENERATE_DATE_ARRAY('2024-01-01', '2026-12-31')) AS date` |
| Year, Month, Name of Month | `EXTRACT(YEAR FROM date)`, `EXTRACT(MONTH FROM date)`, `FORMAT_DATE('%B', date)` |
| `year_month` | `FORMAT_DATE('%Y-%m', date)` |
| `fiscal_year` | a `CASE` on `EXTRACT(MONTH FROM date) >= 9` |

```sql
SELECT date,
       EXTRACT(YEAR FROM date) AS year,
       EXTRACT(MONTH FROM date) AS month_no,
       FORMAT_DATE('%B', date) AS month,
       FORMAT_DATE('%Y-%m', date) AS year_month
FROM UNNEST(GENERATE_DATE_ARRAY('2024-01-01', '2026-12-31')) AS date;   -- 1,096 rows
```

Sort by column and Mark as date table have no SQL counterpart: they are settings of the model, not of the data.
