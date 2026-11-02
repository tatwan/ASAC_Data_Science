# Solution · Lab 11: targets against actuals

The [lab instructions](../README.md) carry the screens and the click path. This page gives the answers, why the route works, and the same work in SQL.

## The answers

| Checkpoint | Query | Answer |
|---|---|---|
| C1 | `store_targets` | 11 rows, 13 columns: one row is one shop (kept wide, **Enable load** off) |
| C1 | `targets_long` | 132 rows (11 × 12): one row is one shop in one month; targets 110,000 |
| C2 | `actuals_by_month` | 125 rows: seven shop-months had no completed sale; 107,595.00 |
| C3 | `targets_vs_actuals` | 132 rows; `met_target` = yes in **61**; the seven months without sales read 0 |
| C3 | `targets_by_store` | 11 rows; 107,595.00 against 110,000. Met the year: **NK-AMM-03** 11,494.50 / 11,300 · **NK-IRB-01** 19,191.00 / 18,700 · **NK-KRK-01** 4,324.50 / 4,100 |

## Why this route works

- **The month was in the column names.** A merge, a filter or a chart axis works on values, so the wide sheet cannot be matched to the sales. Unpivot turns the twelve names into twelve rows with a `month` value.
- **Both sides must have the same grain before they meet.** Targets are one row per shop and month after Unpivot; sales are one row per order until Group By sums them to shop and month. Merging orders with targets would repeat each target on every order.
- **Two keys, clicked in the same order on both sides.** `store_code` alone would match each target to twelve months of sales.
- **Left Outer from the targets** keeps the seven months with no sale (actual 0, so `no`), which an inner merge would hide.
- **Monthly and yearly are different questions.** NK-AMM-01 met 7 of its 12 months but missed the year (20,451.00 against 20,700); a strong month can cover a weak one.
- The most common errors: the header not promoted (Unpivot then turns `Column2` … into months); `"yyyy-MMM"` in the month formula, which writes `2025-Sep` and makes the merge match 0 of 132; and `month` left as a number or date on one side.

## The same in SQL (BigQuery)

To run this yourself: upload `store_targets_2025-26.csv` to your `nakheel_stores` dataset as `store_targets` (**Auto detect**), and use the `store_sales` view from solution 01. Look at the **Schema** tab first: BigQuery may rewrite a column name that starts with a digit or holds a dash, so write the twelve month columns exactly as the Schema tab shows them. The `AS '2025-09'` labels make `month` read the same whatever BigQuery called the columns.

| Power Query | SQL |
|---|---|
| Unpivot Other Columns | `UNPIVOT (target FOR month IN (...))` |
| Reference, so `store_targets` stays wide | a view that reads the table; the table does not change |
| Custom Column `Date.ToText([order_date], "yyyy-MM")` | `FORMAT_DATE('%Y-%m', order_date)` |
| Group By on two columns, Sum | `GROUP BY store_code, month` with `SUM(order_total)` |
| Merge Queries as New on two keys, Left Outer | `LEFT JOIN ... ON a.store_code = t.store_code AND a.month = t.month` |
| Replace `null` with `0` | `COALESCE(actual, 0)` |
| Conditional Column comparing two columns | `IF(actual >= target, 'yes', 'no')` |

```sql
-- C1: one row per shop and month (132 rows, 110,000)
CREATE OR REPLACE VIEW nakheel_stores.targets_long AS
SELECT store_code, month, target
FROM nakheel_stores.store_targets
UNPIVOT (target FOR month IN (
  `2025-09` AS '2025-09', `2025-10` AS '2025-10', `2025-11` AS '2025-11', `2025-12` AS '2025-12',
  `2026-01` AS '2026-01', `2026-02` AS '2026-02', `2026-03` AS '2026-03', `2026-04` AS '2026-04',
  `2026-05` AS '2026-05', `2026-06` AS '2026-06', `2026-07` AS '2026-07', `2026-08` AS '2026-08'));

-- C2: completed sales summed to the same grain (125 rows, 107,595.00)
CREATE OR REPLACE VIEW nakheel_stores.actuals_by_month AS
SELECT store_code, FORMAT_DATE('%Y-%m', order_date) AS month, SUM(order_total) AS actual
FROM nakheel_stores.store_sales
WHERE status = 'completed' AND order_date >= '2025-09-01'
GROUP BY store_code, month;

-- C3: target beside actual (132 rows, 61 yes)
SELECT t.store_code, t.month, t.target,
       COALESCE(a.actual, 0) AS actual,
       IF(COALESCE(a.actual, 0) >= t.target, 'yes', 'no') AS met_target
FROM nakheel_stores.targets_long AS t
LEFT JOIN nakheel_stores.actuals_by_month AS a
  ON a.store_code = t.store_code AND a.month = t.month
ORDER BY t.store_code, t.month;

-- C3: the year (11 rows, 3 yes)
SELECT t.store_code,
       SUM(COALESCE(a.actual, 0)) AS actual,
       SUM(t.target) AS target,
       IF(SUM(COALESCE(a.actual, 0)) >= SUM(t.target), 'yes', 'no') AS met_yearly_target
FROM nakheel_stores.targets_long AS t
LEFT JOIN nakheel_stores.actuals_by_month AS a
  ON a.store_code = t.store_code AND a.month = t.month
GROUP BY t.store_code
ORDER BY t.store_code;
```

The SQL makes the cost of the wide sheet visible: `UNPIVOT` has to name all twelve months. **Unpivot Other Columns** names only the column to keep, so next September's column is picked up without a change.
