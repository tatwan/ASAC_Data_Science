# A two-step pipeline

In this activity, you will answer "Which months were better than our average month?" with two CTEs, checking the rows after each step before you add the next.

**Time:** 15 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **Starter:** `Unsolved/months_above_average.sql`

Before you type anything, plan the steps in a comment: (1) completed revenue per month; (2) the average of those months; (3) the months above that average.

## Instructions

1. Step 1 as a CTE named `monthly`, then read it with `SELECT * FROM monthly ORDER BY month` to check it.

    Translate: `DATE_TRUNC(order_date, MONTH) AS month` (from D04, [Work with dates](../../D04/08-Evr-Dates/README.md)), completed orders only, `SUM(order_total) AS revenue`, `GROUP BY month`.

    You should see 24 rows, one per month, September 2024 first with 11,268.00.

2. Step 2: after the closing bracket of `monthly`, type a comma and a second CTE, `average_month`, that reads the first:

    ```sql
    average_month AS (
      SELECT AVG(revenue) AS avg_revenue
      FROM monthly
    )
    ```

    Change the final `SELECT` to read `average_month`, rounded to 2 decimals. You should see 1 row: 13,167.65.

3. The answer: change the final `SELECT` to read `monthly` again and keep only the months above the average.

    Translate: `WHERE revenue > (SELECT avg_revenue FROM average_month)`. This is the subquery from [A question in two steps](../01-Ins-Two-Steps/README.md), reading a CTE instead of a table. Show `month` and `revenue`, with the revenue rounded to 2 decimals, and sort by month, oldest first (`ORDER BY month`).

    You should see 8 rows. April 2026 is the best month, 20,237.00. September 2025 is 17,472.00.

4. Why check each step before adding the next? If the final answer is wrong, you already know steps 1 and 2 were right, so the problem is in the last step.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 24 | September 2024 first, 11,268.00 |
| 2 | 1 | 13,167.65 |
| 3 | 8 | April 2026, 20,237.00 |

If the query stops with a syntax error near `SELECT` or `AS`, count your `AS (` blocks and your commas. Two CTEs need exactly one comma between them and none after the last one: `WITH a AS (...), b AS (...) SELECT ...`.

## Hint

`WITH monthly AS (...)` on its own is not a query. Every `WITH` ends with a `SELECT` that reads one of its CTEs.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../D04/03-Evr-Upload-Nakheel/Resources/README.md).
