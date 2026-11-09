# Solution: activity 03, filter context and CALCULATE

## The answers (steps 1–2: status = completed)

| category | Total Revenue | Customers |
|---|---:|---:|
| Outerwear | **76,637.00** | 307 |
| Shoes | 62,373.50 | **284** |
| Bottoms | 50,535.00 | 320 |
| Accessories | 43,525.00 | 309 |
| Sportswear | 42,365.00 | 311 |
| Tops | 40,588.00 | 304 |
| **Total** | 316,023.50 | **452** |

The Customers rows add up to 1,835. Step 3, channel = online: Total Revenue 110,685.50 (1,008 orders, 298 customers).

Step 4, no slicer:

| status | Total Revenue | Completed Revenue |
|---|---:|---:|
| completed | 316,023.50 | 316,023.50 |
| cancelled | 21,998.50 | 316,023.50 |
| pending | 2,348.00 | 316,023.50 |

Bonus: with no status slicer, Total Revenue by category counts every status (Outerwear 81,920.50) and Completed Revenue keeps the category filter and adds status = completed (Outerwear 76,637.00).

## Why this route works

Power BI evaluates the measure separately for each cell, using its table-row filters, slicer selections and filters from the Filters pane. The Total cell counts each customer once across the categories in scope. On the cancelled row, `CALCULATE` replaces the row's status filter with `completed` when it evaluates Completed Revenue. On a category row, it adds the completed status filter and keeps that category.

**The most common error:** expecting the total row of a distinct count to equal the sum of its rows.

## The same work in SQL (BigQuery)

| DAX | SQL |
|---|---|
| a row of the table by category | `GROUP BY p.category` |
| the total row | the same query with no `GROUP BY` |
| `CALCULATE([Total Revenue], sales_lines[status] = "completed")` | `SUM(...)` with `WHERE status = 'completed'`, whatever the row |

```sql
SELECT p.category,
       ROUND(SUM(i.qty * i.price), 2) AS total_revenue,     -- Outerwear 76,637.00
       COUNT(DISTINCT o.customer_id)  AS customers          -- Shoes 284
FROM nakheel.order_items AS i
JOIN nakheel.orders   AS o ON i.order_id = o.order_id
JOIN nakheel.products AS p ON i.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY total_revenue DESC;
-- the total row: drop p.category and GROUP BY: 316,023.50 and 452
```
