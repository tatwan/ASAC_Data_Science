# BETWEEN on a timestamp

In this activity, you will count August 2026 orders twice with the same `BETWEEN`, once on the date and once on the timestamp, get two different answers, and learn the safe pattern for a timestamp.

**Time:** 5 minutes · **Data:** `nakheel.orders` (activity 03) · **File:** `Solved/between_timestamp.sql`

## Instructions

1. Open `Solved/between_timestamp.sql`. `order_date` is a `DATE`; `order_ts` is a `TIMESTAMP`, a date and a time. Run query 1: `order_date BETWEEN '2026-08-01' AND '2026-08-31'` gives 158 orders.

2. Run query 2, the same words on the timestamp: 153. On a timestamp, `'2026-08-31'` means midnight at the start of 31 August, so the orders placed later that day are dropped, with no warning.

3. Run query 3 to see the five orders it dropped, sorted by `order_ts`.

4. Run query 4, the safe pattern for a timestamp: from the first moment, up to but not including the next period. `order_ts >= '2026-08-01' AND order_ts < '2026-09-01'` gives 158 again.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 158 |
| 2 | 1 | 153 |
| 3 | 5 | order 102999 first, 31 August at 10:27 |
| 4 | 1 | 158 |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
