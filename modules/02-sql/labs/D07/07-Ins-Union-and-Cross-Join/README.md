# UNION and CROSS JOIN

In this activity, you will stack two results with `UNION ALL` and `UNION DISTINCT`, meet the BigQuery error for a bare `UNION`, and pair every row with every row using `CROSS JOIN`.

**Time:** 15 minutes · **Data:** `D03.customers`, `D03.orders`, `D03.products`, `D03.order_items` (D03 activity 01), `nakheel.customers`, `nakheel.orders` (D04 activity 03) · **Files:** `Solved/union.sql`, `Solved/cross_join.sql`

A join puts tables **side by side** on a key and adds columns. `UNION` puts one result **under** another and adds rows. It needs no key, only matching columns: both queries return the same number of columns, in the same order, with matching types, and the result takes its column names from the first query.

## Instructions

### Stack with UNION (`Solved/union.sql`)

1. Run query 1, customers in Amman. You should see C-118 and C-377. C-455 has no city, so `city = 'Amman'` does not keep it: `NULL` again.

2. Run query 2, the customer on each completed order. You should see 4 rows: C-204 twice, C-401 and C-118.

3. Type the `UNION ALL` query yourself and run it:

    ```sql
    SELECT customer_id
    FROM D03.customers
    WHERE city = 'Amman'
    UNION ALL
    SELECT customer_id
    FROM D03.orders
    WHERE status = 'completed';
    ```

    You should see 6 rows. `UNION ALL` keeps every row: 2 + 4. There are two kinds of repeat in the result: C-118 is in both queries, and C-204 repeats inside query 2, once per order.

4. Change `ALL` to `DISTINCT` and add `ORDER BY customer_id` at the end. You should see 4 rows: C-118, C-204, C-377, C-401. `DISTINCT` removes repeats inside each query as well as between them. Without `ORDER BY` the row order is not guaranteed.

5. Delete `DISTINCT` so the line reads only `UNION`, and run. BigQuery stops with `Syntax error: Expected keyword ALL or keyword DISTINCT but got keyword SELECT`. This is BigQuery-specific: PostgreSQL, SQL Server, MySQL and Snowflake accept a bare `UNION` and read it as `DISTINCT`. BigQuery makes you say which you mean.

6. The rule to keep: stack data with `UNION ALL`, then check that rows out = rows in query 1 + rows in query 2. Use `UNION DISTINCT` when you want a list of different values. A common use is tables with the same columns split by period or branch, such as one export per month, stacked into one before analysis.

    For PL-300: Power Query's **Append** keeps every row like `UNION ALL`, but lines columns up **by name**. SQL's `UNION`, and DAX's `UNION()`, go by position.

### Pair every row with CROSS JOIN (`Solved/cross_join.sql`)

7. `CROSS JOIN` pairs every row of one table with every row of the other. There is no `ON`: rows out = rows in A × rows in B. Predict the row count for 5 customers and 5 orders, then run query 1. You should see 25 rows. Each row is one pair, whether the keys match or not.

8. Run query 2: the same pairs, keeping only those where the keys match. You should see 5 rows, the same as the `INNER JOIN` in [INNER JOIN and LEFT JOIN](../../D06/03-Evr-Inner-and-Left/README.md) on D06. Every join starts from this grid of pairs and keeps part of it.

9. Run query 3. At Nakheel the grid has 500 × 3,000 = 1,500,000 rows. Count them; never select them all. A join on a column that repeats on both sides, such as a name or a city, grows toward this size. Check 3 of the Five Checks catches it.

10. One use: every customer against every category, so the pairs with no sale still get a row. Run query 4. You should see 5 × 3 = 15 rows. It uses a list of categories inside brackets, a subquery, which you learn on D08.

11. Run query 5 and read the result; do not type it. It fills in the completed revenue for each of the 15 pairs. It answers "Which customers have never bought Outerwear?": four, C-118, C-204, C-377 and C-455. C-118's rain jacket was on cancelled order 1002, so it does not count, which is the D01 trap again.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| Union 1 | 2 | C-118, C-377 |
| Union 2 | 4 | C-204 appears twice |
| Union 3 | 6 | 2 + 4 |
| Union 4 | 4 | C-118, C-204, C-377, C-401 |
| Cross 1 | 25 | 5 × 5 |
| Cross 2 | 5 | the `INNER JOIN` rows |
| Cross 3 | 1 | 1,500,000 |
| Cross 4 | 15 | 5 customers × 3 categories |
| Cross 5 | 15 | 9 pairs are 0; four customers have 0 for Outerwear |

The bare `UNION` in step 5 (the last query in `union.sql`) returns an error on purpose.

## References

The D01 tables (the `D03` dataset), course-owned synthetic data, 19 September 2026. Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../D04/03-Evr-Upload-Nakheel/Resources/README.md).
