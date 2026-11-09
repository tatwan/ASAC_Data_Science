# Solution: lab 04, percent of total by category

## The answers

```dax
All Categories Revenue =
    CALCULATE([Completed Revenue], REMOVEFILTERS(products))

% of Total = DIVIDE([Completed Revenue], [All Categories Revenue])
```

| category | Completed Revenue | All Categories Revenue | % of Total | online only |
|---|---:|---:|---:|---:|
| Outerwear | 76,637.00 | 316,023.50 | **24.3%** | **22.9%** |
| Shoes | 62,373.50 | 316,023.50 | 19.7% | 22.7% |
| Bottoms | 50,535.00 | 316,023.50 | 16.0% | 14.9% |
| Accessories | 43,525.00 | 316,023.50 | 13.8% | 13.0% |
| Sportswear | 42,365.00 | 316,023.50 | 13.4% | 12.9% |
| Tops | 40,588.00 | 316,023.50 | 12.8% | 13.6% |
| **Total** | 316,023.50 | 316,023.50 | **100.0%** | 100.0% |

With only Outerwear selected in the category slicer, the Outerwear row still shows **76,637.00 ÷ 316,023.50 ≈ 24.3%**. After clearing that slicer and selecting online, the row shows **25,315.50 ÷ 110,685.50 ≈ 22.9%**.

Bonus: by `customers[segment]`, `REMOVEFILTERS(products)` leaves the segment filter in place, so every row reads 100%. The bottom number must remove the table the rows come from: `REMOVEFILTERS(customers)` gives Retail 50.9%, Wholesale 48.8% and (Blank) 0.3%.

## Why this route works

Both measures sum completed sales. **Completed Revenue** uses the category filter on the row. For **All Categories Revenue**, `REMOVEFILTERS(products)` clears the category filter from the row and any category slicer selection for that calculation. Selecting **online** filters `sales_lines`, so both measures then sum only online sales.

`REMOVEFILTERS()` with no argument also removes the channel filter from the denominator's calculation. The online slicer selection stays visible. Outerwear reads **8.0%** because it divides online Outerwear revenue by completed revenue across all categories and channels.

## The same work in SQL (BigQuery)

| DAX | SQL |
|---|---|
| Completed Revenue on a category row | `SUM(...)` with `GROUP BY category` |
| `CALCULATE(…, REMOVEFILTERS(products))` | `SUM(revenue) OVER ()`: the window sees every row (D10) |
| `DIVIDE` | `SAFE_DIVIDE` |
| the online slicer | `AND o.channel = 'online'` in the `WHERE` |

```sql
WITH by_category AS (
  SELECT p.category, SUM(i.qty * i.price) AS revenue
  FROM nakheel.order_items AS i
  JOIN nakheel.orders   AS o ON i.order_id = o.order_id
  JOIN nakheel.products AS p ON i.product_id = p.product_id
  WHERE o.status = 'completed'
  GROUP BY p.category
)
SELECT category,
       ROUND(revenue, 2) AS revenue,
       ROUND(100 * SAFE_DIVIDE(revenue, SUM(revenue) OVER ()), 1) AS share_pct   -- Outerwear 24.3
FROM by_category
ORDER BY share_pct DESC;
```
