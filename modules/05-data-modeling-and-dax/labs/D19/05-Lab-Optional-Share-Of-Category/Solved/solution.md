# Solution: lab 05, each product's share of its category

## The answers

```dax
Category Revenue =
    CALCULATE([Completed Revenue], REMOVEFILTERS(products[product_name]))

% of Category = DIVIDE([Completed Revenue], [Category Revenue])
```

| category | product_name | Completed Revenue | Category Revenue | % of Category |
|---|---|---:|---:|---:|
| Tops | White thobe | 9,768.00 | 40,588.00 | **24.1%** |
| Accessories | Leather belt | 9,646.00 | 43,525.00 | 22.2% |
| Shoes | Ankle boot | 12,000.00 | 62,373.50 | 19.2% |

56 rows in all: the four products that never sold have no completed line.

## Why this route works

Each row has two filters from `products`: its category and its product. Removing only the `product_name` filter leaves the category filter, so the bottom number is the row's category total. Removing the whole table would leave nothing, and give 316,023.50 (lab 04's share of the total).

**The most common error:** removing the filter on a column the table does not use (`product_id` when the table shows `product_name`): nothing is removed and every row reads 100%.

## The same work in SQL (BigQuery)

| DAX | SQL |
|---|---|
| `REMOVEFILTERS(products[product_name])`, category kept | `SUM(revenue) OVER (PARTITION BY category)` (D10 activity 02) |

```sql
WITH product_revenue AS (
  SELECT p.category, p.product_name, SUM(i.qty * i.price) AS revenue
  FROM nakheel.order_items AS i
  JOIN nakheel.orders   AS o ON i.order_id = o.order_id
  JOIN nakheel.products AS p ON i.product_id = p.product_id
  WHERE o.status = 'completed'
  GROUP BY p.category, p.product_name
)
SELECT category, product_name, revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (PARTITION BY category), 1) AS share_pct
FROM product_revenue
ORDER BY share_pct DESC;      -- White thobe 24.1, 56 rows
```
