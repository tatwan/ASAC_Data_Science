# Running totals and the month before

In this activity, you will add two columns to monthly revenue: a running total, which must end at the completed revenue you already know, and the change on the previous month with `LAG`.

**Time:** 12 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **File:** `Solved/running_total_lag.sql`

## Instructions

1. **Start from the `monthly` CTE** (D08, D09 and today's 2.1): 24 rows, one per month.

2. **A running total.** Select `month` and `revenue` from `monthly`, add this column, and sort by month (`ORDER BY month`):

    ```sql
    SUM(revenue) OVER (ORDER BY month) AS running_total
    ```

    - With `ORDER BY` inside `OVER`, the window for each row is every row from the first month up to this one. So each month's `running_total` is the revenue so far.
    - Without `ORDER BY` (2.1), the window was every row, and every month got the same total.

    You should see 24 rows. September 2024 is 11,268.00 and **August 2026 is 316,023.50**: completed revenue for the whole period, the number you have checked since D04. If the last row does not match it, the running total is wrong.

3. **The month before, with `LAG`.** Keep the query from step 2, still sorted by month, and add two columns:

    ```sql
    LAG(revenue) OVER (ORDER BY month) AS previous_month,
    revenue - LAG(revenue) OVER (ORDER BY month) AS change
    ```

    - `LAG(revenue)` reads `revenue` from the row before, in the window's order.
    - The first month has no row before it, so its `previous_month` and `change` are `NULL`.

    You should see 24 rows. April 2026 is up 5,792.50 on March; May 2026 is down 7,473.00.

4. **A running total that restarts every year.** Write a new final `SELECT` on the same `monthly` CTE with three columns, `month`, `revenue` and `year_to_date`, sorted by month (`ORDER BY month`). `year_to_date` is step 2's running total with `PARTITION BY` added before the `ORDER BY`:

    ```sql
    SUM(revenue) OVER (PARTITION BY EXTRACT(YEAR FROM month) ORDER BY month) AS year_to_date
    ```

    December 2025's `year_to_date` is 147,589.00: completed revenue for 2025. Power BI calls this measure "year to date" (D20).

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 2 | 24 | last running_total 316,023.50 |
| 3 | 24 | April 2026 change +5,792.50 |
| 4 | 24 | December 2025 year_to_date 147,589.00 |

## Reference: what you will meet later

`LEAD(revenue)` reads the row **after**; recognise it when you see it. A moving average, for example the last three months, uses a frame: `AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`. The next step, [Four more jobs for a window](../13-Ins-More-Window-Jobs/README.md), shows it once.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
