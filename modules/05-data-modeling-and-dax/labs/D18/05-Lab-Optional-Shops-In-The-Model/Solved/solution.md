# Solution: lab 05 (optional), the shops in the same model

## The answers

| Step | Value |
|---|---|
| 1 | `store_sales` 1,901 rows (5 columns) · `stores` 12 rows (10 columns) |
| 2 | `stores[store_code]` → `store_sales[store_code]` and `dates[date]` → `store_sales[order_date]`, one to many, Single, active; no `order_id` line |
| 3 | Amman 83,914.50 · Irbid 62,116.50 · Aqaba 20,774.50 · Zarqa 16,134.50 · Karak 8,495.50 · Balqa 5,897.00 · Madaba 3,908.00 · Mafraq 3,239.50 · (Blank) 858.00 · total 205,338.00 |
| 4 | every month agrees; April 2026: 13,585.50 in both columns |

## Why this route works

A relationship gives D17's governorate chart without copying the store's columns onto 1,901 sales: Part 1's rule (a relationship connects a dimension to a fact). Two fact tables share a dimension (`dates`) instead of being related to each other: a direct line on `order_id` would give `dates` a second path to `sales_lines`, and the two paths give two April totals (20,237.00 and 13,585.50).

**The most common error:** taking `line_value` from `sales_lines` for the governorate chart: the same total on every bar, because `stores` does not reach `sales_lines`.

## The same work in SQL (BigQuery)

```sql
SELECT s.governorate, ROUND(SUM(ss.order_total), 2) AS revenue
FROM store_sales AS ss
LEFT JOIN stores AS s ON ss.store_code = s.store_code
WHERE ss.status = 'completed'
GROUP BY s.governorate;   -- NULL is NK-POP-01, 858.00; total 205,338.00
```

(With `store_sales` and `stores` uploaded from this lab's `Resources/` to a dataset of your own.)
