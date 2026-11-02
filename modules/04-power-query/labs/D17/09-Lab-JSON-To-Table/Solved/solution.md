# Solution · Lab 09: JSON to a table

The [lab instructions](../README.md) carry the screens and the click path. This page gives the answers, why the grain matters, and the same work in SQL.

## The answers

| After | Rows | One row is one | Check |
|---|---:|---|---|
| `orders` list to a table, records expanded (`online_orders`) | 77 | order | 62 completed · 8 cancelled · 7 pending; 2 with no city (C-1487, C-1227) |
| `items` expanded to new rows (`online_order_lines`) | 192 | item on an order | order 102844 on 5 rows |

| Value | Answer |
|---|---:|
| `line_total`, completed | **6,121.50**, the website's completed August in the Nakheel tables |
| `line_total`, all statuses | 7,956.00 |
| `shipping_fee` on `online_orders` | **72.50** |
| `shipping_fee` on `online_order_lines` (wrong) | 107.50 |
| Units sold, completed | 357 |
| Bonus: most units, completed | P-014, 36 units (then P-033 29, P-026 22) |

## Why the grain matters

- **A record expands into columns; a list expands into rows.** `customer` is one record per order, so it adds columns and the row count stays 77. `items` is a list, so each order becomes as many rows as it has items: 192.
- **After the list expands, one row is one item.** A number that describes the order (`shipping_fee`) is copied onto every item row, so summing it there counts it once per item: 107.50 instead of 72.50. Keep a table at the order grain for order-level numbers.
- **Duplicate, not Reference, for `online_orders`.** A Reference would follow the original query into the item rows after the next expand.
- The most common error: summing `shipping_fee` after the items were expanded, or removing duplicate fee values to "fix" it (different orders can share a fee).

## The same in SQL (BigQuery)

BigQuery reads JSON one record per line, so the file is saved that way here: [`online_orders_2026-08.ndjson`](online_orders_2026-08.ndjson), one order per line. Upload it as `nakheel_stores.online_orders` with format **JSONL** and **Auto detect**: `customer` arrives as a STRUCT (a record) and `items` as a REPEATED RECORD (a list of records), the same shapes Power Query showed as **Record** and **List**.

| Power Query | SQL |
|---|---|
| Expand a **Record** column (`customer`) | dot notation: `customer.city` |
| Expand a **List** column to **new rows** (`items`) | `CROSS JOIN UNNEST(items) AS i` (written `, UNNEST(...)`) |
| Then expand each item's record | `i.product_id`, `i.qty`, `i.price` |
| Custom Column `[qty] * [price]` | `i.qty * i.price AS line_total` |
| Keep a separate order-level table | query `online_orders` without `UNNEST` |

```sql
-- C1: one row per order (77; 2 with no city)
SELECT order_id, order_date, status, customer.customer_id, customer.city, shipping_fee
FROM nakheel_stores.online_orders;

-- C2: one row per item (192; order 102844 on 5 rows)
SELECT o.order_id, o.status, o.shipping_fee, i.product_id, i.qty, i.price,
       i.qty * i.price AS line_total
FROM nakheel_stores.online_orders AS o, UNNEST(o.items) AS i;

-- C3: completed line totals, 6,121.50
SELECT SUM(i.qty * i.price) AS completed_revenue
FROM nakheel_stores.online_orders AS o, UNNEST(o.items) AS i
WHERE o.status = 'completed';

-- C3: shipping at the right grain (72.50) and after the items were unnested (107.50)
SELECT SUM(shipping_fee) AS right_grain FROM nakheel_stores.online_orders;
SELECT SUM(o.shipping_fee) AS wrong_grain
FROM nakheel_stores.online_orders AS o, UNNEST(o.items) AS i;

-- Bonus: units by product, completed orders (P-014, 36)
SELECT i.product_id, SUM(i.qty) AS units
FROM nakheel_stores.online_orders AS o, UNNEST(o.items) AS i
WHERE o.status = 'completed'
GROUP BY i.product_id
ORDER BY units DESC
LIMIT 3;
```

The same trap exists in SQL: as soon as `UNNEST` turns one order into five rows, any order-level number in the `SELECT` repeats five times.
