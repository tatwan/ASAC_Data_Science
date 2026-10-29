# Do our customers come back?

In this activity, you will answer "Do our customers come back after their first order?" with a subquery in `FROM`: first one row per customer, then a question about those rows.

**Time:** 12 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **Starter:** `Unsolved/subquery_in_from.sql`

The question is about customers, but the data is one row per order. So the answer takes two grains: first count each customer's completed orders (one row per customer), then summarise those counts.

## Instructions

1. **Step 1 alone: completed orders per customer.** Before you run it, say what one row is and predict the row count.

    Translate: `nakheel.orders`, completed only, `COUNT(*) AS completed_orders`, `GROUP BY customer_id`. Sort by `completed_orders`, most first.

    You should see 452 rows. C-1270 has the most, 126 completed orders.

2. **The shortcut that does not work.** "The average number of orders per customer" sounds like one query. Try it:

    ```sql
    SELECT AVG(COUNT(*)) AS avg_orders
    FROM nakheel.orders
    WHERE status = 'completed'
    GROUP BY customer_id;
    ```

    BigQuery stops with `Multi-level aggregation requires the enclosing aggregate function to have one or more GROUP BY modifiers`. In plain words: you put one aggregate (`COUNT`) inside another (`AVG`) in a single `SELECT`. `COUNT(*)` and `AVG` belong to two different grains: `COUNT(*)` collapses each customer's orders, and `AVG` should then collapse the customers. One `SELECT` has only one grain, so the first step has to finish before the second starts.

3. **Step 2: put step 1 in `FROM`.** "On average, how many completed orders does a customer place, and what are the fewest and the most?"

    Translate: `FROM (step 1) AS per_customer`, then `AVG(completed_orders)` rounded to 2 decimals, `MIN(completed_orders)`, `MAX(completed_orders)`.

    You should see 1 row: 6.13, 1 and 126.

4. **The manager's question: "How many customers bought once, and how many came back?"** Keep step 1 in `FROM`. In the outer query, label each customer with `CASE`: `'one order'` when `completed_orders = 1`, otherwise `'came back'`. Then count the customers in each group.

    Translate: `CASE WHEN completed_orders = 1 THEN 'one order' ELSE 'came back' END AS kind`, `COUNT(*) AS customers`, `GROUP BY kind`. Sort by `kind` (`ORDER BY kind`), so `came back` comes first.

    You should see 2 rows: came back 323, one order 129.

5. Say the answer in one sentence a manager can use. For example: "Of the 452 customers with a completed order, 323 came back at least once; 129 bought once and did not return."

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 452 | C-1270 first, 126 |
| 3 | 1 | 6.13 · 1 · 126 |
| 4 | 2 | came back 323 · one order 129 |

452 is 451 customers in `customers` plus C-0999, the order whose customer is missing (you met it on D06).

## Hint

The outer query reads `per_customer` like a table, so it can only use the columns step 1 returns: `customer_id` and `completed_orders`. If BigQuery says `Unrecognized name: order_total`, you used a column from `orders` that step 1 did not keep.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
