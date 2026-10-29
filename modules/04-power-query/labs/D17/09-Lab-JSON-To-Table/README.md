# Lab 09 · JSON to a table: the website's orders

In this self-guided lab, you will turn a month of website orders, sent as JSON, into a table of order lines, and find out how expanding a list changes what one row means.

**When:** after class, at your own pace. Not submitted. · **Data:** `online_orders_2026-08.json` from [`nakheel_store_files.zip`](../../../../../shared/datasets/nakheel_stores/README.md) · **Start from:** a new Power BI file, or today's

## The story

The website does not send a CSV. It sends JSON: each order is a record, with a record inside it for the customer and a list inside it for the items bought. A list of records is how most web systems and APIs hand over data. Power Query can flatten it, but every expand changes the grain of the table, and a sum that was right before an expand can be wrong after it.

## What you will learn

- To read JSON in Power Query: a **Record** holds named fields, a **List** holds values in order.
- To expand a record column into columns, and a list column into rows.
- To check "one row is one ___" after every expand, and why `shipping_fee` must not be summed on item rows.

## Before you start

Open `online_orders_2026-08.json` in Notepad and read the first order. It has `order_id`, `order_date`, `status`, a `customer` with `customer_id` and `city`, a `shipping_fee`, and `items`, a list of the products bought (one to six per order).

**In the browser:** in your semantic model's Power Query, **Get data** → **JSON**, uploading the file. Microsoft's upload page lists JSON among the connectors that can upload a file in Power Query Online; whether the semantic-model editor in the service offers it on your account is what your instructor tested in class (activity 01, "Before you start"). The rest of the steps are the same.

## Checkpoints

- **C1:** a table of the 77 orders, one row per order, with `customer_id` and `city` as columns.
- **C2:** a table of 192 order lines, one row per item, with `product_id`, `qty` and `price`.
- **C3:** completed revenue for August 2026 online, 6,121.50, the same as SQL; shipping counted once per order.

## Step 1 · Open the file (C1)

**Home** → **Get data** → **JSON** → `online_orders_2026-08.json` → **Open**. Power Query opens on what it found.

**What you should see:** depending on your version, either a record with three fields (`exported`, `source`, `orders`) or a table already. If you see the record, click the word **List** beside `orders`: you are now looking at the list of 77 records. Then **Transform** → **To Table** → **OK** (no delimiter). You have one column, `Column1`, with **Record** in every row.

## Step 2 · Records into columns (C1)

1. Click the expand button in the `Column1` header. Keep every field ticked, untick **Use original column name as prefix**, **OK**.
2. The `customer` column says **Record**. Expand it the same way: `customer_id` and `city`.
3. Set the types: `order_id` **Whole Number**, `order_date` **Date**, `shipping_fee` **Decimal Number**.

**What you should see:** 77 rows; one row is one order. `items` still says **List** in every row. Two orders have no city (`null`).

**Check the shipping now:** one row is one order, so a sum of `shipping_fee` on this table is the shipping the website charged. Select `shipping_fee`, **Transform** → **Statistics** → **Sum**: **72.50**. Write it down, then delete that step in **Applied steps** (it turned the table into one number).

## Step 3 · A list into rows (C2)

1. Click the expand button in the `items` header and choose **Expand to New Rows**.
2. The column now says **Record**. Expand it: `product_id`, `qty`, `price`. Set `qty` to **Whole Number** and `price` to **Decimal Number**.
3. Rename the query `online_order_lines`.

**What you should see:** 192 rows. One row is now one **item**: order 102844 appears five times, once per product, with its `order_id`, `status` and `shipping_fee` repeated on each line.

## Step 4 · Revenue, and the shipping trap (C3)

1. **Add Column** → **Custom Column**. **New column name:** `line_total`. **Formula:** `[qty] * [price]`. **OK**, and set it to **Decimal Number**.
2. **Close & Apply**. A card with `line_total` (Sum), filter `status` = completed.
3. A second card with `shipping_fee` (Sum), no filter.

**What you should see:** `line_total` for completed orders: **6,121.50**, the same as SQL. `shipping_fee`: **107.50**, but the website charged **72.50**. After step 3 each order's fee sits on every line of that order, so the sum counts it once per item. Shipping belongs to the order, not the line: sum it on the order table from step 2, or keep it out of this table.

```sql
SELECT SUM(order_total) AS revenue, SUM(shipping_fee) AS shipping
FROM nakheel.orders
WHERE channel = 'online' AND FORMAT_DATE('%Y-%m', order_date) = '2026-08';
-- revenue for all 77 orders 7,956.00; add AND status = 'completed' for 6,121.50. shipping 72.50.
```

## Check yourself

| Checkpoint | One value to check |
|---|---|
| C1 | 77 rows; 2 with no city |
| C2 | 192 rows; order 102844 on 5 rows |
| C3 | completed `line_total` 6,121.50 · shipping 72.50 (not 107.50) |

## If something goes wrong

- **The expand menu has no Expand to New Rows:** the column holds records, not lists. **Expand to New Rows** is for a **List** column; a **Record** column shows its field names.
- **192 rows already in step 2:** you expanded `items` before `customer`. That is fine; check the count after each expand.

## Bonus

**More practice, not checked:** **Group By** on `online_order_lines`: group by `product_id`, sum `qty`, for completed orders only. Which product sold the most units in August? (Completed orders sold 357 units in all.)

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Button and menu names are those of Power BI Desktop in October 2026. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [JSON connector](https://learn.microsoft.com/en-us/power-query/connectors/json), [Upload a file in Power Query Online](https://learn.microsoft.com/en-us/power-query/upload-file), [Parse text as JSON or XML](https://learn.microsoft.com/en-us/power-query/parse-json-xml), [Group by](https://learn.microsoft.com/en-us/power-query/group-by).
