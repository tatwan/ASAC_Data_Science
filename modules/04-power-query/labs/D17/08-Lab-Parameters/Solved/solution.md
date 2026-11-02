# Solution · Lab 08: parameters

The [lab instructions](../README.md) carry the screens and the click path. This page gives the answers, why parameters help, and the same idea in SQL.

## The answers

| Checkpoint | Answer |
|---|---|
| C1 | Text parameter `FilesFolder`, your extracted folder's full path ending in `\`; used in five `Source` steps: the two finance queries, `stores_raw`, `store_files_sales` and the **Sample File** helper |
| C2 | Folder renamed, only **Current Value** changed: the completed-store-revenue card still reads **205,338.00** |
| C3 | `StatusToCount` through `store_sales_one_status`, card with no visual filter: |

| `StatusToCount` | Sum of `order_total` |
|---|---:|
| completed | 205,338.00 |
| cancelled | 14,224.00 |
| pending | 1,040.00 |
| (all three) | 220,602.00 |

Bonus: completed store revenue from 1 March 2026 is **60,480.50**.

## Why parameters help

- **One place to change.** The path was typed into five queries; now it is typed once. When the data moves, you change one value instead of editing five steps (and missing the helper query's).
- **A parameter filters rows before they reach the model.** The card needs no visual filter because `store_sales_one_status` holds only one status. A visual filter, by contrast, hides rows that are still loaded.
- **Suggested values help, they do not enforce.** The list offers `completed`, `cancelled`, `pending`; a typed `Completed` would match nothing.
- The most common errors: a doubled or missing `\` where the parameter meets the rest of the path, and the **Sample File** helper's path left unchanged (five places, not four).

## The same in SQL (BigQuery)

`StatusToCount` has a direct twin: a variable declared once at the top of a script. `FilesFolder` has none: BigQuery data lives in a dataset, not a folder path, and moving it is not something a query has to follow.

| Power Query | SQL |
|---|---|
| **Manage Parameters → New Parameter** `StatusToCount` | `DECLARE status_to_count STRING DEFAULT 'completed';` |
| Filter `status` **Equals** the parameter `StatusToCount` | `WHERE status = status_to_count` |
| Change **Current Value**, apply | change the `DEFAULT` (or `SET`) and run again |
| `FilesFolder` in every `Source` step | no twin: queries name a dataset, `nakheel_stores.store_sales` |

```sql
-- Run as one script. BigQuery wants every DECLARE at the top of the script.
-- Change 'completed' to 'cancelled' or 'pending', and run again.
DECLARE status_to_count STRING DEFAULT 'completed';
DECLARE from_date DATE DEFAULT DATE '2026-03-01';   -- for the bonus

SELECT SUM(order_total) AS revenue
FROM nakheel_stores.store_sales          -- the view from solution 01
WHERE status = status_to_count;          -- 205,338.00 · 14,224.00 · 1,040.00

-- Bonus: completed revenue from from_date
SELECT SUM(order_total) AS revenue
FROM nakheel_stores.store_sales
WHERE status = 'completed' AND order_date >= from_date;   -- 60,480.50
```
