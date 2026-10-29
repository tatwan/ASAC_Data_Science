# One query that uses the whole module

In this activity, you will answer one manager question with everything from D03 to D10 in a single query: a join, `CASE`, `GROUP BY`, CTEs and two window functions.

**Time:** 20 minutes · **Data:** `nakheel.orders`, `nakheel.customers` (D04 activity 03) · **Starter:** `Unsolved/whole_module.sql`

**The question:** "For each segment, who are our three biggest customers, which city are they in, and what share of the segment's completed revenue does each one bring?"

## Instructions

1. **Plan the steps in comments before any SQL.** Say what one row of each step is.

    - Step 1, `customer_revenue`: one row per customer with a completed order. Join `orders` to `customers` (D06); clean the city with D07's `CASE` and the segment with `LOWER(TRIM(...))` (D04); `SUM(order_total) AS revenue` per customer (`GROUP BY`). Check: 451 rows.
    - Step 2, `ranked`: every row of step 1, plus the customer's rank inside the segment (`RANK`) and its share of the segment's revenue (`SUM ... OVER (PARTITION BY ...)`). Check: 451 rows.
    - The answer: ranks 1 to 3 in each segment.

2. **Step 1.** The city rule, from D07:

    ```sql
    CASE
      WHEN c.city IS NULL THEN 'unknown'
      WHEN LOWER(TRIM(c.city)) = 'al zarqa' THEN 'zarqa'
      ELSE LOWER(TRIM(c.city))
    END AS city_clean
    ```

    Group by the customer ID, the name, `city_clean` and `segment_clean`. Check 451 rows before you go on.

3. **Step 2.** Two windows, both partitioned by `segment_clean`:

    ```sql
    RANK() OVER (PARTITION BY segment_clean ORDER BY revenue DESC) AS segment_rank,
    ROUND(100 * revenue / SUM(revenue) OVER (PARTITION BY segment_clean), 1) AS share_of_segment
    ```

4. **The answer.** Show `segment_clean`, `segment_rank`, `customer_id`, `customer_name`, `city_clean`, `revenue` and `share_of_segment`. Keep `segment_rank <= 3`, sorted by segment and rank (`ORDER BY segment_clean, segment_rank`). You should see 6 rows.

5. Say the finding in one sentence. One customer, Leen Najjar in Amman, brings 22.9% of all wholesale revenue. What would you tell the sales manager?

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 451 | C-1380 Leen Najjar, amman, wholesale, 35,338.50 |
| 4 | 6 | wholesale 1: C-1380, amman, 22.9 · retail 1: C-1270, irbid, 5.3 |

451, not 452: the `INNER JOIN` to `customers` drops order 101664, whose customer is not in the table (D06).

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
