# D17 · Prepare store sales with Power Query

You will combine Nakheel's store files, clean the store list, and check which sales and stores do not match. Activities 01–07 build one report; labs 08–11 give you more practice afterwards.

If this is your first Power BI lesson, start with [D16 activity 10](../D16/10-Evr-PowerBI-End-To-End/README.md): open Power Query, clean one column and check a report against SQL. Then return here for the store files.

## Get the files

Download [nakheel_store_files.zip](../../../../shared/datasets/nakheel_stores/nakheel_store_files.zip) and extract it. This is a different download from D16's `nakheel_csv.zip`.

Inside the extracted `nakheel_store_files` folder, check for:

- `finance/store_sales_2024-25.csv` and `finance/store_sales_2025-26.csv` (892 and 1,009 orders).
- `store_files/` (twelve shop CSVs and `notes.txt`).
- `stores_raw.csv`, `online_orders_2026-08.json`, `till_export_raw.csv` and `store_targets_2025-26.csv`.

The finance files also have [individual download links in the data guide](../../../../shared/datasets/nakheel_stores/README.md). Keep the extracted files as supplied; the differences in their column names and store codes are part of the work.

## Work through the activities

| Activity | What you build | Start from |
|---|---|---|
| [01 · Append two years](01-Evr-Append-Two-Years/README.md) | `store_sales` | A blank Desktop report or a new browser semantic model |
| [02 · Combine a folder](02-Evr-Combine-A-Folder/README.md) | `store_files_sales` | The same file/model as 01 |
| [03 · Revenue by store and month](03-Stu-Revenue-By-Store-And-Month/README.md) | Two charts and a check of the pop-up stall | 02 |
| [04 · Reference, split and errors](04-Evr-Split-Reference-Errors/README.md) | `stores`, reading `stores_raw` | The same file/model as 01–02 |
| [05 · Finish the store list](05-Stu-Clean-The-Store-List/README.md) | Coordinates and short store names | 04 |
| [06 · Merge sales and stores](06-Evr-Merge-Sales-And-Stores/README.md) | `store_sales_by_store` | 01, 04 and 05 |
| [07 · Find unmatched rows](07-Stu-Sales-Without-A-Store/README.md) | Anti joins and an inner-join comparison | 06 |
| [08 · Parameters](08-Lab-Parameters/README.md) | A folder parameter and a status parameter | Desktop file from 01–07 |
| [09 · JSON to a table](09-Lab-JSON-To-Table/README.md) | `online_order_lines` | The JSON file; a new or existing report/model |
| [10 · Import errors](10-Lab-Import-Errors/README.md) | A corrected till export | The till CSV; a new or existing report/model |
| [11 · Optional targets against actuals](11-Lab-Unpivot-Targets/README.md) | Targets and actuals at store-month grain | The targets CSV, with 01's `store_sales` or the lab's `Resources/store_sales.csv`; a new or existing report/model |

**Desktop:** save the report as `D17-checkpoint.pbix` after activity 01 and save again after each activity. Keep the extracted data folder too: the report reads it when you refresh.

**For D18:** start a new file/model and follow the [D18 guide](../../../05-data-modeling-and-dax/labs/D18/README.md). You do not need to export any D17 queries. D18's optional shops lab supplies ready-to-load CSV copies of `store_sales` and `stores`.

**Browser:** use one semantic model, `D17-nakheel`, throughout activities 01–07. Save the connected report as `D17-checkpoint`. To change its queries, select **Open semantic model**, switch **Viewing** to **Editing**, then **Transform data**. Finish Power Query with **Save**, apply changes if prompted, return to the report tab and click **Refresh**. Opening a new report for each CSV makes separate models that cannot be appended or merged together. The folder connector needs a cloud folder or a gateway; activity 02 explains the cloud route. Lab 08's local-path exercise needs Desktop.

## Check rows and totals

Power Query's preview can show only part of a table. For profiling, select **View → Column quality / Column distribution / Column profile** (browser: **View → Data view**), then change **Column profiling based on top 1000 rows** to **entire data set**. A preview label such as `999+ rows` is not the full row count. To check a loaded table, use a **Card** with `order_id` and change its aggregation to **Count**; clear its filters when checking all rows.

The main completed-store-revenue check is **205,338.00**. Put `status` = **completed** in **Filters on this visual** for every revenue chart or card. A count of all orders and a total of completed revenue intentionally use different filters. A matching total checks the amount; the later merge and anti joins check which stores those orders belong to.

To show the whole value on the current Card visual: **Format visual → Visual → Callout → Apply settings to** the summed field → **Value → Display units → None**. Some versions group this under **Callout values**. Use the displayed field name to find the setting.
