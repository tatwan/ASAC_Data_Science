# Lab: Best sellers and trends

In this lab, you will rank Nakheel's products by units sold inside each category, follow each channel's revenue month by month, and keep each category's top three with their share, using the window functions from today.

**When:** after class. Not submitted, not graded; the Solved file is released afterwards. · **Data:** `nakheel.orders`, `nakheel.order_items`, `nakheel.products` (D04 activity 03) · **Starter:** `Unsolved/rank_and_trend_lab.sql`

**How this lab is organised:** C1, C2 and C3 are checkpoints. Each builds on what you did in class; check yours against the numbers before you go on.

## C1. Rank the products by units sold

"Inside each category, which products sell the most units, and where are the ties?"

1. A CTE `product_units`: one row per category and product, `SUM(i.qty) AS units`, completed orders only. Check: 56 rows, 18,108 units in all.
2. In the final `SELECT`, show `category`, `product_name` and `units`, and add both `RANK()` and `DENSE_RANK()`, each `OVER (PARTITION BY category ORDER BY units DESC)`, as `unit_rank` and `unit_dense_rank`. Sort by category, then rank, then product name: `ORDER BY category, unit_rank, product_name`.
3. Find the tie: the two products whose `RANK` is the same. What does the product after them get in each column?

**Checkpoint C1:** 56 rows. In Sportswear, Gym shorts and Compression top both have 284 units and rank 6; Football jersey is 8 with `RANK` and 7 with `DENSE_RANK`.

## C2. Each channel, month by month

"For each channel, how did revenue change on the month before, and how much has each channel brought in so far?"

1. A CTE `channel_month`: one row per channel and month, completed revenue: `channel`, `month`, `revenue`. Check: 48 rows.
2. Add `revenue - LAG(revenue) OVER (PARTITION BY channel ORDER BY month) AS change`.
3. Add a running total for each channel: `SUM(revenue) OVER (PARTITION BY channel ORDER BY month) AS running_total`. Sort by channel, then month: `ORDER BY channel, month`.
4. Audit: the last month of each channel must equal that channel's completed revenue. Check it with a second query: completed revenue per channel (`GROUP BY channel`, `ORDER BY channel`).

**Checkpoint C2:** 48 rows. Online's largest monthly rise is August 2025, +2,399.00. The last `running_total` is 110,685.50 for online and 205,338.00 for store, which add up to 316,023.50.

## C3. The top three in each category, and their share

"For each category, which three products sell the most units, and what share of the category's units does each one take?"

1. From `product_units`, show `category`, `product_name` and `units`; add the rank by units inside the category (`RANK() ... AS unit_rank`) and the share of the category's units, rounded to 1 decimal: `ROUND(100 * units / SUM(units) OVER (PARTITION BY category), 1) AS share_of_category_units`.
2. Keep the top three with `QUALIFY unit_rank <= 3`. Sort by category, then rank: `ORDER BY category, unit_rank`.

**Checkpoint C3:** 18 rows. Slide sandal takes 19.4% of Shoes units, the largest share of any top seller; Water bottle sells the most units of any product, 608.

Why is the share right even though `QUALIFY` removes rows? The windows are calculated before `QUALIFY` runs, so `SUM(units) OVER (...)` still sees every product in the category.

## More practice (not checked, not submitted)

- Rank the cities by completed revenue inside each segment. Use the D07 city rule.
- For each month, which category was first by revenue? (One row per month: 24 rows.)
- Add `LEAD(revenue) OVER (ORDER BY month)` to the monthly query. What does the last month show, and why?
- "What was each customer's most recent completed order?" One row per customer: the order ID, its date and its total.

    Translate: completed orders; `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC)`; keep number 1 with `QUALIFY`; `ORDER BY customer_id`. You should see 452 rows, one per customer who has bought. The same pattern removes duplicate rows (4.2 in class).

- **Optional: write the city rule once, as a function.** The D07 city rule is a `CASE` you have typed in several queries. A SQL function (a UDF, user-defined function) writes it once:

    ```sql
    CREATE TEMP FUNCTION clean_city(city STRING) AS (
      CASE
        WHEN city IS NULL THEN 'unknown'
        WHEN LOWER(TRIM(city)) = 'al zarqa' THEN 'zarqa'
        ELSE LOWER(TRIM(city))
      END
    );
    SELECT clean_city(city) AS city_clean,
           COUNT(*) AS customers
    FROM nakheel.customers
    GROUP BY city_clean
    ORDER BY customers DESC;
    ```

    Run both statements together. You should see 9 rows (8 cities and unknown), amman first with 196 customers: the same cities as `bi.dim_customer`. A `TEMP` function lasts only while its query runs; `CREATE FUNCTION bi.clean_city(...)` keeps it in the dataset, like a view. BigQuery can also write functions in JavaScript; this course does not use them. Not in Assignment 1.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
