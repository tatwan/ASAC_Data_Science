# Lab: A KPI set for Nakheel Retail

In this lab, you will define and calculate five KPIs for Nakheel's managers, then show how the answer to "is the typical order getting bigger?" changes with the grain you choose.

**Time:** about 45 minutes, after class · **Data:** `nakheel.orders` (activity 03) · **Starter:** `Unsolved/kpi_set.sql`

**Before you start:** the four `nakheel` tables are uploaded (3,000 rows in `orders`). If not, use the CSVs and steps in the [Nakheel upload activity](../03-Evr-Upload-Nakheel/README.md); `orders.csv` alone is enough for C1 to C3.

**What you hand in:** nothing. The lab is practice and is not graded; the solution is released after class. Save your `.sql` file with the definition table and every comment block filled in. It is one of the files you choose from for Assignment 1, which is issued on D09 (Sunday 11 October).

## How this lab is organised

There are five KPIs and three checkpoints. The KPIs, numbered 1 to 5, are **what** the manager wants. The checkpoints, **C1**, **C2** and **C3**, are the **steps** you work through to build them. Each step has a label such as C1a or C3b, and the same label appears in the starter file and in Check yourself. Each checkpoint ends with a check before you move on:

| Checkpoint | SQL skill | KPIs |
|---|---|---|
| C1 · Group correctly | `GROUP BY` | 1, 2, 3 |
| C2 · Count some rows, filter groups | `COUNTIF`, `HAVING` | 4, 5 |
| C3 · Change the grain | One KPI at three grains | 3 again |

## The five KPIs

Fill in the definition table at the top of the starter file before you write any query. For each KPI: the rule in words, and the grain (what one row of the result is).

| # | KPI | What the manager asked for |
|---|---|---|
| 1 | Completed revenue | Money from completed orders, each month |
| 2 | Completed orders | How many orders were completed, each month |
| 3 | Average order value | What a completed order is worth on average, store against online |
| 4 | Cancellation rate | The share of orders placed that were cancelled, each month |
| 5 | High-cancellation months | Which months had a cancellation rate above 9% |

## C1 · Group correctly

**C1a.** KPIs 1 and 2 in one query, one row per month: revenue rounded to 2 decimals, sorted by month.

**C1b.** KPI 3, one row per channel, rounded to 2 decimals, sorted by `channel`.

**Checkpoint C1:** 24 rows for KPIs 1–2 and 2 rows for KPI 3, matching the Check yourself table.

## C2 · A conditional aggregate and a filter on groups

**C2a.** KPI 4: for each month, show orders placed, cancelled orders and the cancellation rate. Count cancelled orders with `COUNTIF`. For the rate, divide cancelled orders by orders placed, rounded to 4 decimals with `ROUND(…, 4)`. Keep every order in the query: do not filter out the orders that were not cancelled. Sort by month.

**C2b.** KPI 5: show the month and the rate, only for the months where the rate is above 0.09, sorted by month.

**Checkpoint C2:** C2a returns 24 rows and C2b returns 6.

## C3 · Change the grain

The commercial manager asks: "Is the typical order getting bigger?"

**C3a.** Calculate average order value (completed orders) by **year**, rounded to 2 decimals and sorted by year. What would you tell the manager from this result alone? Then add a column to the same query that counts how many months of data each year has: `COUNT(DISTINCT DATE_TRUNC(order_date, MONTH))`. Are the three years built from the same number of months? Does that change your answer?

**C3b.** Calculate average order value (completed orders) by **month**, rounded to 2 decimals and sorted by month. Is there a steady trend?

**C3c.** Compare like with like: September 2024–August 2025 against September 2025–August 2026. Use a `CASE` on `order_date` to label each order with its period, then group by the label. Name the label column `period`, label the periods `'Sep 2024 - Aug 2025'` and `'Sep 2025 - Aug 2026'`, and sort by `period` so the earlier one comes first. Round the average to 2 decimals. You get both periods side by side in one result.

**C3d.** In your interpretation line, say which result answers the manager's question, and why the yearly one could mislead.

**Checkpoint C3:** C3a returns 3 rows, C3b 24 and C3c 2, and your interpretation names the grain you chose and gives the reason.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| C1a | 24 | August 2026: 13,061.50 from 129 orders |
| C1b | 2 | online 109.81; store 116.47 |
| C2a | 24 | January 2025: 12 of 116 cancelled, 0.1034 |
| C2b | 6 | March 2025 is the highest, 0.1111 |
| C3a | 3 | 2024: 116.08 from 4 months of data; 2025: 110.39 from 12; 2026: 117.98 from 8 |
| C3b | 24 | September 2024: 100.61 |
| C3c | 2 | 115.20, then 113.12 |

If a count differs, check the status and date range before changing the aggregate.

## Hint

For C2, a `WHERE status = 'cancelled'` would remove the orders you need to divide by. For C3c, `CASE WHEN order_date < '2025-09-01' THEN … ELSE … END` gives each order a period label. A `WHERE` on the dates would also work, but it keeps one period per query, so you would need two queries and compare them by eye.

## Stretch card

Not required, not checked. In `bigquery-public-data.thelook_ecommerce.orders`, count the orders of each status, largest first. Write down the bytes estimate before you run it. The answer changes as the public dataset is updated, so there is no fixed value to check.

## More practice

**Not checked and not submitted.** Solutions are in the Solved file. Nothing on D06 assumes you did these.

- M1 "Which ten products sold the most units?" (`order_items`, all statuses; sort by units, largest first, then by `product_id`; `LIMIT 10`)
- M2 "How many completed orders were delivered on the day they were placed?"
- M3 "How much did we collect in shipping fees each year, on completed orders?" (rounded to 2 decimals, sorted by year)
- M4 "How many new customer accounts did we open each year?" (year of `signup_date`, sorted by year)
- O1 Back to life expectancy (`owid.life_expectancy_data`): each country's lowest and highest value since 1950, sorted by `entity`. Keep countries and territories only, as in the D03 lab. If your D03 table is still called `life_expectancy`, `MIN(life_expectancy)` fails with `MIN is not defined for arguments of type STRUCT`: upload it again as `life_expectancy_data` (D03 lab, step 3).
- O2 The average life expectancy of all countries in 2023 (rounded to 2 decimals, with the number of countries), and the `World` row for 2023. Why are they different?

## Check yourself: more practice

| Question | Rows returned | One value to check |
|---|---:|---|
| M1 | 10 | P-040 first, 656 units |
| M2 | 1 | 1,763 of 2,771 |
| M3 | 3 | 2025: 502.50 |
| M4 | 4 | 2024: 292 new accounts |
| O1 | 237 | Afghanistan: 28.1563 to 66.0346 |
| O2 | 1 | 74.15 across 237 countries |
| O2b | 1 | World 73.1694 |

## If something goes wrong

| Problem | Fix |
|---|---|
| `SELECT list expression references column … which is neither grouped nor aggregated` | Every column in `SELECT` must be in `GROUP BY` or inside `SUM`, `COUNT`, `AVG` … |
| `Aggregate function AVG not allowed in WHERE clause` | A filter on a calculated group value goes in `HAVING` |
| An amount shows a long tail of decimals | Amounts are stored as `FLOAT`. Round money results: `ROUND(AVG(order_total), 2)` |
| Your month column shows the whole date | That is what `DATE_TRUNC` returns: the first day of the month. It still groups correctly |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026 ([dataset README](../03-Evr-Upload-Nakheel/Resources/README.md)). Life expectancy, Our World in Data, CC BY 4.0, course copy of 24 September 2026 ([dataset README](../../D03/08-Lab-Life-Expectancy/Resources/README.md)).
