# Lab 07 (optional, PL-300): How to compare monthly targets with daily sales

Finance sets one revenue target per shop per month, but our sales are recorded by day. In this lab you load the targets as a third fact table, give each target a date the calendar can match, and compare target with actual by month and by governorate.

**When:** optional practice for PL-300, after Lab 05. Not submitted. · **Files:** your file from Lab 05 · **Data:** `store_targets_2025-26.csv`, already in the Nakheel store files you extracted in D17 (or download the [single file](../../../../../shared/datasets/nakheel_stores/store_targets_2025-26.csv) on GitHub with **Download raw file**); `stores`, `store_sales` (lab 05); `dates` (activity 02) · **Guide:** [the D18 page](../README.md)

**The question:** finance set a revenue target for each shop and month of 2025-26. Which months and governorates met their targets?

## Before you start

Open the **D18 file/model you used for [Lab 05](../05-Lab-Optional-Shops-In-The-Model/README.md)**. It must contain `store_sales` (1,901 rows), `stores` (12 rows) and `dates`, with active **Single** relationships from `stores` and `dates` to `store_sales`. If you skipped 05, follow its steps first. Lab 06 is not required; if you tried it, finish its restore-to-Single step before continuing.

The targets CSV is finance's original **wide** file: `store_code` plus twelve month columns, `2025-09` through `2026-08`. If you did D17 Lab 11, step 1 is the same unpivot you did there.

Use a new report page for the matrices and clear page/report filters. This avoids carrying Lab 04's March–June selection or a selected governorate from Lab 05 into the checks.

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | One column per month: nothing can match a month name to a date | **Unpivot Other Columns** |
| 2 | `dates` has one row per day; a target belongs to a month | a `month_start` date |
| 3 | A governorate or calendar month cannot yet filter the targets | two relationships |
| 4 | Target against actual by month | a matrix |
| 5 | Target against actual by governorate, and the day-level trap | the same matrix |

We follow **NK-AMM-01** in September 2025.

## Step 1 · Turn the months into rows

**Why this step:** the sheet has one row per shop and one column per month; the model needs one row per shop and month.

1. **Home** → **Get data** → **Text/CSV**, choose `store_targets_2025-26.csv`, then **Transform Data**. If the headers read `Column1` …, select **Use First Row as Headers**.
2. Right-click the `store_code` header → **Unpivot Other Columns**. The twelve month columns become two: `Attribute` holds the month and `Value` holds the target.
3. Rename `Attribute` to `month` (type **Text**) and `Value` to `target` (type **Whole Number**). Rename the query `targets_long`.

Keep `store_code` as **Text**. Its values match the cleaned codes in Lab 05's supplied `stores.csv`.

> **On the web:** open the existing **D18-nakheel** model → **Editing** → **Transform data** → **Get data** → **Text/CSV** → **Upload file**. Add the CSV to this model. After step 2, **Save**, apply changes if prompted, then return to the report and **Refresh**.

**Check:** **132** rows (11 shops × 12 months), shown at the bottom left of Power Query. `stores` has 12 shops, but Jerash opens in September 2026, after this year, so it has no targets.

**What just happened:** NK-AMM-01's twelve monthly targets are now twelve rows. Its September row reads `2025-09`, **1,400**.

## Step 2 · Give each target the first day of its month

**Why this step:** `dates` has one row per day, so a target needs a date before the calendar can filter it. We give each month its first day, as Microsoft recommends for facts stored by month.

1. Still in Power Query, with `targets_long` selected: **Add Column** → **Custom Column**. Name the column `month_start` and enter this formula:

   ```
   Date.FromText([month] & "-01", [Format = "yyyy-MM-dd", Culture = "en-US"])
   ```

2. Set the type of `month_start` to **Date**.
3. **Close & Apply**.

**Check:** rows with `month` `2025-09` show **2025-09-01** in `month_start`.

**What just happened:** NK-AMM-01's September target now has a date that `dates` can match.

`[month] & "-01"` joins the month text and a day to make `2025-09-01`; `Date.FromText` converts that text into a Date value using the stated format. This is a matching key, not a claim that the whole target must be earned on 1 September. The row's grain remains one shop and one month. Repeating the full monthly target on every day would multiply it when summed.

## Step 3 · Relate the targets

**Why this step:** the targets are a fact table: `stores` and `dates` should filter them as they filter the sales.

1. In **Model view**, drag `stores[store_code]` onto `targets_long[store_code]`, then `dates[date]` onto `targets_long[month_start]`.
2. Click each new line and read **Properties**: **Many to one** (or **One to many**, the same line read from the other end), active, **Cross-filter direction: Single**.
3. If Power BI drew a line between `targets_long` and `store_sales`, delete it. Two fact tables connect through the shared `stores` and `dates`, never directly. Keep the relationships into `store_sales` from Lab 05.

Hide `store_code`, `month` and `month_start` in `targets_long` (as in Lab 04). If you skipped 04, select them in Model view → **Properties** → **Is hidden**. They remain available to the relationships.

**Check:** **two** new solid lines into `targets_long`.

**What just happened:** the targets and the sales now share two dimensions, with no Merge.

## Step 4 · Target against actual by month

**Why this step:** finance's first question is whether each month met its target.

1. On the new report page, add a **Matrix** and put `dates[year_month]` in **Rows**. Take `year_month` from the shared `dates` table so it filters both facts.
2. In **Values**, add **Sum** of `targets_long[target]`, then **Sum** of `store_sales[order_total]`.
3. In **Filters on this visual**, set `dates[fiscal_year]` to **2025-26** and `store_sales[status]` to **completed**.

**Check:** total **110,000** against 107,595.00 (2025-09: 12,300 against 12,169.00).

**What just happened:** each month in the matrix selects all that month's rows in `dates`, which filters both fact tables. The September selection includes 1 September, so it finds the monthly targets, as well as the sales on every day in September.

Read the values as target first, actual second. September is 131.00 below target (12,300 − 12,169.00); the fiscal-year total is 2,405.00 below (110,000 − 107,595.00). We compare at the monthly grain or above, where both columns describe the same period.

## Step 5 · By governorate, and the day-level trap

**Why this step:** the same targets, grouped by the shop's governorate, and one grain too fine.

1. Keep both filters from step 4 and change the rows to `stores[governorate]`. **Check:** Amman **42,000** against 41,749.50; Karak 4,100 against 4,324.50, above target.
2. Change the rows to the plain `dates[date]` column, not its date hierarchy. Targets now appear on twelve days only, the first of each month.

**What just happened:** NK-AMM-01's September target sits on 2025-09-01, while its September sales are spread across the month's days. Both reach the matrix through the same `stores` and `dates`.

When you switch to a single day, sales describe that day's activity but the target is still a whole month's amount attached to its first day. A blank target on 2 September does not mean finance set a zero target for that day. To compare performance daily, we would need an agreed way to allocate the monthly target across days; this lab does not make that allocation.

3. Change the rows back to `dates[year_month]`. To follow our shop, add a **Slicer** on `stores[store_code]` and pick NK-AMM-01: September 2025 reads **1,400** against **1,522.00**, above target. Clear the slicer, then save the D18 file/report.

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
- **Actual is 205,338.00 instead of 107,595.00:** set this matrix's `dates[fiscal_year]` filter to **2025-26** and check that `dates` still relates to `store_sales[order_date]`.
- **A governorate shows the full target:** check the `stores`–`targets_long` relationship and use `stores[governorate]` for the rows.

## References

Nakheel's store files, course-made 28 October 2026 ([`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md)). Microsoft: [Understand star schema: facts at a higher grain](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema). Menu names are Power BI's in October 2026.
