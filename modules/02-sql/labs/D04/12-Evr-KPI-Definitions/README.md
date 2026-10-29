# Define a KPI before you calculate it

In this activity, you will write three KPIs as a definition table (name, rule in words, grain) and then as one query.

**Time:** 15 minutes · **Data:** `nakheel.orders` (activity 03) · **Starter:** `Unsolved/kpi_definitions.sql`

A KPI (key performance indicator) is a number a business agrees to track the same way every time. Two analysts who calculate "revenue" differently will report different numbers to the same manager. Writing the rule down first stops that.

## Instructions

1. Fill in the definition table in the starter file for three KPIs: completed revenue, completed orders, and average order value. For each, write the rule in words and the grain: what one row of the result is.

2. The three KPIs share a grain, one month. Write one query that returns all three, one row per month, sorted by month.

3. Compare August 2025 with August 2026. How did each of the three KPIs change, and by how much?

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 2 | 24 | 2024-09-01: 11,268.00 from 112 orders; average 100.61 |
| 3 | two rows of step 2 | August 2025: 13,075.50, 126 orders, 103.77. August 2026: 13,061.50, 129 orders, 101.25 |

## Hint

Average order value is completed revenue divided by completed orders: `SUM(order_total) / COUNT(*)`, with the same `WHERE`, rounded to 2 decimals with `ROUND(…, 2)`. `AVG(order_total)` gives the same number here.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../03-Evr-Upload-Nakheel/Resources/README.md).
