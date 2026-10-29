# Lab 11 · Optional: targets against actuals with Unpivot and Group By

In this optional self-guided lab, you will turn a wide targets sheet (one column per month) into a long table with **Unpivot**, sum the actual sales per shop and month with **Group By**, and merge the two on two keys to see which shops met their targets.

**When:** after class, if you want more. Not submitted. · **Data:** `store_targets_2025-26.csv` from [`nakheel_store_files.zip`](../../../../../shared/datasets/nakheel_stores/README.md) and `store_sales` from today's activity 01 · **Start from:** today's Power BI file

## The story

Finance set a revenue target for every shop and month of 2025-26 and keeps it the way people like to read it: one row per shop, one column per month. A chart of target against actual needs it the other way: one row per shop and month. That turn is **Unpivot**. The actual side needs the sales summed to the same grain, which is **Group By**, the Power Query `GROUP BY`.

## What you will learn

- To unpivot month columns into rows, and say what one row is before and after.
- To group rows and sum a column, on two grouping columns.
- To merge on two key columns at once.

## Checkpoints

- **C1:** `targets_long`: 132 rows, columns `store_code`, `month`, `target`; the year's targets add up to 110,000.
- **C2:** `actuals_by_month`: completed 2025-26 sales grouped by `store_code` and `month`: 125 rows, 107,595.00 in all.
- **C3:** the two merged: 132 rows, 61 shop-months at or above target, 3 shops that met the year.

## Step 1 · Unpivot (C1)

1. **Get data** → **Text/CSV** → `store_targets_2025-26.csv` → **Transform Data**. 11 rows, 13 columns; one row is one shop.
2. Select `store_code`, right-click → **Unpivot Other Columns**.
3. Rename `Attribute` to `month` and `Value` to `target`. Check that `month` is **Text** (`2025-09`, the same text the month column of step 2 will hold). Rename the query `targets_long`.

**What you should see:** 132 rows (11 shops × 12 months); one row is one shop in one month.

## Step 2 · Group By (C2)

1. Right-click `store_sales` → **Reference**. Rename it `actuals_by_month`.
2. Filter `status` to completed, and `order_date` to **is after or equal to** 1 September 2025.
3. **Add Column** → **Custom Column**: **New column name** `month`, **Formula** `Date.ToText([order_date], "yyyy-MM")`.
4. **Home** → **Group By** → **Advanced**. Group by `store_code`, then **Add grouping** → `month`. **New column name** `actual`, **Operation** **Sum**, **Column** `order_total`. **OK**.

**What you should see:** 125 rows, not 132: seven shop-months had no completed sale. The pop-up stall is not here: it traded in March 2025, before this year.

## Step 3 · Merge on two keys (C3)

1. Select `targets_long` → **Merge Queries as New**. Top: click `store_code`, then Ctrl+click `month`. Bottom: `actuals_by_month`, click `store_code`, then Ctrl+click `month`, in the same order. **Left Outer**. **OK**. Rename the query `targets_vs_actuals`.
2. Expand `actual` only. Replace `null` in `actual` with `0` (the seven months without sales).
3. **Add Column** → **Conditional Column**: **New column name** `met_target`; **If** `actual` **is greater than or equal to**, then in the value box switch the small drop-down from **ABC** (a typed value) to **Select a column** and choose `target`; **Output** `yes`; **Else** `no`.
4. For the year: right-click `targets_vs_actuals` → **Reference**, then **Group By** `store_code` with two sums, `actual` and `target`.

**What you should see:** `targets_vs_actuals` has 132 rows; `met_target` is `yes` in 61. After step 4, 11 rows; over the year, actual 107,595.00 against target 110,000. Three shops beat their yearly target: NK-AMM-03, NK-IRB-01 and NK-KRK-01.

## Check yourself

| Checkpoint | One value to check |
|---|---|
| C1 | 132 rows · targets 110,000 |
| C2 | 125 rows · 107,595.00 |
| C3 | 61 `yes` · NK-KRK-01 met the year (4,324.50 against 4,100) |

## If something goes wrong

- **The merge matches almost nothing:** `month` is a date in one query and text in the other, or the two keys were clicked in a different order in the two tables.
- **Unpivot made 143 rows, and `Attribute` holds the word `store_code` on some rows:** you chose **Unpivot Columns** with every column selected. Delete the step and use **Unpivot Other Columns** with only `store_code` selected.

## Bonus

**More practice, not checked:** a clustered column chart of `target` and `actual` by `month` for one shop, with a slicer on `store_code`.

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Button and menu names are those of Power BI Desktop in October 2026. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Unpivot columns](https://learn.microsoft.com/en-us/power-query/unpivot-column), [Group by](https://learn.microsoft.com/en-us/power-query/group-by), [Merge queries overview](https://learn.microsoft.com/en-us/power-query/merge-queries-overview).
