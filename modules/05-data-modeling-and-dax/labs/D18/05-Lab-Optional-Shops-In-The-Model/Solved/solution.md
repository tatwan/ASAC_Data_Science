# Solution: lab 05 (optional), the shops in the same model

## The answers

| Step | Value |
|---|---|
| 1 | `store_sales` 1,901 rows (5 columns) · `stores` 12 rows (10 columns) |
| 2 | `stores[store_code]` → `store_sales[store_code]` and `dates[date]` → `store_sales[order_date]`, one to many, Single, active; no `order_id` line |
| 3 | Amman 83,914.50 · Irbid 62,116.50 · Aqaba 20,774.50 · Zarqa 16,134.50 · Karak 8,495.50 · Balqa 5,897.00 · Madaba 3,908.00 · Mafraq 3,239.50 · (Blank) 858.00 · total 205,338.00 |
| 4 | Both columns agree in all 24 months. September 2024 is 8,757.50, April 2026 is 13,585.50 and the total is 205,338.00. |

## Why this route works

A relationship groups the sales by governorate without copying the shop's columns onto 1,901 orders. The supplied CSVs are ready to import into the D18 model.

`store_sales` has one row per store order. `sales_lines` has one row per line across both channels. When the matrix selects April 2026, `dates` filters each table on its own `order_date`. Each table needs its own completed filter. The lines also need the store-channel filter. Without it, the April line amount includes online sales and reads 20,237.00.

If every month shows 220,602.00 in the order column, it is showing the full order total across all statuses. Check the active relationship from `dates[date]` to `store_sales[order_date]` and apply the completed filter to `store_sales[status]`. The direct link from `store_sales` to `sales_lines` in the rehearsal screenshot sends filters toward the lines, so it leaves the order total unchanged when the month changes.

For the governorate chart, use `order_total` from `store_sales`. In the corrected model, `stores` can filter store orders by governorate and `products` can filter sales lines by category. A report that needs both on the same sales amount would need shop information at line grain.

## The same work in SQL (BigQuery)

```sql
SELECT s.governorate, ROUND(SUM(ss.order_total), 2) AS revenue
FROM store_sales AS ss
LEFT JOIN stores AS s ON ss.store_code = s.store_code
WHERE ss.status = 'completed'
GROUP BY s.governorate;   -- NULL is NK-POP-01, 858.00; total 205,338.00
```

(With `store_sales` and `stores` uploaded from this lab's `Resources/` to a dataset of your own.)
