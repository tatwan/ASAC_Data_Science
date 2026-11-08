# Solution: lab 04, two dates and a tidy model

## The answers (completed orders)

| year_month | Sum of `line_value` (sold) | `Delivered revenue` |
|---|---:|---:|
| 2026-03 | 14,444.50 | 15,289.00 |
| 2026-04 | **20,237.00** | **17,815.50** |
| 2026-05 | 12,764.00 | 15,281.50 |
| 2026-06 | 17,321.50 | 16,493.00 |

Of April's orders, 17,524.50 were delivered in April and 2,712.50 in May. Over the two years both series add up to 316,023.50: only completed orders have a `delivered_date`, and every one of them has one.

After step 3, `sales_lines` has 10 columns; after step 4 the **Data** pane shows `order_id`, `qty`, `price`, `channel`, `status`, `line_value` and the measure `Delivered revenue`.

## Why this route works

One date table plays two roles (a role-playing dimension). Only one path between two tables can be active, so the delivered-date line is inactive and visuals keep using the order date; `USERELATIONSHIP` switches the inactive line on inside one measure. Hiding the keys sends report authors to the dimensions, where the names, segments and months are; removing columns that nothing uses keeps them out of the model.

**The most common error:** a key hidden on the one side (`customers[customer_id]`) instead of the many side. Nothing breaks, but the report author loses the customer code.

## The same work in SQL (BigQuery)

| Model | SQL |
|---|---|
| `Delivered revenue` by month | group by the delivered month instead of the order month |
| Remove Columns | leave the columns out of the `SELECT` |
| Is hidden | no counterpart: a setting of the model |

```sql
SELECT FORMAT_DATE('%Y-%m', o.delivered_date) AS delivered_month,
       ROUND(SUM(i.qty * i.price), 2) AS delivered_revenue
FROM nakheel.order_items AS i
JOIN nakheel.orders AS o ON i.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY delivered_month
ORDER BY delivered_month;   -- 2026-04: 17,815.50
```

Bonus: a second date table costs a second table and a second set of month columns; Microsoft recommends it when a visual must filter by both roles at once, for example orders placed in April against delivered in May in one matrix.
