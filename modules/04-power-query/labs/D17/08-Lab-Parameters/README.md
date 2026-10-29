# Lab 08 · Parameters: one place to change a path or a filter

In this self-guided lab, you will move the folder path out of your queries into a parameter, so the file still works when the data moves, and add a second parameter that chooses which order status a table counts.

**When:** after class, at your own pace. Not submitted. · **Data:** your `nakheel_store_files` folder · **Start from:** your Power BI file from today's activities 01 to 07

## The story

Your report reads `C:\Users\you\Documents\nakheel_store_files\...` in five places. Send the file to a colleague, or move the folder, and every query breaks. A **parameter** is a named value that queries read instead of a typed-in value: change it once and every query that uses it follows.

## What you will learn

- To create a parameter with **Manage Parameters** → **New Parameter**, and what its fields mean.
- To use a parameter inside a step, in the formula bar.
- To give a parameter a list of allowed values and use it in a filter.

## Before you start

Open your file from today in **Power BI Desktop**. You need `store_sales_2024-25`, `store_sales_2025-26`, `store_files_sales` and `stores_raw`.

**In the browser:** this lab is for Desktop. A path on your computer means nothing to the Power BI service, and Microsoft's page on parameters in the service says you can review and edit parameter settings there "but not create them". Read the steps, and do them on a Windows computer when you can.

## Checkpoints

- **C1:** a Text parameter `FilesFolder` that holds the path to your `nakheel_store_files` folder.
- **C2:** the four queries read `FilesFolder`; after you move the folder and change only the parameter, the completed store revenue is still 205,338.00.
- **C3:** a parameter `StatusToCount` with three allowed values, used in a filter; the card reads 205,338.00, 14,224.00 or 1,040.00.

## Step 1 · Create the parameter (C1)

1. **Home** → **Transform data**. **Home** → **Manage Parameters** → **New Parameter**.
2. **Name:** `FilesFolder`. **Description:** `Folder that holds the Nakheel store files, ending with \`. Tick **Required**. **Type:** **Text**. **Suggested Values:** **Any value**. **Current Value:** your path, for example `C:\Users\you\Documents\nakheel_store_files\`, with the backslash at the end. **OK**.

**What you should see:** `FilesFolder` in the **Queries** pane, with its value shown beside a parameter icon.

## Step 2 · Use it in the queries (C2)

1. Select `store_files_sales` and click its `Source` step. The formula bar shows `= Folder.Files("C:\...\nakheel_store_files\store_files")`.
2. Replace the text in quotes, quotes included, so the formula reads:

    ```powerquery
    = Folder.Files(FilesFolder & "store_files")
    ```

    `&` joins two pieces of text, like `CONCAT` in SQL.

3. Do the same in the `Source` step of `store_sales_2024-25`, `store_sales_2025-26` and `stores_raw`. Each one has `File.Contents("C:\...\something.csv")` inside `Csv.Document(...)`. Change only the path inside `File.Contents(...)`:

    ```powerquery
    File.Contents(FilesFolder & "finance\store_sales_2024-25.csv")
    File.Contents(FilesFolder & "finance\store_sales_2025-26.csv")
    File.Contents(FilesFolder & "stores_raw.csv")
    ```

4. The fifth place is easy to miss. Open the **Helper queries** group that **Combine Files** made in activity 02. One of its queries (usually named **Sample File**) has its own `Source` step with `Folder.Files("C:\...\store_files")`, so Power Query can read the example file. Change it the same way: `= Folder.Files(FilesFolder & "store_files")`. If you skip it, `store_files_sales` fails as soon as the folder moves.

5. **Close & Apply**. Then test it: close Power BI, rename the folder to `nakheel_store_files_2`, open the file, **Transform data** → **Manage Parameters**, change **Current Value** to the new path, **OK**, **Close & Apply**.

**What you should see:** no errors, and the completed store revenue card still reads 205,338.00. Rename the folder back afterwards (and the parameter too).

## Step 3 · A parameter with a list (C3)

1. **Manage Parameters** → **New**. **Name:** `StatusToCount`. **Type:** **Text**. **Suggested Values:** **List of values**; type `completed`, `cancelled`, `pending` on three lines. **Default Value** and **Current Value:** `completed`. **OK**.
2. Right-click `store_sales` → **Reference**. Rename it `store_sales_one_status`.
3. Filter its `status` column: **Text Filters** → **Equals**. In the value box, open the small drop-down on its left (it shows **ABC**) and choose **Parameter**, then `StatusToCount`. **OK**.
4. **Close & Apply**. Build a card with `order_total` (Sum) from `store_sales_one_status`, with no visual filter.
5. Change the parameter: **Transform data** → **Manage Parameters** → `StatusToCount` → **Current Value**, or **Home** → the drop-down under **Transform data** → **Edit parameters** if your version shows it. **Close & Apply** (or **Apply changes**) after each change.

**What you should see:** completed 205,338.00 · cancelled 14,224.00 · pending 1,040.00. The three add up to 220,602.00, the total without any filter.

## Check yourself

| Checkpoint | One value to check |
|---|---|
| C1 | `FilesFolder` ends with `\` |
| C2 | after the move: 205,338.00 |
| C3 | 205,338.00 · 14,224.00 · 1,040.00 |

## If something goes wrong

- **An error saying the path could not be found:** the backslash between the parameter and the rest is missing or doubled. `FilesFolder` ends with `\`; the text after `&` does not start with one.
- **An error saying the name `FilesFolder` was not recognized:** the spelling or capital letters differ. Power Query names are case-sensitive.
- **`store_files_sales` shows an error after the move, and the other queries do not:** the helper query's `Source` step still has the old path (step 2, item 4).
- **No Parameter option in the filter box:** the parameter's type is not **Text**. Edit it in **Manage Parameters**.

## Bonus

**More practice, not checked:** add a third parameter, `FromDate` (**Date**), and filter `store_sales_one_status` to orders on or after it. What is completed store revenue from 1 March 2026?

## References

Button and menu names are those of Power BI Desktop in October 2026. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Using parameters](https://learn.microsoft.com/en-us/power-query/power-query-query-parameters), [Edit parameter settings in the Power BI service](https://learn.microsoft.com/en-us/power-bi/connect-data/service-parameters).
