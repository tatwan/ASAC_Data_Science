# Three places a subquery can live

In this activity, you will put the same inner query, "the average completed order", in three places in an outer query, `WHERE`, `SELECT` and `FROM`, and see what each place needs from it.

**Time:** 15 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **File:** `Solved/three_places.sql`

A subquery is a query inside another query, in brackets. The inner query runs first, and the outer query uses its answer. Where you put the brackets decides what the answer must look like.

| Place | What the outer query needs | Example |
|---|---|---|
| `WHERE` | one value to compare with (`=`, `>`), or a list for `IN` | orders bigger than the average |
| `SELECT` | exactly one value, repeated on every row | each order next to the average |
| `FROM` | a table, which you give a name with `AS` | first one row per customer, then count them |

## Instructions

1. **The inner query on its own.** Type and run it. Before you run it, say what one row of the result is.

    ```sql
    SELECT AVG(order_total) AS average_order
    FROM nakheel.orders
    WHERE status = 'completed';
    ```

    You should see 1 row: 114.05 (BigQuery shows more decimals).

2. **In `WHERE`: "Which completed orders are bigger than our average order?"** This is the D08 query. Run it again.

    ```sql
    SELECT order_id, customer_id, order_total
    FROM nakheel.orders
    WHERE status = 'completed'
      AND order_total > (SELECT AVG(order_total)
                         FROM nakheel.orders
                         WHERE status = 'completed')
    ORDER BY order_total DESC;
    ```

    You should see 689 rows, order 100849 first with 1,964.50. `>` compares each order with one number, so the inner query must return one row.

3. **In `SELECT`: "Show each completed order next to the average, and by how much it beats it."** The same brackets, now as a column.

    ```sql
    SELECT order_id,
           order_total,
           ROUND((SELECT AVG(order_total)
                  FROM nakheel.orders
                  WHERE status = 'completed'), 2) AS average_order,
           ROUND(order_total - (SELECT AVG(order_total)
                                FROM nakheel.orders
                                WHERE status = 'completed'), 2) AS above_average_by
    FROM nakheel.orders
    WHERE status = 'completed'
    ORDER BY above_average_by DESC;
    ```

    You should see 2,771 rows. The `average_order` column says 114.05 on every row. Order 100849 is first, 1,850.45 above the average.

    A subquery in `SELECT` must return exactly one value, because it fills one cell of every row. Notice that the same subquery is written twice: keep that in mind for later today.

4. **In `FROM`: "How many customers have spent more than 1,000 with us?"** You cannot answer that from `orders` in one step: first you need one row per customer with what each spent, then you count the rows over 1,000. Run the inner query alone first:

    ```sql
    SELECT customer_id,
           SUM(order_total) AS revenue
    FROM nakheel.orders
    WHERE status = 'completed'
    GROUP BY customer_id;
    ```

    You should see 452 rows: one per customer with a completed order. Now put it in brackets after `FROM`, give it a name with `AS`, and read it like a table:

    ```sql
    SELECT COUNT(*) AS customers_over_1000
    FROM (SELECT customer_id,
                 SUM(order_total) AS revenue
          FROM nakheel.orders
          WHERE status = 'completed'
          GROUP BY customer_id) AS per_customer
    WHERE revenue > 1000;
    ```

    You should see 1 row: 60. The outer `WHERE` filters the rows of `per_customer`, so it can use `revenue`, a column that does not exist in `orders`.

5. **Read it inside out.** For each of the three queries, point to the part that runs first. In every case it is the part in brackets. People read top to bottom; a nested query runs from the inside out. That is what a CTE will fix later today.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 114.05 |
| 2 | 689 | order 100849 first, 1,964.50 |
| 3 | 2,771 | order 100849 first, 1,850.45 above the average |
| 4 | 1 | 60 customers |

## Hint

If you see `Scalar subquery produced more than one element`, a subquery in `WHERE` (with `=` or `>`) or in `SELECT` returned more than one row. Run the inner query alone and count its rows.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
