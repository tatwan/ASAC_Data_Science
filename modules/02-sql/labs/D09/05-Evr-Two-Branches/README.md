# Two branches, one answer

In this activity, you will answer "Which categories grew most from our first year to our second?" with two CTEs that do not need each other, one per year, joined at the end.

**Time:** 15 minutes · **Data:** `nakheel.order_items`, `nakheel.orders`, `nakheel.products` (D04 activity 03) · **Starter:** `Unsolved/two_branches.sql`

So far each CTE has read the one before it (a chain), or one CTE has been read twice. Here the two steps are **branches**: `year_one` and `year_two` each start from the raw tables, and only the final `SELECT` brings them together.

Our data runs from September 2024 to August 2026, so the two years are:

| Year | From | To |
|---|---|---|
| Year 1 | 1 September 2024 | 31 August 2025 |
| Year 2 | 1 September 2025 | 31 August 2026 |

## Instructions

1. **Branch 1 alone: completed revenue per category in year 1.** Before you run it, say what one row is and predict the row count.

    Translate: the D06 three-table join (`order_items`, `orders`, `products`), completed orders with `order_date` between the two year 1 dates, `SUM(i.qty * i.price) AS revenue`, `GROUP BY p.category`. Write it inside `WITH year_one AS ( ... )`, then `SELECT * FROM year_one`, largest revenue first (`ORDER BY revenue DESC`).

    You should see 6 rows. Outerwear is first with 36,318.00.

    Then change only the last `SELECT` to `SELECT SUM(revenue) AS total FROM year_one`. You should see 142,273.50.

2. **Branch 2: the same step for year 2.** Copy the whole CTE, rename it `year_two`, and change only the two dates. Check it the same way.

    You should see 6 rows, Outerwear first with 40,319.00, and a total of 173,750.00. The two totals add up to 316,023.50, every completed sale we have: no order fell between the years, and none was counted twice.

3. **The answer: "Which categories grew most from year 1 to year 2?"** Put both CTEs in one `WITH`, with a comma between them and none after the last. Join them on category and work out the growth.

    Translate: `FROM year_one AS y1 INNER JOIN year_two AS y2 ON y1.category = y2.category`. Show the category, both revenues rounded to 2 decimals, and `ROUND(100 * (y2.revenue - y1.revenue) / y1.revenue, 1) AS growth_pct`, highest growth first (`ORDER BY growth_pct DESC`).

    You should see 6 rows. Shoes grew most, 37.3%.

4. Say the finding in one sentence a manager can use. For example: "Every category grew. Shoes grew fastest, by more than a third; Outerwear is still our biggest category but grew least, 11%."

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 6 | Outerwear first, 36,318.00 |
| 1, total | 1 | 142,273.50 |
| 2 | 6 | Outerwear first, 40,319.00 |
| 2, total | 1 | 173,750.00 |
| 3 | 6 | Shoes 37.3 first · Outerwear 11.0 last |

If Shoes shows 27.2, you divided by year 2's revenue. Growth is always measured against the earlier year.

## Hint

Each branch is a complete query of its own. Write `year_one`, check it, and only then copy it. If the join returns 0 rows, run each branch alone: one of them probably has the wrong dates.

## Bonus

Percent is not the whole story. Show the category, `ROUND(y2.revenue - y1.revenue, 2) AS growth_money` and `growth_pct`, and sort by `growth_money`, largest first (`ORDER BY growth_money DESC`). Which category added the most money, and where does Outerwear land now?

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
