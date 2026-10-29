# First measures on Nakheel

In this activity, you will answer three questions from Nakheel's managers with `GROUP BY`, `WHERE` and `HAVING`.

**Time:** 10 minutes · **Data:** `nakheel.orders`, `nakheel.customers` (activity 03) · **Starter:** `Unsolved/nakheel_measures.sql`

For each question, write down what one row of the **result** will be before you write the query.

## Instructions

1. "How many completed orders did each channel bring in, and what were they worth?"

    Translate: completed orders, grouped by `channel`; count them and sum `order_total`; sort by the revenue, largest first.

2. "Which months of 2025 brought in more than 13,000 dinars from completed orders?"

    Translate: completed orders placed in 2025, grouped by month (`DATE_TRUNC(order_date, MONTH)`, as in activity 04), keep the months whose revenue is over 13,000; sort by month, earliest first.

3. "How many customers do we have in each city? Biggest city first."

    Translate: `customers`, grouped by `city` as it was typed, counted, sorted by the count, largest first, then by `city`.

## Check yourself

| Question | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 | store: 1,763 orders, 205,338.00 |
| 2 | 4 | September 2025: 17,472.00 |
| 3 | 11 | Amman 191; one row is `NULL` |
| Bonus | 1 | 2026-08-06, 14 orders (all statuses) |

If a count differs, check the status and year in `WHERE`. Question 2 also needs the revenue threshold in `HAVING`.

## Hint

Question 2 needs a filter on rows (the year, the status) and a filter on groups (the revenue). One goes in `WHERE`, the other in `HAVING`.

## Bonus

Which single day had the most orders, counting every status? Expect one row. Sort by the count, largest first, then by `order_date`, and keep the first row with `LIMIT 1`.

Then look again at question 3. Eleven rows, but Nakheel trades in eight cities. Which rows should be the same city? In the next hour, `TRIM` and `LOWER` merge `amman` into Amman. `Al Zarqa` needs a rule you write yourself. The `NULL` row is a missing city, not a misspelling.

## Still to answer

"Which product category brings in the most revenue?" You cannot answer it yet: categories are in `products`, and amounts are in `order_items`. That needs two tables at once, which is the subject of D06.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
