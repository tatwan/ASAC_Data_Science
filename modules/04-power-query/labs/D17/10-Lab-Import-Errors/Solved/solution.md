# Solution · Lab 10: import errors

The [lab instructions](../README.md) carry the screens and the click path. This page gives the answers, why the route works, and the same work in SQL.

## The answers

| Checkpoint | Answer |
|---|---|
| C1 | 17 rows in `Source` (the real header is row 4); 12 rows after Remove Top Rows (3), Use First Row as Headers and Remove Blank Rows: 7 completed, 1 cancelled, 2 pending, 2 voided |
| C2 | 3 rows with errors: two `VOID` receipts (`order_id` is not a number, `order_total` is `-`) and order 102869 (`order_total` typed `93.50 JOD`) |
| Quick fix | **Remove Errors**: 6 completed orders, **1,939.00**. Order 102869's 93.50 is lost with the voided rows |
| C3 | Split on the space, `-` replaced with `null`, then Decimal Number, then completed: **7 orders, 2,032.50**, Aqaba's completed August in `store_sales` |

## Why this route works

- **An error is a message about one value.** Read it, then fix the value (`93.50 JOD` is a real sale with its currency typed) or drop the row for a business reason (a voided receipt is not an order). **Remove Errors** drops every row with any error, a real sale included: 2,032.50 − 1,939.00 = 93.50, exactly order 102869.
- **Fix the text first, set the type last.** Once `order_total` is Decimal Number, `93.50 JOD` and `-` are already errors, and Split or Replace Values has nothing left to work on. That is why step 5 deletes the type step from step 3.
- **The voided rows leave through the status filter**, because they are not completed orders. Their `order_id` stays text here; nothing sums it.
- The most common error: a type step (yours, or one Power BI adds after the split) left before the replace, so `-` is still an Error.

## The same in SQL (BigQuery)

To run this yourself: upload `till_export_raw.csv` to your `nakheel_stores` dataset as `till_export_raw` with **Header rows to skip: 4** and **Auto detect**. BigQuery skips the three title lines and reads the names from the fourth row; `order_id` and `order_total` arrive as STRING because of `VOID`, `-` and `JOD`.

| Power Query | SQL |
|---|---|
| Remove Top Rows (3) · Use First Row as Headers | **Header rows to skip: 4** when you upload |
| Remove Blank Rows | `WHERE status IS NOT NULL` |
| A type change that fails shows **Error** in one cell | `CAST` stops the whole query; `SAFE_CAST` returns `NULL` instead |
| Keep Errors | `WHERE SAFE_CAST(...) IS NULL` |
| Remove Errors | `WHERE SAFE_CAST(...) IS NOT NULL` |
| Split Column by Space, keep the first part | `SPLIT(order_total, ' ')[OFFSET(0)]` |
| Replace `-` with `null` | `NULLIF(..., '-')` |

```sql
-- C2: the rows whose values will not become numbers (3 rows)
SELECT *
FROM nakheel_stores.till_export_raw
WHERE status IS NOT NULL
  AND (SAFE_CAST(order_id AS INT64) IS NULL OR SAFE_CAST(order_total AS NUMERIC) IS NULL);

-- The quick fix, Remove Errors: 6 orders, 1,939.00
SELECT COUNT(*) AS orders, SUM(SAFE_CAST(order_total AS NUMERIC)) AS revenue
FROM nakheel_stores.till_export_raw
WHERE status = 'completed'
  AND SAFE_CAST(order_id AS INT64) IS NOT NULL
  AND SAFE_CAST(order_total AS NUMERIC) IS NOT NULL;

-- C3, each error fixed for its reason: 7 orders, 2,032.50
SELECT COUNT(*) AS orders,
       SUM(CAST(NULLIF(SPLIT(order_total, ' ')[OFFSET(0)], '-') AS NUMERIC)) AS revenue
FROM nakheel_stores.till_export_raw
WHERE status = 'completed';

-- The check: the same shop and month in store_sales (the view from solution 01)
SELECT SUM(order_total) AS revenue
FROM nakheel_stores.store_sales
WHERE store_code = 'NK-AQB-01' AND status = 'completed'
  AND order_date BETWEEN '2026-08-01' AND '2026-08-31';   -- 2,032.50
```

The difference to notice: SQL refuses a bad value for the whole query (`CAST`) or hides it as `NULL` (`SAFE_CAST`); Power Query keeps the row and marks the one cell, so you can read why it failed before you decide.
