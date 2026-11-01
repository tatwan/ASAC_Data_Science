# Two years of store sales in one table: Append

In this activity, you will stack Nakheel's two yearly store-sales files into one table with **Append**, find out why half the revenue goes missing, fix it, and keep the two input queries out of the model with **Enable load**.

**In class:** a demo, then you do it · **Data:** `finance/store_sales_2024-25.csv` and `finance/store_sales_2025-26.csv` from [`nakheel_store_files.zip`](../../../../../shared/datasets/nakheel_stores/README.md) · **Tool:** Power BI Desktop (Windows) or Power BI in the browser

## The story

The finance team sends store sales once a year, one file per year. A manager wants one number: how much did the shops sell in the two years? In SQL you would put the two tables under each other with `UNION ALL`. In Power Query the same move is called **Append**. The answer is one you already know: completed store revenue was 205,338.00 dinars (D16, activity 10, step 6).

## What you will learn

- To append two queries into a new one, the Power Query version of `UNION ALL`.
- That Append matches columns **by name**, where `UNION ALL` in SQL matches them by position, and what happens when one name differs.
- To keep a helper query out of the model by unticking **Enable load**.

## Before you start

Download [`nakheel_store_files.zip`](../../../../../shared/datasets/nakheel_stores/nakheel_store_files.zip), move it to `Documents`, right-click it → **Extract All…**, keep the folder name Windows suggests (`nakheel_store_files`) → **Extract**. Opening the zip without extracting it shows the files, but Power BI cannot read them from there. With 7-Zip or WinRAR, choose **Extract to nakheel_store_files\**, not **Extract here**. Today's activities all use this folder. Open Power BI Desktop with a new, blank file.

The files are in the extracted folder's **finance** subfolder, not in D16's `nakheel_csv` folder. For example: `Documents\nakheel_store_files\finance\store_sales_2024-25.csv`. You can also open the [2024–25 CSV](../../../../../shared/datasets/nakheel_stores/finance/store_sales_2024-25.csv) and [2025–26 CSV](../../../../../shared/datasets/nakheel_stores/finance/store_sales_2025-26.csv) directly on GitHub and select **Download raw file**.

**In the browser:** start a new report from **+ New Report → Get data → Text/CSV → Upload file**. Upload the first finance CSV, sign in with **Organizational account** if asked, and click **Next** through the preview to Power Query, as in D16. Add the second CSV with **Home → Get data → Text/CSV → Upload file** inside the same Power Query editor. Do the append before leaving the editor. Select **Create a report**, choose **My workspace**, and name the semantic model `D17-nakheel`. Save the report as `D17-checkpoint`.

For every later query change: **Open semantic model → Editing → Transform data**. Add files through that model's **Get data**. Finish Power Query with **Save**, apply changes if prompted, return to the report tab and click **Refresh**. These navigation steps follow the D16 route; the new D17 transformations still need to work on your account. If a connector or command is unavailable, use Desktop or pair with someone using Desktop. See the [D17 guide](../README.md) for row-count checks and saving.

## Step 1 · Load both files into Power Query

1. **Home** → **Get data** → **Text/CSV** → `finance\store_sales_2024-25.csv` → **Transform Data**.
2. **Home** → **New Source** → **Text/CSV** → `finance\store_sales_2025-26.csv` → **Open**, then **OK** in the preview. Stay in Power Query; do not load a separate report.

**What you should see:** two queries on the left. `store_sales_2024-25` has 892 rows, `store_sales_2025-26` has 1,009. Look at the column headers of each. One row is one store order.

## Step 2 · Predict, then append

Before you click: the two files hold 892 and 1,009 orders. How many rows will the appended table have?

1. Select `store_sales_2024-25`.
2. **Home** → **Combine** → **Append queries** → **Append queries as new**.
3. **Two tables**. **First table:** `store_sales_2024-25`. **Second table:** `store_sales_2025-26`. **OK**.
4. Rename the new query (right-click → **Rename**) to `store_sales`.

**What you should see:** 1,901 rows, as predicted. But count the columns: six, not five. The last one, `amount`, is empty (`null`) in the first 892 rows; `order_total` is `null` in the last 1,009.

## Step 3 · Why the revenue looks wrong

**Desktop:** **Home → Close & Apply**. **Browser:** **Create a report** for the first load, or **Save** for later changes, then return to the report and **Refresh**. Build a **Card** from `store_sales` with `order_total` (Sum), then drag `status` from the same table to **Filters on this visual** and tick **completed** only. See the [D17 guide](../README.md) if the card abbreviates the number.

**What you should see:** **97,743.00**, not 205,338.00. The card adds up only the first year. The till system changed in September 2025 and the second file calls the column `amount`. Append puts columns with the same name under each other; a name that appears in only one file becomes a column of its own, empty for the other file's rows. The order of the columns did not matter: the second file has `order_date` before `store_code`, and they still landed in the right place, because they have the same names.

SQL works the other way round. `UNION ALL` matches columns by position, so in SQL the reordered file would have put dates under `store_code`, and a different name would not matter.

## Step 4 · Fix it at the source

1. **Home** → **Transform data**. Select `store_sales_2025-26`.
2. Right-click the `amount` header → **Rename** → `order_total`.
3. Select `store_sales`.

**What you should see:** five columns and no empty `order_total`. You did not touch `store_sales`: it reads the two queries every time, so the fix in one of them flows through. **Close & Apply** (browser: **Save**, then refresh the report): the card now reads **205,338.00**, the SQL answer.

## Step 5 · Keep the inputs out of the model

The model needs `store_sales`, not the two yearly pieces. Loading them as well would put the same orders in the model twice.

1. In Power Query, right-click `store_sales_2024-25` and untick **Enable load**. If Power BI warns that the data will be removed from the report, choose **Continue**.
2. Do the same for `store_sales_2025-26`.

**What you should see:** the two names turn italic in the **Queries** pane. After **Close & Apply**, the **Data** pane shows only `store_sales`. The two queries still run at every refresh; they just are not loaded as tables of their own.

**In the browser:** look for **Enable load** in the query's right-click menu. If your editor does not offer it, keep the two source queries and use fields from `store_sales` for the report. Save the query changes and refresh the report.

Save the Desktop file as `D17-checkpoint.pbix`, or save the browser report as `D17-checkpoint`. Keep using this file/model for the next activities.

## Check yourself

| Step | One value to check |
|---|---|
| 1 | 892 rows and 1,009 rows |
| 2 | 1,901 rows, 6 columns; `amount` is `null` in 892 rows |
| 3 | Card: 97,743.00 |
| 4 | 5 columns · Card: 205,338.00 |
| 5 | `store_sales` is the only table in the **Data** pane |

## If something goes wrong

- **The appended table has 892 or 1,009 rows:** check which query you selected and which inputs appear in its append step. **Append queries** changes the selected query; **Append queries as new** creates a separate one. Reopen the append step and select both different yearly queries. Do not use a partial preview as the full count; see the [D17 guide](../README.md).
- **The card shows 220,602.00:** the `status` filter is missing; that total includes cancelled and pending orders.
- **The card shows a number 100 times too big (20,533,800.00), or dates look wrong:** your Windows is set to read numbers with a decimal comma, so `30.00` became 3000. In each yearly query, delete the `Changed Type` step, then right-click `order_total` (and `amount`) → **Change Type** → **Using Locale…** → **Decimal Number**, **English (United States)**.
- **The rename does not reach `store_sales`:** check that you renamed `amount` in `store_sales_2025-26`, and that the new name is exactly `order_total`, with no space and in lower case.

## Hint

If the card shows `97.74K` or `205.34K`, it is the right number in a short format: use the [Card formatting steps](../README.md#check-rows-and-totals) to show it in full.

The SQL you would write for the fixed table:

```sql
SELECT order_id, store_code, order_date, status, order_total FROM sales_2024_25
UNION ALL
SELECT order_id, store_code, order_date, status, amount AS order_total FROM sales_2025_26;
```

The `AS order_total` is the rename in step 4.

## Bonus

Select `store_sales` and open **Home** → **Advanced Editor**. Find `Table.Combine`: the list in its brackets is the queries it stacks. **Append queries** with **Three or more tables** writes the same function with a longer list.

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Use the [D17 guide](../README.md) for saving, browser navigation and row-count checks. Button and menu names can vary between Desktop and the browser. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Append queries](https://learn.microsoft.com/en-us/power-query/append-queries), [Exclude queries from load and refresh](https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-include-in-report-refresh), [Upload a file in Power Query Online](https://learn.microsoft.com/en-us/power-query/upload-file).
