# Solution: activity 01, load the four start files and relate the tables

## The answers

| Step | Result |
|---|---|
| 1 | `sales_lines` 7,516 rows, `customers` 500, `products` 60, `dates` 1,096 |
| 2 | `customers` → `sales_lines` on `customer_id`, `products` → `sales_lines` on `product_id`, `dates` → `sales_lines` on `order_date` (solid, one to many, Single); `dates` → `sales_lines` on `delivered_date` (dashed, inactive) |
| 3 | `dates` marked on `date`; `month` sorted by `month_no`: January first |
| 4 | Sum of `line_value`: 340,370.00 |

## Why this route works

The start files are D18's tables after its activities and Lab 04, so the model only needs what a CSV file cannot carry: the relationships, the date-table mark and the sort order. Only one path between two tables can be active, so the second `dates` line is inactive; D18's `Delivered revenue` and today's Part 3 use it on purpose.

**The most common error:** `dates[date]` dropped onto the wrong column (`customer_id`, say). Power BI accepts it, every chart by month shows the full total on one bar or none, and the fix is to delete that line and drag again.

## The same work in SQL (BigQuery)

| Model | SQL |
|---|---|
| a relationship on `customer_id` | `LEFT JOIN nakheel.customers ON … customer_id` (D06) |
| Sum of `line_value` in a card | `SUM(qty * price)` over every line |

```sql
SELECT ROUND(SUM(qty * price), 2) AS total_revenue
FROM nakheel.order_items;      -- 340,370.00, every line of every status
```
