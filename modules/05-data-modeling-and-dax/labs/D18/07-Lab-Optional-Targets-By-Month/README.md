# Lab 07 (optional, PL-300): finance's monthly targets in the model

In this optional lab, you will bring finance's monthly store targets into the model as a third fact table, give each target the first day of its month, and compare target with actual by month and by governorate without any Merge.

**When:** after class, after lab 05; exam practice for PL-300. Not submitted. · **Files:** your file from lab 05 · **Data:** [`store_targets_2025-26.csv`](../../../../../shared/datasets/nakheel_stores/store_targets_2025-26.csv) (on GitHub, **Download raw file**; also in D17's `nakheel_store_files.zip`); `stores`, `store_sales` (lab 05); `dates` (activity 02) · **Guide:** [the D18 page](../README.md)

**The question:** finance set a revenue target for each shop and month of 2025-26. Which shops and months met it?

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | One column per month: nothing can match a month name to a date | **Unpivot Other Columns** |
| 2 | `dates` has one row per day; a target belongs to a month | a `month_start` date |
| 3 | The targets reach nothing | two relationships |
| 4 | Target against actual by month | a matrix |
| 5 | Target against actual by governorate, and the day-level trap | the same matrix |

We follow **NK-AMM-01** in September 2025.

## Step 1 · Turn the months into rows

**Why this step:** the sheet has one row per shop and one column per month; the model needs one row per shop and month.

**Get data** → **Text/CSV** → `store_targets_2025-26.csv` → **Transform Data** (if the headers read `Column1` …, **Use First Row as Headers**). Select `store_code` → right-click → **Unpivot Other Columns**. Rename `Attribute` to `month` (type **Text**) and `Value` to `target` (**Whole Number**); rename the query `targets_long`.

**Check:** **132** rows (11 shops × 12 months).

**What just happened:** NK-AMM-01's twelve monthly targets are twelve rows.

## Step 2 · Give each target the first day of its month

**Why this step:** Microsoft's advice for a fact table at a higher grain: "store the first date of the time period" and relate it to the date table.

**Add Column** → **Custom Column**, name `month_start`, formula `Date.FromText([month] & "-01", [Format = "yyyy-MM-dd", Culture = "en-US"])`; type **Date**. **Close & Apply**.

**Check:** `2025-09` → **2025-09-01**.

**What just happened:** NK-AMM-01's September target now has a date that `dates` can match.

`[month] & "-01"` joins the month text and a day to make `2025-09-01`; `Date.FromText` converts that text into a Date value using the stated format. This is a matching key, not a claim that the whole target must be earned on 1 September. The row's grain remains one shop and one month. Repeating the full monthly target on every day would multiply it when summed.

## Step 3 · Relate the targets

**Why this step:** the targets are a fact table: `stores` and `dates` should filter them as they filter the sales.

Model view: `stores[store_code]` onto `targets_long[store_code]`; `dates[date]` onto `targets_long[month_start]`. Hide `store_code`, `month` and `month_start` in `targets_long` (as in lab 04).

**Check:** **two** new solid lines into `targets_long`.

**What just happened:** the targets and the sales now share two dimensions, with no Merge.

## Step 4 · Target against actual by month

**Why this step:** the question finance asks first.

A **Matrix**: rows `dates[year_month]`; values Sum of `targets_long[target]` and Sum of `store_sales[order_total]`; filters `dates[fiscal_year]` = 2025-26 and `store_sales[status]` = completed.

**Check:** total **110,000** against 107,595.00 (2025-09: 12,300 against 12,169.00).

**What just happened:** each month in the matrix selects all that month's rows in `dates`, which filters both fact tables. The September selection includes 1 September, so it finds the monthly targets, as well as the sales on every day in September.

Read the values as target first, actual second. September is 131.00 below target (12,300 − 12,169.00); the fiscal-year total is 2,405.00 below (110,000 − 107,595.00). We compare at the monthly grain or above, where both columns describe the same period.

## Step 5 · By governorate, and the day-level trap

**Why this step:** the same targets, grouped by the shop's governorate, and one grain too fine.

Change the rows to `stores[governorate]`: Amman 42,000 against 41,749.50; Karak 4,100 against 4,324.50, above target. Then change them to `dates[date]`: targets appear on twelve days only, the first of each month. A monthly target means nothing below the month: read it by month or above.

**Check:** Amman **42,000** against 41,749.50.

**What just happened:** NK-AMM-01's September target sits on 2025-09-01, filtered by the same `stores` and `dates` as its sales.

When you switch to a single day, sales describe that day's activity but the target is still a whole month's amount attached to its first day. A blank target on 2 September does not mean finance set a zero target for that day. To compare performance daily, we would need an agreed way to allocate the monthly target across days; this lab does not make that allocation.

## Check yourself

| Step | One value |
|---|---|
| 1 | 132 rows |
| 2 | 2025-09-01 |
| 3 | 2 new lines |
| 4 | 110,000 against 107,595.00 |
| 5 | Amman 42,000 |

## If something goes wrong

- **`month_start` is an error:** set `month` to **Text** before the custom column.
- **110,000 on every month:** the `dates`–`targets_long` relationship is missing, or it is on `month` instead of `month_start`.

## References

Nakheel's store files, course-made 28 October 2026 ([`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md)). Microsoft: [Understand star schema: facts at a higher grain](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema). Menu names are Power BI's in October 2026.
