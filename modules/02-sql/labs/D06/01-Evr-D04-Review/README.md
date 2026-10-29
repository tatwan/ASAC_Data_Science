# D04 in one query

In this activity, you will build one query on Nakheel orders that uses `GROUP BY`, a `CASE` rule and `HAVING` together, saying what one row is and predicting the row count before every run.

**Time:** 20 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **Starter:** `Unsolved/d04_review.sql`

**Before you start:** the four `nakheel` tables are uploaded. If they are missing, use the [D04 Nakheel upload activity](../../D04/03-Evr-Upload-Nakheel/README.md).

Every join on D06 changes what one row is. This review makes sure `GROUP BY` is solid first. For every query, write down two things before you press **Run**: "one row of the result is one ___" and how many rows you expect.

## Instructions

1. One row of `nakheel.orders` is one ___? Count the rows, and count the different `order_id` values.

    Translate: `COUNT(*)` and `COUNT(DISTINCT order_id)` in one `SELECT`.

    If the two numbers are equal, `order_id` is unique: one row, one order. You will use this check before every join.

2. "Revenue by channel." Run the query in the starter file exactly as written. Read the error aloud: which column does it name, and what does it say is missing?

3. Fix it. "Completed revenue by channel, with the number of completed orders." One row of the result is one ___? How many rows?

    Translate: `WHERE status = 'completed'`, `GROUP BY channel`, `COUNT(*)` called `completed_orders` and `ROUND(SUM(order_total), 2)` called `revenue`.

4. "Split each channel by order size." Start from query 3, so it still counts completed orders only. Use the D04 rule: an order is large from 200, medium from 50, otherwise small. One row is one ___? How many rows?

    Translate: add the rule as a `CASE` column called `size_band`; group by `channel` and `size_band`; sort by `channel`, then `revenue` from largest.

5. "Only the groups worth more than 50,000." Is 50,000 a test on one order, or on a group? Choose `WHERE` or `HAVING`.

    Translate: the query from step 4 with one more line; sort by `revenue` from largest.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 3,000 and 3,000 |
| 2 | error | `SELECT list expression references column channel which is neither grouped nor aggregated` |
| 3 | 2 | online 1,008 orders, 110,685.50; store 1,763 orders, 205,338.00 |
| 4 | 6 | online large first: 107 orders, 52,844.50; store large: 210 orders, 102,848.00 |
| 5 | 3 | store large 102,848.00; store medium 82,422.50; online large 52,844.50 |

If query 5 returns 0 rows, you wrote `WHERE order_total > 50000`. That tests each order, and no single order is worth 50,000 (the largest is 1,964.50). The test belongs on the group's total, in `HAVING`. If it returns 6 rows, the `HAVING` line is missing. If query 4 shows online large with 114 orders, or query 5 returns 4 rows, the `WHERE status = 'completed'` line is missing.

## Hint

Every column in `SELECT` is either in the `GROUP BY` or inside a function such as `SUM` or `COUNT`. `SUM` makes one total from many rows; BigQuery cannot put two channels beside one number.

An order of exactly 200.00 is large: `CASE` checks the `WHEN` lines from the top and stops at the first one that is true.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../D04/03-Evr-Upload-Nakheel/Resources/README.md).
