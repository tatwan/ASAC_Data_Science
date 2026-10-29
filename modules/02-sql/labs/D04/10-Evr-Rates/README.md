# Conditional counts and rates

In this activity, you will count the cancelled orders without filtering the others away, then turn that count into a rate.

**Time:** 10 minutes · **Data:** `nakheel.orders` (activity 03) · **Starter:** `Unsolved/rates.sql`

## Instructions

1. In one row: all orders, and the cancelled ones. Use `COUNTIF(status = 'cancelled')`.

2. The cancellation rate as the average of a 0/1 column: `AVG(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)`, wrapped in `ROUND(…, 4)`. Why does the average of zeros and ones give a share?

3. The same counts and rate for each channel: orders, cancelled orders and the cancellation rate (rounded to 4 decimals); sort by `channel`. Which channel cancels more?

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 3,000 orders, 212 cancelled |
| 2 | 1 | 0.0707, about 7% |
| 3 | 2 | online 0.0764; store 0.0673 |

## Hint

A `WHERE status = 'cancelled'` would remove the other orders, and you need them as the denominator. `COUNTIF` counts some rows while keeping all of them.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
