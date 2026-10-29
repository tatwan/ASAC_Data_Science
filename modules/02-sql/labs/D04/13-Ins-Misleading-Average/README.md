# The misleading average

In this activity, you will answer "what does a typical order cost?" twice, at two different grains, and see that both answers are correct.

**Time:** 10 minutes · **Data:** `nakheel.orders`, `nakheel.order_items` (activity 03) · **File:** `Solved/misleading_average.sql`

## Instructions

1. Open `Solved/misleading_average.sql`. Run query 1: the average value of one order **line** (one product on one order), completed orders only, rounded to 2 decimals, with the number of lines. You should see 45.46 dinars.

    The query uses `IN (SELECT …)` to keep the lines of completed orders, because `order_items` has no status. That is a subquery, and D08 covers it. For now, read it as "the order IDs of completed orders".

2. Run query 2: the average value of one **order**, completed orders only, rounded to 2 decimals, with the number of orders. You should see 114.05 dinars.

3. Both are averages of the same money. They differ because one row means something different in each table. Before you report an average, say what one row is.

4. Run query 3. 2,082 of the 2,771 completed orders are below the 114.05 average. A few very large wholesale orders pull it up. "Typical" and "average" are not the same word.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 45.46 over 6,951 lines |
| 2 | 1 | 114.05 over 2,771 orders |
| 3 | 1 | 2,082 of 2,771 below the average |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
