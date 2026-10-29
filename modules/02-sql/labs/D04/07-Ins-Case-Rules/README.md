# Make a column from a rule

In this activity, you will write a business rule in words, turn it into a `CASE` expression, and group by the new column.

**Time:** 8 minutes · **Data:** `nakheel.orders` (activity 03) · **File:** `Solved/case_rules.sql`

## Instructions

1. Write the rule in words first, as a comment: "An order is large from 200 dinars, medium from 50, otherwise small."

2. Open `Solved/case_rules.sql`. Run query 1. The rule becomes a new column, `size_band`, on every order. The query ends with `ORDER BY order_id LIMIT 10`, so you see the first 10 of the 3,000 orders. `CASE` checks the `WHEN` lines from the top and stops at the first one that is true. That is why the 200 line comes before the 50 line. Swap them and no order is ever large: every order from 200 is also from 50, so it stops at the 50 line.

3. Run query 2. A `CASE` column can be grouped like any other column. Completed orders, sorted by `revenue`, largest first: 317 large, 1,342 medium, 1,112 small.

4. Compare the counts with the revenue. Large orders are 11% of completed orders and almost half of completed revenue.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 10 | first 10 orders by `order_id`; order 100001: 22.50, small |
| 2 | 3 | large: 317 orders, 155,692.50 |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
