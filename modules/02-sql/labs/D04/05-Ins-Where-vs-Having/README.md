# WHERE filters rows, HAVING filters groups

In this activity, you will filter Nakheel orders before grouping with `WHERE`, then filter the groups after counting with `HAVING`, and see why `WHERE` cannot test a count.

**Time:** 5 minutes · **Data:** `nakheel.orders` (activity 03) · **File:** `Solved/where_vs_having.sql`

## Instructions

1. Open `Solved/where_vs_having.sql`. Run query 1. `WHERE status = 'completed'` removes rows **before** they are grouped: completed orders per channel, sorted by `channel`.

2. Run query 2. `HAVING COUNT(*) > 20` removes groups **after** they are counted: 25 customers have more than 20 orders, sorted by the count, largest first, then by `customer_id`.

3. Run query 3. It uses both: `WHERE` keeps the completed orders, then `HAVING` keeps the customers with more than 20 of them. 22 customers, sorted the same way.

4. Run query 4. It stops with `Aggregate function COUNT not allowed in WHERE clause`. There is nothing to count yet when `WHERE` runs.

5. Write the run order in your notes. The one from D03 grows two steps: **FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT**.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 | online 1,008; store 1,763 |
| 2 | 25 | C-1270 first, 135 orders |
| 3 | 22 | C-1270 first, 126 completed orders |
| 4 | error | `Aggregate function COUNT not allowed in WHERE clause` |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
