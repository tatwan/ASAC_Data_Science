# Solution · Activity 01: two years of store sales in one table

The [activity instructions](../README.md) carry the screens and the click path. This page gives the answers, why the fix works, and the same work in SQL.

## The answers

| | Rows | Columns | Completed Sum of `order_total` |
|---|---:|---:|---:|
| `store_sales_2024-25` | 892 | 5 | 97,743.00 |
| `store_sales_2025-26` | 1,009 | 5 (`amount`) | 107,595.00 (in `amount`) |
| `store_sales`, before the rename | 1,901 | 6 | **97,743.00**: the second year is in `amount` |
| `store_sales`, after the rename | 1,901 | 5 | **205,338.00**: the SQL answer |

By status after the fix: completed 1,763 (205,338.00), cancelled 128 (14,224.00), pending 10 (1,040.00). Without the `status` filter the card reads 220,602.00.

## Why the fix works

- **Append matches columns by name.** The reordered columns did no harm; the renamed one did. `amount` became a sixth column, `null` for the first year, and `order_total` was `null` for the second, so the card summed one year.
- **Fix the input, not the result.** `store_sales` replays its inputs at every refresh, so the rename in `store_sales_2025-26` fixes every later refresh too.
- **A query that only feeds another one does not need to be loaded:** untick **Enable load**, and the **Data** pane shows only `store_sales`.

## The same in SQL (BigQuery)

| Power Query | SQL |
|---|---|
| Append Queries as New | `UNION ALL`, saved as a view |
| Append matches columns **by name** | `UNION ALL` matches them **by position** |
| Rename `amount` to `order_total` in the input query | `amount AS order_total` in the second `SELECT` |
| Enable load off on the inputs | report from the view only |

```sql
-- SELECT * stacks by position. BigQuery refuses this one: the second column is
-- store_code (text) in the first file and order_date (a date) in the second.
SELECT * FROM nakheel_stores.store_sales_2024_25
UNION ALL
SELECT * FROM nakheel_stores.store_sales_2025_26;

-- Name the columns in the same order, and rename amount on the way
CREATE OR REPLACE VIEW nakheel_stores.store_sales AS
SELECT order_id, store_code, order_date, status, order_total
FROM nakheel_stores.store_sales_2024_25
UNION ALL
SELECT order_id, store_code, order_date, status, amount AS order_total
FROM nakheel_stores.store_sales_2025_26;

-- 1,901 orders; completed revenue 205,338.00
SELECT COUNT(*) AS orders,
       SUM(IF(status = 'completed', order_total, 0)) AS completed_revenue
FROM nakheel_stores.store_sales;

-- The same total from the Nakheel tables you already have
SELECT SUM(order_total) AS store_revenue
FROM nakheel.orders
WHERE channel = 'store' AND status = 'completed';   -- 205,338.00
```

The two tools fail differently on the same files: SQL stops with an error you cannot miss, while Append runs and loses half the revenue quietly into a sixth column. That is why the card is checked against 205,338.00.

### Running the SQL in these solutions

The store files are not in BigQuery yet. To run the D17 solutions' SQL, create a dataset `nakheel_stores` (location US, like `nakheel`) and upload each file with **Create table** → **Upload** → **CSV** → **Auto detect**:

| File | Table | Used in |
|---|---|---|
| `finance/store_sales_2024-25.csv` | `store_sales_2024_25` | 01 and every later solution, through the view `store_sales` |
| `finance/store_sales_2025-26.csv` | `store_sales_2025_26` | the same |
| `stores_raw.csv` | `stores_raw` | 04–07, through the view `stores` |
| `online_orders_2026-08.ndjson` (in `09-Lab-JSON-To-Table/Solved/`), format **JSONL** | `online_orders` | 09 |
| `till_export_raw.csv`, **Header rows to skip: 4** | `till_export_raw` | 10 |
| `store_targets_2025-26.csv` | `store_targets` | 11 |

BigQuery may rewrite a column name that holds a space, a dash or a slash, or starts with a digit (`governorate - city - area`, `2025-09`). Check each table's **Schema** tab and use the names you see.
