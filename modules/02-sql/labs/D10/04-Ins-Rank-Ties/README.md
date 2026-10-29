# Rank within a group, and what a tie does

In this activity, you will rank the Sportswear products by units sold with `ROW_NUMBER`, `RANK` and `DENSE_RANK`, and see how each handles the two products that sold exactly 284 units.

**Time:** 12 minutes · **Data:** `nakheel.order_items`, `nakheel.orders`, `nakheel.products` (D04 activity 03) · **File:** `Solved/rank_ties.sql`

## Instructions

1. **Units per Sportswear product.** One row per product, completed orders only:

    ```sql
    WITH product_units AS (
      SELECT p.category,
             p.product_name,
             SUM(i.qty) AS units
      FROM nakheel.order_items AS i
      INNER JOIN nakheel.orders AS o
        ON i.order_id = o.order_id
      INNER JOIN nakheel.products AS p
        ON i.product_id = p.product_id
      WHERE o.status = 'completed'
      GROUP BY p.category, p.product_name
    )
    SELECT *
    FROM product_units
    WHERE category = 'Sportswear'
    ORDER BY units DESC;
    ```

    You should see 9 rows, Water bottle first with 608 units. Gym shorts and Compression top both sold 284.

2. **Three ways to number the rows.** Replace the final `SELECT`:

    ```sql
    SELECT product_name,
           units,
           ROW_NUMBER() OVER (ORDER BY units DESC) AS row_num,
           RANK()       OVER (ORDER BY units DESC) AS rank_num,
           DENSE_RANK() OVER (ORDER BY units DESC) AS dense_num
    FROM product_units
    WHERE category = 'Sportswear'
    ORDER BY units DESC;
    ```

    - `ORDER BY` inside `OVER` sets the order the window counts in. It is separate from the `ORDER BY` at the end, which only sorts the output.
    - `ROW_NUMBER` gives every row its own number: 1, 2, 3 … The two products on 284 get 6 and 7, in no fixed order.
    - `RANK` gives a tie the same number and then skips: 6, 6, then 8.
    - `DENSE_RANK` gives a tie the same number and does not skip: 6, 6, then 7.

    You should see 9 rows. Football jersey is 8 in `row_num` and `rank_num`, and 7 in `dense_num`.

3. **Make `ROW_NUMBER` repeatable.** Run step 2 twice. Which of the two 284 products is 6 can change between runs, because nothing tells BigQuery how to break the tie. Add a second sort column inside `OVER`: `ROW_NUMBER() OVER (ORDER BY units DESC, product_name)`. Now Compression top is always 6 and Gym shorts 7.

4. **Every category at once.** Remove `WHERE category = 'Sportswear'` and add `PARTITION BY category` inside each `OVER`, before its `ORDER BY`:

    ```sql
    RANK() OVER (PARTITION BY category ORDER BY units DESC) AS rank_num
    ```

    Add `category` as the first column, so you can see which category each rank belongs to, and sort by category, then rank, then name, so tied products always print in the same order: `ORDER BY category, rank_num, product_name`.

    The numbering starts again at 1 in each category. You should see 56 rows; each category's best seller has `rank_num` 1.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 9 | Water bottle first, 608 units |
| 2 | 9 | Football jersey: 8, 8, 7 |
| 4 | 56 | six products with rank_num 1 |

## Which one to use

| Function | A tie gets | Use it when |
|---|---|---|
| `ROW_NUMBER` | different numbers | you need exactly N rows, for example one row per customer |
| `RANK` | the same number, then a gap | a league table: two teams joint 6th, the next is 8th |
| `DENSE_RANK` | the same number, no gap | "the top three places", however many share them |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
