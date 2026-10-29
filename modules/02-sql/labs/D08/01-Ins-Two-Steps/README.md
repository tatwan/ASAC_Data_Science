# A question in two steps

In this activity, you will answer "Which completed orders are bigger than our average completed order?" in two steps, then put the first step inside the second as a subquery.

**Time:** 12 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **File:** `Solved/two_steps.sql`

You cannot compare each order with the average until you know the average. So the question has two steps: find the average, then compare every order with it.

## Instructions

1. Step 1 on its own: "What is our average completed order?" One row of the answer is one number for the whole table. Type and run:

    ```sql
    SELECT ROUND(AVG(order_total), 2) AS average_order
    FROM nakheel.orders
    WHERE status = 'completed';
    ```

    You should see 1 row: 114.05.

2. Step 2, with that number typed in by hand. Type and run:

    ```sql
    SELECT order_id, customer_id, order_total
    FROM nakheel.orders
    WHERE status = 'completed'
      AND order_total > 114.05
    ORDER BY order_total DESC;
    ```

    You should see 689 rows. Order 100849 comes first, 1,964.50.

    You type 114.05 by hand here only to see why a subquery is better. The number is copied from step 1, so it is right today. When a new order arrives tomorrow, the average changes and this query does not. Someone has to remember to run step 1 again, and nothing warns you if they forget.

3. Put step 1 inside step 2. Replace `114.05` with the step 1 query in brackets, then run:

    ```sql
    SELECT order_id, customer_id, order_total
    FROM nakheel.orders
    WHERE status = 'completed'
      AND order_total > (SELECT AVG(order_total)
                         FROM nakheel.orders
                         WHERE status = 'completed')
    ORDER BY order_total DESC;
    ```

    - A **subquery** is a query inside another query, in brackets. BigQuery runs the inner query first, gets one number, and uses it where 114.05 was.
    - The inner query has no `ROUND`, so the comparison uses the exact average. Here both give the same rows.

    You should see 689 rows again, order 100849 first. The answer is the same, and now the average is worked out fresh every time the query runs.

4. Make this a habit: run the inner query on its own before the outer one. Select only the text inside the brackets and click **Run**; BigQuery runs just the selected text. If it does not give the number you expect, the outer query cannot be right.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 114.05 |
| 2 | 689 | order 100849 first, 1,964.50 |
| 3 | 689 | order 100849 first, 1,964.50 |

Why not just use the number? For a one-off answer you can. For a report that runs every week, the typed number goes out of date and nothing tells you.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../D04/03-Evr-Upload-Nakheel/Resources/README.md).
