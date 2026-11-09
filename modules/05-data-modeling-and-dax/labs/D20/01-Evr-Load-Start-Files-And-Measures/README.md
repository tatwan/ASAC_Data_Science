# Activity 01 · Build the fresh model

You will start a new model and check that it can reproduce Nakheel’s completed revenue. [Download all five start files](../README.md#download-the-start-files).

| Step | What you need to do | Tool |
|---|---|---|
| 1 | Bring in clean sales and lookup tables | Text/CSV |
| 2 | Make filters reach the sales lines | Model view |
| 3 | Give the report a calendar | Mark as date table |
| 4 | Add reusable totals | New measure |

## 1. Load the four CSVs

**Why this step.** Each row of `sales_lines` describes one line on an order. The other files supply the customer, product and date details.

In Desktop, use **Get data → Text/CSV → Load** for each file. Confirm that `date`, `order_date` and `delivered_date` are Date columns, `qty` is a whole number, and `price` and `line_value` are numeric. Keep IDs the same type on both sides of a relationship. Use Text for `year_month` and whole numbers for `year` and `month_no`. The unmatched C-0999 and blank delivery dates are part of the supplied data.

**On the web.** In your workspace, open **Create → Get data** and choose **Text/CSV**. Add the remaining CSVs in the same Power Query session and create the semantic model. Open it in **Editing** mode. This route depends on account permissions and enabled connectors. If the model editor is unavailable, use the worked view in the PDF and continue when you have model-edit access.

**Check.** The counts are 7,516 sales lines, 500 customers, 60 products and 1,096 dates. Order 100003 appears on three sales lines.

## 2. Draw the four relationships

**Why this step.** Selecting a month or a product category should narrow the same sales lines before a measure adds them.

In Model view, check or create these one-to-many paths, with single-direction filtering from each dimension into `sales_lines`.

- `customers[customer_id]` to `sales_lines[customer_id]`
- `products[product_id]` to `sales_lines[product_id]`
- `dates[date]` to `sales_lines[order_date]`, active
- `dates[date]` to `sales_lines[delivered_date]`, inactive

**Check.** Three solid paths and one dashed date path. The three lines of order 100003 are reached by the active order date 3 September 2024.

## 3. Mark and sort the calendar

**Why this step.** Time measures use one continuous date column. Month names alone sort alphabetically.

Mark `dates` as the date table with `dates[date]`. In Desktop, use **Column tools → Sort by column** to sort `dates[month]` by `dates[month_no]`. In the web model editor, look for **Mark as date table** on the table’s context menu. Use `dates[year_month]` sorted ascending for visuals that span years.

**Check.** January appears before February in a visual sorted by the month name. Use month as a category for the sort check. The row `2024-09` groups dates from September 2024 only.

## 4. Add the four measures

**Why this step.** A model measure can be reused on a card, in a table or inside another calculation.

Paste the [measure definitions](../Resources/start/d19_measures.txt) one at a time using **New measure**. Put Completed Revenue on a card. Add Orders and Average Order Value and set the report to completed status to read the matching order population. In Desktop, save the PBIX. On the web, model edits autosave. Create a report from that model and save the report separately.

**Check yourself.** Completed Revenue is 316,023.50. Under completed status, Orders is 2,771 and Average Order Value is 114.05. If the order count is 3,000, look for the status filter. The order 100003 lines now contribute 47.00 to Completed Revenue.

[Microsoft date tables](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-date-tables) · [Activity 02](../02-Evr-Time-Intelligence/README.md)
