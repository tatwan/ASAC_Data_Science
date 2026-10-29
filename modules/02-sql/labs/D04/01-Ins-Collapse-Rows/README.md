# Rows collapse into groups

In this activity, you will add a calculated column to every row of `D03.order_items`, then group the same twelve rows two different ways and see what one row of each result means.

**Time:** 18 minutes · **Data:** `D03.order_items` (D03 activity 01) · **File:** `Solved/collapse_rows.sql`

## Instructions

1. Open `Solved/collapse_rows.sql`. Run query 1. `qty * price AS line_revenue` adds a column. The row count does not change: 12 rows in, 12 rows out. The rows are sorted by `item_id`.

2. Before you run query 2, say what one row of the answer will be: one order. Predict how many rows. Then run it. `GROUP BY order_id` collapses the 12 rows into 5, one per order, sorted by `order_id`. You should see:

    | order_id | lines | order_revenue |
    |---:|---:|---:|
    | 1001 | 2 | 47.00 |
    | 1002 | 2 | 100.50 |
    | 1003 | 3 | 61.50 |
    | 1004 | 2 | 162.00 |
    | 1005 | 3 | 116.00 |

3. Run query 3. `GROUP BY product_id` collapses the same 12 rows into 5 different groups, one per product, sorted by `product_revenue`, largest first. **The grain of the result is whatever you group by.** Before you run a `GROUP BY`, say what one row of the answer will be.

4. Run query 4. It stops with `SELECT list expression references column product_id which is neither grouped nor aggregated`. Every column in `SELECT` must be either in the `GROUP BY` or inside a function such as `SUM` or `COUNT`. Order 1003 has three products, and BigQuery cannot put three different `product_id` values into one order's row.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 12 | item 9001: `line_revenue` 39.00 |
| 2 | 5 | order 1004: 2 lines, 162.00 |
| 3 | 5 | P-77 first: 10 units, 195.00 |
| 4 | error | `… which is neither grouped nor aggregated` |

## References

The D01 tables (the `D03` dataset), course-owned synthetic data, 19 September 2026.
