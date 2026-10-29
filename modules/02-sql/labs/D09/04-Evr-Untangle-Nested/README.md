# Untangle a nested query

In this activity, you will take two nested queries that already work and rewrite each one as a CTE, then prove the rewrite gives exactly the same answer.

**Time:** 15 minutes · **Data:** `nakheel.orders`, `nakheel.customers` (D04 activity 03) · **Starter:** `Unsolved/untangle.sql`

The recipe, every time:

1. Find the innermost brackets: that is step 1.
2. Cut it out, paste it at the top inside `WITH <name> AS ( ... )`, and name it after what one row of it is.
3. Where the brackets were, write the name.
4. Run, and compare with the nested version's answer.

## Instructions

1. **The nested query from "Do our customers come back?"** Run it as it is in the starter and note the answer: 2 rows, came back 323 and one order 129.

    ```sql
    SELECT CASE
             WHEN completed_orders = 1 THEN 'one order'
             ELSE 'came back'
           END AS kind,
           COUNT(*) AS customers
    FROM (SELECT customer_id,
                 COUNT(*) AS completed_orders
          FROM nakheel.orders
          WHERE status = 'completed'
          GROUP BY customer_id) AS per_customer
    GROUP BY kind
    ORDER BY kind;
    ```

    Rewrite it as a CTE named `per_customer`. The outer query becomes `FROM per_customer`. Run it: the same 2 rows.

2. **A nested query that repeats itself: "Which months were better than our average month?"** This is the D08 pipeline question, written without CTEs:

    ```sql
    SELECT month,
           ROUND(revenue, 2) AS revenue
    FROM (SELECT DATE_TRUNC(order_date, MONTH) AS month,
                 SUM(order_total) AS revenue
          FROM nakheel.orders
          WHERE status = 'completed'
          GROUP BY month) AS monthly
    WHERE revenue > (SELECT AVG(revenue)
                     FROM (SELECT DATE_TRUNC(order_date, MONTH) AS month,
                                  SUM(order_total) AS revenue
                           FROM nakheel.orders
                           WHERE status = 'completed'
                           GROUP BY month) AS monthly_again)
    ORDER BY month;
    ```

    Run it: 8 rows, April 2026 the best with 20,237.00. Look at it before you rewrite it: the monthly revenue query is written **twice**. If someone changes one copy (for example to count pending orders too) and forgets the other, the answer is wrong and nothing warns them.

    Rewrite it with one CTE, `monthly`, used in both places: once in `FROM`, once inside the `WHERE` subquery. Run it: the same 8 rows.

3. Compare the two versions of query 2 side by side. Which one could a colleague check in one minute? A CTE written once can be read many times; that is the second reason to use one, after reading top to bottom.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1, nested and CTE | 2 | came back 323 · one order 129 |
| 2, nested and CTE | 8 | April 2026, 20,237.00 |

## Hint

A CTE can be read more than once in the same query. `WHERE revenue > (SELECT AVG(revenue) FROM monthly)` reads `monthly` a second time without repeating it.

## Bonus

"Who is our biggest customer by completed revenue? I want the name." Question 4 of D08's [Subquery practice](../../D08/03-Stu-Subquery-Practice/README.md) (tonight's after-class work) answers it with a subquery inside `WHERE`. Here, answer it with two CTEs instead: `customer_revenue` (one row per customer) and `top_customer` (the one row with the most revenue: sort by `revenue`, largest first, and keep the first row with `ORDER BY revenue DESC LIMIT 1`), then join `top_customer` to `nakheel.customers` for the name. Show `customer_id`, `customer_name` and `revenue`. You should get C-1380, Leen Najjar.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
