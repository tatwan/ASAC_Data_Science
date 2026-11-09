# Solution: activity 01, the four Nakheel tables and sales_lines

## The answers

| Step | Value |
|---|---|
| 1 | 4 queries: `customers`, `products`, `orders`, `order_items` |
| 2 | `segment`: Retail 435 · Wholesale 65 (five spellings before) |
| 3 | 7,516 of 7,516 lines find their order; `sales_lines` has 11 columns after the expand |
| 4 | Sum of `line_value`, `sales_lines[status]` = completed: **316,023.50** (12 columns) |
| 5 | `sales_lines` 7,516 (one line of an order, fact) · `customers` 500 (one customer, dimension) · `products` 60 (one product, dimension) · `orders` 3,000 and `order_items` 7,516 not loaded |

Step 5's three columns: `shipping_fee` does not belong on `sales_lines` (an order's fee on each of its lines sums to 1,742.50 against the true 1,032.50); `price` does (it is that line's price); `customer_id` does, as a key to `customers`.

## Why this route works

`orders` and `order_items` describe the same sale: the order says who and when, its lines say what. Merging the order onto its lines keeps one row per line, so the line grain is unchanged and nothing is counted twice, as long as the order's own totals stay behind. Merge builds one table at one grain. The customer and product descriptions are not merged in: they stay in their own tables, and activity 03 connects them with relationships.

**The most common error:** leaving `order_total` ticked and adding it up on the lines: 988,971.50, about 3.1 times the true revenue, because each order's total is repeated once per line (order 100003: 47.00 × 3 = 141.00).

## The same work in SQL (BigQuery)

| Power Query step | SQL |
|---|---|
| Merge Queries as New, Left Outer on `order_id` | `FROM nakheel.order_items AS i LEFT JOIN nakheel.orders AS o ON i.order_id = o.order_id` |
| Expand without `order_total`, `shipping_fee` | `SELECT i.*, o.customer_id, o.order_date, o.order_ts, o.channel, o.status, o.delivered_date` |
| Custom Column `line_value` | `i.qty * i.price AS line_value` |
| Card with `status` = completed | `SUM(...) WHERE o.status = 'completed'` |

```sql
SELECT ROUND(SUM(i.qty * i.price), 2) AS completed_revenue   -- 316,023.50
FROM nakheel.order_items AS i
LEFT JOIN nakheel.orders AS o
  ON i.order_id = o.order_id
WHERE o.status = 'completed';
```

Every line finds its order in these supplied files, so either a Left Outer or an Inner join gives 7,516 rows. The Left Outer join also keeps a line if its order record is missing in another dataset.
