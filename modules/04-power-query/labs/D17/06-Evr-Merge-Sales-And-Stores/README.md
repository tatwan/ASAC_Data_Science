# Sales with their store: Merge

In this activity, you will attach the store list to the store sales with **Merge**, the Power Query version of a `LEFT JOIN`, find out why more than four hundred sales come back without a governorate, and fix it where the problem is.

**In class:** a demo, then you do it · **Data:** `store_sales` (activity 01) and `stores` (activities 04 and 05) · **Tool:** Power BI Desktop or the browser

## The story

The manager's question from the start of the day: how much did the shops sell in each governorate? The sales know the store code; only the store list knows the governorate. In SQL you joined two tables on a key on D06. In Power Query that is **Merge**: for each sale, find the store with the same `store_code` and bring its columns across.

## What you will learn

- To merge two queries on a key column, choose the join kind, and expand the columns you need.
- To read the match count Power Query shows before you commit to a merge.
- That Power Query compares text exactly, capital letters included, and how to fix a key in the query it comes from.

## Before you start

You need `store_sales` (1,901 rows, 5 columns) and `stores` (12 rows, cleaned) in the same file or semantic model. If you are missing one, do activity 01 or activities 04 and 05 first.

## Step 1 · Predict

`store_sales` has 1,901 rows, one per store order. `stores` has 12 rows, one per store. If every sale keeps its row and gains its store's columns, how many rows will the result have?

## Step 2 · Merge

1. Select `store_sales`. **Home** → **Combine** → **Merge Queries** → **Merge Queries as New**.
2. The top table is `store_sales`: click its `store_code` column. In the drop-down below choose `stores` and click its `store_code` column.
3. **Join Kind:** **Left Outer (all from first, matching from second)**.
4. Before you click **OK**, read the message at the bottom of the dialog: it counts how many rows of the first table found a match.

**What you should see:** about 1,497 of the 1,901 rows match. Four hundred sales would find no store. Click **OK** anyway, so you can see which ones.

## Step 3 · Expand, then look for the gaps

1. Rename the new query `store_sales_by_store`. It has 1,901 rows and a new column `stores` that says **Table** in every row: the matching rows of the store list.
2. Click the expand button in the `stores` header. Tick `governorate`, `area` and `short_name` (if you made it in activity 05) only, untick **Use original column name as prefix**, **OK**.
3. Open the filter on `governorate` and keep only `(null)`.

**What you should see:** 404 rows with no governorate, from three store codes: `NK-IRB-02` (345 rows), `NK-SLT-01` (40) and `NK-POP-01` (19). Clear the filter.

## Step 4 · Why NK-IRB-02 found nothing

Open `stores` and look at its `store_code` column. Irbid City Centre is typed `nk-irb-02` and Salt `nk-slt-01`. To a person they are the same codes. Power Query compares text exactly: Microsoft's words are that "comparisons between items that are identical but have different cases results in identifying the items as being different, not identical."

Fix it where the problem is:

1. In `stores`, select `store_code`. **Transform** → **Format** → **UPPERCASE**.
2. Go back to `store_sales_by_store` and filter `governorate` to `(null)` again.

**What you should see:** 19 rows, all `NK-POP-01`: the Ramadan stall, which really is not in the store list. You changed nothing in the merge. `store_sales_by_store` reads `stores` at every refresh, so the fix came through, the same as the rename in activity 01.

## Step 5 · Revenue by governorate

**Close & Apply**. Build a **Clustered bar chart** from `store_sales_by_store` (the model also holds `store_sales` and `stores`, so pick the fields from this table): `governorate` on the **Y-axis**, `order_total` (Sum) on the **X-axis**, filter `status` = completed.

**What you should see:** Amman 83,914.50, Irbid 62,116.50, Aqaba 20,774.50, Zarqa 16,134.50, Karak 8,495.50, Balqa 5,897.00, Madaba 3,908.00, Mafraq 3,239.50, and a bar labelled **(Blank)** with 858.00: the stall. Together, 205,338.00, the SQL answer. A left outer merge never loses a sale.

The same in SQL:

```sql
SELECT st.governorate, SUM(s.order_total) AS revenue
FROM store_sales AS s
LEFT JOIN stores AS st
  ON s.store_code = UPPER(st.store_code)
WHERE s.status = 'completed'
GROUP BY st.governorate
ORDER BY revenue DESC;
```

## Check yourself

| Step | One value to check |
|---|---|
| 2 | about 1,497 of 1,901 rows match |
| 3 | 1,901 rows; 404 with no governorate |
| 4 | 19 rows with no governorate, all `NK-POP-01` |
| 5 | Amman 83,914.50 · (Blank) 858.00 · total 205,338.00 |

## If something goes wrong

- **The merged query has more than 1,901 rows:** the store list has a store code twice, so some sales matched two rows. Check `stores` for duplicates (**Column distribution**: distinct should equal unique).
- **The expand made columns called `stores.governorate`:** you left **Use original column name as prefix** ticked. Rename them, or redo the expand.
- **Still 404 rows after UPPERCASE:** you changed the case in `store_sales_by_store` (the sales side, whose codes were already in capitals), not in the store list. Put the step in `stores` (or in `stores_raw`, which `stores` reads).

## Hint

The match count is the cheapest check in Power Query. Read it every time, before you click **OK**.

## Bonus

Open `store_sales_by_store` in **Home** → **Advanced Editor** and find `Table.NestedJoin`. Its arguments are the left table and key, the right table and key, the new column's name, and `JoinKind.LeftOuter`.

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Button and menu names are those of Power BI Desktop in October 2026. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Merge queries overview](https://learn.microsoft.com/en-us/power-query/merge-queries-overview), [Left outer join](https://learn.microsoft.com/en-us/power-query/merge-queries-left-outer), [Capitalization of text in Power Query M](https://learn.microsoft.com/en-us/powerquery-m/m-working-with-case).
