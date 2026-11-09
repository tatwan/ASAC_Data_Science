# Solution: activity 03, relationships and the manager's questions

## The relationships

| One side | Many side | Cardinality | Direction | Active |
|---|---|---|---|---|
| `customers[customer_id]` | `sales_lines[customer_id]` | one to many | Single | yes |
| `products[product_id]` | `sales_lines[product_id]` | one to many | Single | yes |
| `dates[date]` | `sales_lines[order_date]` | one to many | Single | yes |

## The answers (completed orders)

| Question | Answer | Relationship it uses |
|---|---|---|
| 1 · Retail or wholesale | Retail 160,881.50 · Wholesale 154,204.00 · (Blank) 938.00 (order 101664, C-0999) | `customers` → `sales_lines` |
| 2 · Online, top category | Outerwear 25,315.50, just ahead of Shoes 25,120.50 | `products` → `sales_lines`; `channel` is a column of the fact |
| 3 · Best month | 2026-04, 20,237.00 (lowest 2025-11, 9,772.50) | `dates` → `sales_lines` |
| 4 · Customers who bought Sportswear | 311 with Count (Distinct) of `sales_lines[customer_id]` (500 with Count of `customers[customer_id]`) | `products` → `sales_lines` |
| 5 · Products that never sold | Hiking boot, Graphic T-shirt, Sunglasses, Headband (56 → 60 with Show items with no data) | `products` → `sales_lines` |

Bonus: wholesale Shoes, 33,372.50.

## Why this route works

A relationship keeps each table once and joins them when a visual asks. The filter travels from the one side to the many side: a segment filters `customers`, then the lines of those customers. It never travels back, so counting `customers` by category reads 500 everywhere; counting the customer codes on the lines, where the category filter arrives, gives the real number.

**The most common error:** question 4 with `customers[customer_id]`: 500 on every bar.

## The same work in SQL (BigQuery)

| Model | SQL |
|---|---|
| A relationship, one to many | `LEFT JOIN` from the fact to the dimension |
| (Blank) | the `NULL` group |
| Count (Distinct) of `sales_lines[customer_id]` | `COUNT(DISTINCT o.customer_id)` after the join |

```sql
SELECT INITCAP(TRIM(c.segment)) AS segment, ROUND(SUM(i.qty * i.price), 2) AS revenue
FROM nakheel.order_items AS i
JOIN nakheel.orders AS o ON i.order_id = o.order_id
LEFT JOIN nakheel.customers AS c ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY 1;   -- trim and standardise segment as in activity 01; NULL is the (Blank) bar

SELECT p.category, COUNT(DISTINCT o.customer_id) AS customers
FROM nakheel.order_items AS i
JOIN nakheel.orders AS o ON i.order_id = o.order_id
JOIN nakheel.products AS p ON i.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.category;   -- Sportswear 311, Shoes 284
```
