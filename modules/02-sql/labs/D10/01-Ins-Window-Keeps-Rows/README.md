# A window keeps the rows

In this activity, you will answer D08's "Which months were better than our average month?" a third way: with `AVG(...) OVER ()`, a window function that puts the average next to every month without collapsing the rows.

**Time:** 12 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **File:** `Solved/window_keeps_rows.sql`

You have answered this question twice. On D08 you used two CTEs, `monthly` and `average_month`. On D09 you used one CTE read twice, with a subquery in `WHERE`. Today, one CTE and one window.

## Instructions

1. **`GROUP BY` collapses.** Run the average month on its own:

    ```sql
    WITH monthly AS (
      SELECT DATE_TRUNC(order_date, MONTH) AS month,
             SUM(order_total) AS revenue
      FROM nakheel.orders
      WHERE status = 'completed'
      GROUP BY month
    )
    SELECT ROUND(AVG(revenue), 2) AS avg_month
    FROM monthly;
    ```

    You should see 1 row: 13,167.65. `AVG` collapsed 24 months into one number, so the months are gone.

2. **`OVER ()` keeps the rows.** Change the final `SELECT` so it keeps every month and adds the average beside it:

    ```sql
    SELECT month,
           revenue,
           ROUND(AVG(revenue) OVER (), 2) AS avg_month
    FROM monthly
    ORDER BY month;
    ```

    You should see 24 rows, and `avg_month` is 13,167.65 on every row.

    - `AVG(revenue) OVER ()` is a **window function**: it calculates over a set of rows, the window, and writes the answer on each row instead of collapsing them.
    - The empty brackets after `OVER` mean "the window is every row". In the next activity you will split it into groups.
    - On D09 a subquery in `SELECT` put one number on every row. A window does the same without writing the query a second time.

3. **Keep the months above the average.** A window function cannot go in `WHERE`, because `WHERE` runs before the window is calculated. Put the step with the window in a CTE, then filter it:

    ```sql
    WITH monthly AS (
      SELECT DATE_TRUNC(order_date, MONTH) AS month,
             SUM(order_total) AS revenue
      FROM nakheel.orders
      WHERE status = 'completed'
      GROUP BY month
    ),
    with_average AS (
      SELECT month,
             revenue,
             AVG(revenue) OVER () AS avg_month
      FROM monthly
    )
    SELECT month,
           ROUND(revenue, 2) AS revenue
    FROM with_average
    WHERE revenue > avg_month
    ORDER BY month;
    ```

    You should see 8 rows, the same 8 months as on D08 and D09: April 2026 the best with 20,237.00.

4. **The dead end.** Try the filter directly: `WHERE revenue > AVG(revenue) OVER ()` in the same `SELECT` as the window. BigQuery refuses: analytic (window) functions are not allowed in `WHERE`. That is why step 3 needs the second CTE.

5. **A preview: `QUALIFY`.** BigQuery has a shortcut for exactly this. `QUALIFY` filters on a window's result, the way `HAVING` filters on a group. Keep the `monthly` CTE and replace everything after it:

    ```sql
    SELECT month,
           ROUND(revenue, 2) AS revenue
    FROM monthly
    QUALIFY revenue > AVG(revenue) OVER ()
    ORDER BY month;
    ```

    You should see the same 8 months as step 3, with no second CTE. You will use `QUALIFY` properly after ranking, in activity 05.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 13,167.65 |
| 2 | 24 | 13,167.65 on every row |
| 3 | 8 | April 2026, 20,237.00 |
| 5 | 8 | the same 8 months as step 3 |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
