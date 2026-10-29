# Group and count Nakheel orders

In this activity, you will group Nakheel's orders by status and by month, then count the same rows three ways and explain why the three numbers differ.

**Time:** 10 minutes · **Data:** `nakheel.orders` (activity 03) · **Starter:** `Unsolved/count_three_ways.sql`

## Instructions

1. "How many orders do we have of each status?"

    Translate: `orders`, grouped by `status`, counted as `orders`; sort by `orders`, largest first.

2. "What was completed revenue each month?"

    Translate: completed orders only, grouped by month (`DATE_TRUNC(order_date, MONTH) AS month`), `order_total` summed as `revenue`; sort by `month`, earliest first.

3. On the whole table, in one query: `COUNT(*)`, `COUNT(delivered_date)` and `COUNT(DISTINCT customer_id)`. Predict which is largest and which is smallest before you run. Then say which question each number answers.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 3 | completed 2,771; cancelled 212; pending 17 |
| 2 | 24 | 2024-09-01: 11,268.00 |
| 3 | 1 | 3,000 orders; 2,771 delivered; 462 customers |

## Hint

`COUNT(delivered_date)` skips the `NULL`s. Which orders have no delivery date?

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
