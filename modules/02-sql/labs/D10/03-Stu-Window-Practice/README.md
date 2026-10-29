# Window practice: compare a row with its group

In this activity, you will answer three manager questions that compare each row with its group, using `OVER ()` and `OVER (PARTITION BY ...)`.

**Time:** 12 minutes · **Data:** `nakheel.orders`, `nakheel.customers` (D04 activity 03) · **Starter:** `Unsolved/window_practice.sql`

Before every query: what is one row, and what is the window?

## Instructions

1. **"Show each completed order next to the average order of its channel."** One row per completed order: `order_id`, `channel`, `order_total`, and the channel's average order, rounded to 2 decimals, as `channel_avg`. Sort by `order_id`.

    Translate: no `GROUP BY`; `ROUND(AVG(order_total) OVER (PARTITION BY channel), 2) AS channel_avg`; `ORDER BY order_id`.

2. **"Which customers spend more than the average customer in their own segment?"** Count them per segment.

    Translate:
    - Step 1, a CTE `customer_revenue`: one row per customer with a completed order: `o.customer_id`, the cleaned segment (`LOWER(TRIM(c.segment)) AS segment_clean`) and `SUM(o.order_total) AS revenue`. Use an `INNER JOIN` to `customers`, so the order with no customer drops out. Check: 451 rows.
    - Step 2, a CTE `with_segment_average`: every row of step 1 plus `AVG(revenue) OVER (PARTITION BY segment_clean) AS segment_avg`.
    - The answer: the rows above their segment's average, counted per segment: `segment_clean` and `COUNT(*) AS customers_above_average`, sorted by segment (`ORDER BY segment_clean`).

3. **"What share of its year's revenue did each month bring?"** One row per month with its completed revenue, its year's revenue, and its share as a percentage rounded to 1 decimal. Sort by share, highest first.

    Translate: a `monthly` CTE as on D08; then `SUM(revenue) OVER (PARTITION BY EXTRACT(YEAR FROM month)) AS year_revenue`, and the share `AS share_pct`; `ORDER BY share_pct DESC`.

    Look at the top four rows before you write the answer. Why are they all from 2024? (Hint: how many months of 2024 are in the data?)

## Check yourself

| Question | Rows returned | One value to check |
|---|---:|---|
| 1 | 2,771 | order 100001, store, 22.50, store average 116.47 |
| 2 | 2 | retail 98 · wholesale 11 |
| 3 | 24 | December 2024 first, 28.2 |

In question 2, the averages are 409.37 for retail and 2,658.69 for wholesale: the same as D08's "typical customer in each segment".

## Hint

A window function cannot go in `WHERE`. When you need to filter on a window's result (question 2), put the window in a CTE and filter in the next step.

## Bonus

In question 3, which month of 2025, a full year, brought the biggest share? Keep only 2025, sort by share, highest first, and keep one row (`LIMIT 1`). Is that a fairer comparison than December 2024's 28.2%?

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
