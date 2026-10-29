# Lab 10 · A file as the till prints it: import errors

In this self-guided lab, you will load a shop's raw till export, get past the title lines, find the values that will not become numbers, and choose a fix for each that keeps the revenue right.

**When:** after class, at your own pace. Not submitted. · **Data:** `till_export_raw.csv` from [`nakheel_store_files.zip`](../../../../../shared/datasets/nakheel_stores/README.md) · **Start from:** a new Power BI file, or today's

## The story

Aqaba's till prints its August 2026 file with a title, a blank line, two voided receipts and one amount typed with its currency. Head office's figure for Aqaba's completed August sales is 2,032.50 dinars. The fastest-looking fix, **Remove Errors**, gives a different number. Your job is to get 2,032.50, and to know why.

## What you will learn

- To remove title rows and promote the real header row yourself.
- To find error cells with **Keep Errors** and read why each failed.
- To choose between fixing a value, filtering a row out and **Remove Errors**, by what each does to the total.

## Before you start

Open `till_export_raw.csv` in Notepad: three lines before the header, then the orders, and an empty line of commas at the end.

**In the browser:** **Get data** → **Text/CSV** in your semantic model's Power Query, uploading the file, if your account allows it (activity 01, "Before you start"). The steps are the same.

## Checkpoints

- **C1:** a table with the real headers `order_id`, `order_date`, `status`, `order_total` and 12 rows.
- **C2:** the three error cells found and each explained.
- **C3:** completed revenue 2,032.50 from 7 orders, with no row removed by **Remove Errors**.

## Step 1 · Start from the file as it is (C1)

1. **Get data** → **Text/CSV** → `till_export_raw.csv` → **Transform Data**.
2. In **Applied steps**, delete the steps after `Source` (click the **X** beside `Promoted Headers` and `Changed Type`, if they are there). Power BI guessed the header from the first line, which is the title.

**What you should see:** 17 rows. Row 1 says `Nakheel till export`; the real header is row 4.

## Step 2 · Title rows off, header on (C1)

1. **Home** → **Remove Rows** → **Remove Top Rows** → **Number of rows:** `3` → **OK**.
2. **Home** → **Use First Row as Headers**.
3. **Home** → **Remove Rows** → **Remove Blank Rows**.

**What you should see:** 12 rows and the four real column names. Power BI may add a `Changed Type` step on its own after step 2; delete it, you will set the types yourself.

## Step 3 · Set the types, and find the errors (C2)

1. Set `order_id` to **Whole Number**, `order_date` to **Date**, `order_total` to **Decimal Number**.
2. **View** → **Column quality**. `order_id` and `order_total` show errors.
3. **Home** → **Keep Rows** → **Keep Errors**.

**What you should see:** 3 rows. Two are `VOID` receipts: `order_id` is not a number and `order_total` is `-`. One is a real order, 102869, whose `order_total` was typed `93.50 JOD`. Click beside each Error to read it. Then delete the **Kept Errors** step.

## Step 4 · Try the quick fix, and check it (C3)

1. **Home** → **Remove Rows** → **Remove Errors**, with all columns selected.
2. Filter `status` to completed and read the total (select `order_total`, **Transform** → **Statistics** → **Sum**, then delete that step).

**What you should see:** 6 completed orders, **1,939.00**. Order 102869's 93.50 was a sale, and **Remove Errors** threw it away. Delete the **Removed Errors** step and the filter.

## Step 5 · Fix each error for its reason (C3)

1. The voided receipts are not orders: filter `status` to remove `voided`. Their errors go with them.
2. The typed currency is a real amount: move to the step before the type change of `order_total` (click it in **Applied steps**), then right-click `order_total` → **Replace Values** → **Value To Find:** ` JOD` (with the space) → **Replace With:** empty → **Insert** when Power Query asks. Click the last step again.
3. Filter `status` to completed. Close & Apply, and make a card with `order_total` (Sum).

**What you should see:** no errors, 7 completed orders, **2,032.50**: Aqaba's August in `store_sales` from today's activity 01.

## Check yourself

| Checkpoint | One value to check |
|---|---|
| C1 | 12 rows after Remove Blank Rows |
| C2 | 3 rows with errors: 2 `VOID`, 1 `93.50 JOD` |
| C3 | 7 completed orders · 2,032.50 (not 1,939.00) |

## If something goes wrong

- **Your headers are `Column1` to `Column4`:** **Use First Row as Headers** is missing, or you removed 4 rows instead of 3.
- **The `Replace Values` step did nothing:** it sits after the type change, where the cell is already an error. It must come before.

## Bonus

**More practice, not checked:** instead of Replace Values, try **Add Column** → **Column From Examples** on `order_total`: type `93.50` beside `93.50 JOD`. Compare the formula with your fix.

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Button and menu names are those of Power BI Desktop in October 2026. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Dealing with errors](https://learn.microsoft.com/en-us/power-query/dealing-with-errors), [Filter a table by row position](https://learn.microsoft.com/en-us/power-query/filter-row-position), [Promote or demote column headers](https://learn.microsoft.com/en-us/power-query/table-promote-demote-headers).
