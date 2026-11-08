# Solution: activity 02, the base measures

## The answers

```dax
Total Revenue = SUM(sales_lines[line_value])
Orders = DISTINCTCOUNT(sales_lines[order_id])
Customers = DISTINCTCOUNT(sales_lines[customer_id])
Average Order Value = DIVIDE([Total Revenue], [Orders])
```

| Measure | No slicer | status = completed |
|---|---:|---:|
| Total Revenue | 340,370.00 | **316,023.50** |
| Orders | 3,000 | **2,771** |
| Customers | 462 | **452** |
| Average Order Value | 113.46 | **114.05** |

Customers counts `C-0999`, the order with no customer row (D18's (Blank)); 461 of the 462 have a row in `customers`.

## Why this route works

Each measure runs again for every card and cell, on the rows that card or cell keeps, so the slicer changes all four at once without touching the formulas. `DISTINCTCOUNT` counts orders on a table of order lines. Average Order Value divides two measures, so it is right at any level: per order, per category or for the whole table.

**The most common error:** `AVERAGE(sales_lines[line_value])` for the average order: 45.46, the average line (316,023.50 ÷ 6,951 completed lines).

## The same work in SQL (BigQuery)

| DAX | SQL |
|---|---|
| `SUM(sales_lines[line_value])` | `SUM(qty * price)` |
| `DISTINCTCOUNT(sales_lines[order_id])` | `COUNT(DISTINCT order_id)` |
| `DIVIDE([Total Revenue], [Orders])` | `SAFE_DIVIDE(SUM(...), COUNT(DISTINCT ...))` |
| the status slicer on completed | `WHERE status = 'completed'` |

```sql
SELECT ROUND(SUM(i.qty * i.price), 2)           AS total_revenue,     -- 316,023.50
       COUNT(DISTINCT o.order_id)                AS orders,            -- 2,771
       COUNT(DISTINCT o.customer_id)             AS customers,         -- 452
       ROUND(SAFE_DIVIDE(SUM(i.qty * i.price),
                         COUNT(DISTINCT o.order_id)), 2) AS average_order_value   -- 114.05
FROM nakheel.order_items AS i
JOIN nakheel.orders AS o ON i.order_id = o.order_id
WHERE o.status = 'completed';
```

Remove the `WHERE` line for the no-slicer column: 340,370.00, 3,000, 462 and 113.46.
