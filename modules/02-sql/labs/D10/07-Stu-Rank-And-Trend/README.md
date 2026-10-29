# Window practice: rank and trend

In this activity, you will answer three manager questions with `ROW_NUMBER`, `RANK`, `LAG` and `QUALIFY`.

**Time:** 18 minutes · **Data:** `nakheel.orders` (D04 activity 03) · **Starter:** `Unsolved/rank_and_trend.sql`

Before every query: what is one row, what is the window, and in what order does the window count?

## Instructions

1. **"What are the three biggest completed orders in each channel?"** One row per order: channel, order ID, total, and its place in its channel. Sort by channel, then place.

    Translate: `channel`, `order_id`, `order_total`, `ROW_NUMBER() OVER (PARTITION BY channel ORDER BY order_total DESC) AS place`, then `QUALIFY` to keep places 1 to 3; `ORDER BY channel, place`.

2. **"Month by month, how much did each channel's revenue change on the month before?"** One row per channel and month: completed revenue and the change on that channel's previous month. Then find the biggest one-month jump: sort by the change, biggest first.

    Translate: a CTE `channel_month` with one row per channel and month (`GROUP BY channel, month`); then `channel`, `month`, `revenue` and `revenue - LAG(revenue) OVER (PARTITION BY channel ORDER BY month) AS change`; `ORDER BY change DESC`. Without `PARTITION BY channel`, the first online month would be compared with the last store month.

3. **"Which were our three best months?"** One row per month for the top three by completed revenue, with the rank. Sort by rank.

    Translate: the `monthly` CTE; `month`, `revenue`, `RANK() OVER (ORDER BY revenue DESC) AS month_rank`; `QUALIFY month_rank <= 3`; `ORDER BY month_rank`.

## Check yourself

| Question | Rows returned | One value to check |
|---|---:|---|
| 1 | 6 | online first: order 102631, 1,906.00 · store first: order 100849, 1,964.50 |
| 2 | 48 | biggest jump: store, September 2025, +5,399.00 |
| 3 | 3 | April 2026 20,237.00 · September 2025 17,472.00 · June 2026 17,321.50 |

## Hint

For the biggest jump in question 2, sort the result by the change, largest first. The first month of each channel has a `NULL` change; BigQuery puts `NULL` last when you sort `DESC`.

## Bonus

Add a running total for each channel to question 2: `SUM(revenue) OVER (PARTITION BY channel ORDER BY month) AS running_total`, sorted by channel, then month (`ORDER BY channel, month`). The last online month should read 110,685.50 and the last store month 205,338.00. Together they make 316,023.50.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
