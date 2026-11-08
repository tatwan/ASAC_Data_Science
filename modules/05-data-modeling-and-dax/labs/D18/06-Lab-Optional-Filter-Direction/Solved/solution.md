# Solution: lab 06 (optional), cross filter direction Both

## The answers

| Step | Value |
|---|---|
| 1 | with **Both**, Count of `customers[customer_id]` by category: Bottoms 320 · Sportswear 310 · Accessories 308 · Outerwear 307 · Tops 303 · Shoes 283 |
| 2 | the card, Shoes picked, any status: 297 |
| 3 | with **Single** again: 500 |

283 against activity 03's 284: **Both** counts rows of `customers` that the filter reaches, and `C-0999` (order 101664) has no row there; Count (Distinct) of `sales_lines[customer_id]` counts every code on the lines, `C-0999` included. Which one is "right" depends on whether the manager wants known customers or every buyer.

## Why this route works, and why we undo it

**Both** lets the filter travel from the many side back to the one side, so a product filter reaches `customers`. It does so for every visual in the report, which is why Microsoft recommends using it sparingly; for one visual or one measure, count in the fact table or use `CROSSFILTER` inside the measure.

**The most common error:** setting **Both** on `products`–`sales_lines` instead: the customer count does not change.

## The same work in SQL (BigQuery)

```sql
SELECT p.category, COUNT(DISTINCT c.customer_id) AS customers   -- known customers only: Shoes 283
FROM nakheel.order_items AS i
JOIN nakheel.orders AS o ON i.order_id = o.order_id
JOIN nakheel.products AS p ON i.product_id = p.product_id
JOIN nakheel.customers AS c ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY p.category;
```

The inner join to `customers` drops `C-0999`, which is what **Both** does; without that join (activity 03's query) Shoes reads 284.
