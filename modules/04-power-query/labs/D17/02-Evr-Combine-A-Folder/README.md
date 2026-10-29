# Twelve shop files at once: a folder of files

In this activity, you will load a whole folder of shop files as one table, keep only the files that are data, and turn each file's name into a `store_code` column.

**In class:** a demo, then you do it · **Data:** the `store_files` folder from [`nakheel_store_files.zip`](../../../../../shared/datasets/nakheel_stores/README.md) · **Tool:** Power BI Desktop (Windows) or Power BI in the browser

## The story

The shops also send their own files: one file per shop, named after its store code, with every order the shop took. There are twelve of them now and there will be more. Appending twelve queries by hand would work today and break the day a thirteenth shop opens. The **Folder** connector reads every file in a folder and stacks them, and it reads the folder again at every refresh.

## What you will learn

- To connect to a folder and look at the list of files before combining them.
- To combine files that have the same columns into one table, and what the helper queries Power BI adds are for.
- To use the file name, in `Source.Name`, as data.

## Before you start

You need the unzipped `nakheel_store_files` folder from activity 01. Open the `store_files` folder in File Explorer and look: twelve `.csv` files and a `notes.txt`. Open one CSV file in Notepad: the columns are `order_id`, `order_date`, `status`, `order_total`. There is no store column; the file name is the store.

**In the browser:** Power Query Online can reach a folder on your computer only through an on-premises data gateway, a Windows program installed by IT (Microsoft's Folder connector page). Use your university OneDrive instead: upload the `store_files` folder to OneDrive, then in your semantic model's Power Query choose **Get data** → **SharePoint folder**, and give the address of your OneDrive, the part of its web address that ends in your name after `/personal/` (for example `https://youruniversity-my.sharepoint.com/personal/your_name_youruniversity_edu`). Sign in with **Organizational account**. You will see every file in your OneDrive: filter `Folder Path` to the rows that contain `store_files`, then carry on from step 2. The browser's button is called **Combine**, not **Combine & Transform Data**.

## Step 1 · Connect to the folder

1. **Home** → **Get data** → **More…** → **Folder** → **Connect**.
2. **Browse** to `nakheel_store_files\store_files` → **OK**.
3. Power BI lists the files. Click **Transform Data**, not **Combine**: first look at what is in the folder.

**What you should see:** a table with one row per file: 13 rows, with columns such as `Content`, `Name`, `Extension`, `Date modified` and `Folder Path`. One row is one file, not one order.

## Step 2 · Keep only the data files

Microsoft's rule for combining is that the files must "all have the same structure and the same extension". `notes.txt` is a note, not sales.

1. Open the filter arrow on `Extension`, untick `.txt`, keep `.csv`. **OK**.

**What you should see:** 12 rows, one per shop file.

## Step 3 · Combine

1. In the `Content` column header, click the **Combine Files** button (two arrows pointing down).
2. The **Combine Files** dialog shows the first file as the example. Check the preview, then **OK**.
3. Rename the query to `store_files_sales`.

**What you should see:** one table, 1,901 rows: the same 1,901 store orders as activity 01, now read from twelve files. The first column, `Source.Name`, holds the file each row came from. On the left, Power BI added a group called **Helper queries**, including **Transform Sample file**. Power BI applies the steps of that sample query to every file; change the sample, and every file is read the new way.

## Step 4 · Turn the file name into a store code

1. Select `Source.Name`. **Transform** → **Replace Values**. **Value To Find:** `.csv`. **Replace With:** leave empty. **OK**.
2. Rename `Source.Name` to `store_code`.

**What you should see:** `store_code` holds `NK-AMM-01`, `NK-IRB-02` and so on: 12 distinct values. Filter it to `NK-AMM-01`: 251 rows.

## Step 5 · Same number, third route

**Close & Apply**. Make a **Card**: `order_total` (Sum) from `store_files_sales`, filtered to `status` = completed.

**What you should see:** **205,338.00**, the same as `store_sales` in activity 01 and the SQL answer. Two ways in, one number.

`store_files_sales` and `store_sales` now hold the same 1,901 orders. Keep both loaded today, because activity 03 asks questions of this one and you will compare the two routes; in a report you hand to a manager you would load only one of them.

## Check yourself

| Step | One value to check |
|---|---|
| 1 | 13 files |
| 2 | 12 files |
| 3 | 1,901 rows; `Source.Name` has 12 distinct values |
| 4 | `NK-AMM-01`: 251 rows |
| 5 | Card: 205,338.00 |

## If something goes wrong

- **You clicked Combine & Transform Data in step 1 and `notes.txt` was included:** delete the steps after `Source` in **Applied steps** (or start again with **Transform Data**), filter `Extension`, then combine.
- **You see 19 files, not 13:** you pointed at `nakheel_store_files` instead of its `store_files` folder. The Folder connector reads subfolders too.
- **The card shows a number in thousands, such as 205.34K:** **Format visual** → **Callout value** → **Display units** → **None**.

## Hint

The SQL equivalent is a `UNION ALL` of twelve `SELECT`s, each with the store code typed by hand: `SELECT 'NK-AMM-01' AS store_code, * FROM amm_01 UNION ALL …`. The folder does that for you, and `Source.Name` is the typed store code.

## Bonus

Move `NK-MFQ-01.csv` out of the folder to your desktop and click **Home** → **Refresh** in Power BI. Count the rows of `store_files_sales` (the status bar of Power Query, or a card with Count of `order_id`), then move the file back and refresh again. A new shop's file is picked up the same way.

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Button and menu names are those of Power BI Desktop in October 2026. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Folder connector](https://learn.microsoft.com/en-us/power-query/connectors/folder), [Combine CSV files](https://learn.microsoft.com/en-us/power-query/combine-files-csv), [Combine files overview](https://learn.microsoft.com/en-us/power-query/combine-files-overview), [SharePoint folder connector](https://learn.microsoft.com/en-us/power-query/connectors/sharepoint-folder).
