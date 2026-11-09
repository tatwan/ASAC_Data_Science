# Solution: lab 07 (optional), how to compare monthly targets with daily sales

## The answers

| Step | Value |
|---|---|
| 1 | `targets_long`: 132 rows (11 shops × 12 months), columns `store_code`, `month`, `target` |
| 2 | `month_start`: `2025-09` → 2025-09-01, type **Date** |
| 3 | `stores[store_code]` → `targets_long[store_code]`; `dates[date]` → `targets_long[month_start]`; one to many, Single |
| 4 | fiscal 2025-26: target 110,000 against actual 107,595.00 · 2025-09: 12,300 against 12,169.00 · 2026-04: 14,000 against 13,585.50 · 2026-05: 7,800 against 8,038.50 |
| 5 | Amman 42,000 against 41,749.50 · Irbid 34,100 against 34,073.00 · Karak 4,100 against 4,324.50 (above target) · no (Blank) row: the Ramadan stall sold in March 2025, outside this year |

## Why this route works

The targets are a third fact table at the shop-and-month grain. Giving each the first day of its month lets the day-level `dates` table relate to it; `stores` relates to it on `store_code`. Target and actual then meet in the shared dimensions, with no Merge. At day level, the whole monthly target appears on the first day only. Compare targets and sales by month or above; a daily comparison would require an agreed allocation across days.

**The most common error:** relating `dates` to `month` (text) instead of `month_start` (date): 110,000 on every row.

## The same work in SQL (BigQuery)

| Power Query step | SQL |
|---|---|
| Unpivot Other Columns | `UNPIVOT (target FOR month IN (...))` |
| `month_start` | `PARSE_DATE('%Y-%m-%d', CONCAT(month, '-01'))` |
| two relationships and a matrix | Aggregate each fact table by month, then join the two monthly results on month |

```sql
SELECT FORMAT_DATE('%Y-%m', ss.order_date) AS month,
       ROUND(SUM(ss.order_total), 2) AS actual
FROM store_sales AS ss
WHERE ss.status = 'completed'
  AND ss.order_date BETWEEN '2025-09-01' AND '2026-08-31'
GROUP BY month;   -- 2025-09: 12,169.00; the year 107,595.00
```

(With `store_sales` uploaded from lab 05's `Resources/`; the targets come from the unpivoted sheet.)
