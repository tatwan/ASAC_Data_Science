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

**In the browser:** open your semantic model's Power Query and choose **Get data → JSON → Upload file**, if that connector is offered. The D16 rehearsal tested CSV upload, not JSON. If JSON upload is unavailable on your account, use Desktop or pair with someone using it. The expansion steps below are the same.


## Checkpoints

- **C1:** a table of the 77 orders, one row per order, with `customer_id` and `city` as columns.
- **C2:** a table of 192 order lines, one row per item, with `product_id`, `qty` and `price`.
- **C3:** completed revenue for August 2026 online, 6,121.50, the same as SQL; shipping counted once per order.

## Step 1 · Open the file (C1)

**Home** → **Get data** → **JSON** → `online_orders_2026-08.json` → **Open**. Power Query opens on what it found.

Power BI may automatically flatten the JSON. To practise each expand yourself, remove the automatically added steps **after `Source`**, starting with the last step and working upwards. Keep `Source`, which should return a record with the fields `exported`, `source` and `orders`.

1. Click **List** beside `orders`. You now have a list of 77 records.
2. Select **Transform → To Table → OK**, leaving the delimiter as **None**.

**What you should see:** one column, `Column1`, with **Record** in every row. Each record is one order. If `Source` itself is already a table, check its formula: this exercise starts from `Json.Document(...)`, before any expansion.

## Step 2 · Records into columns (C1)

1. Click the expand button in the `Column1` header. Keep every field ticked, untick **Use original column name as prefix**, **OK**.
2. The `customer` column says **Record**. Expand it the same way: `customer_id` and `city`.
3. Set the types: `order_id` **Whole Number**, `order_date` **Date**, `shipping_fee` **Decimal Number**.

**What you should see:** 77 rows; one row is one order. `items` still says **List** in every row. Two orders have no city (`null`).

**Keep an order-level copy:** right-click the query → **Duplicate**, name the copy `online_orders`, and keep it at this 77-row stage. Its `items` column is still a List; right-click that column → **Remove** in the copy so it can load as an ordinary order table. Return to the original query for the next step.

Why **Duplicate** here, when activity 04 taught **Reference**? A Reference reads the original query's final result, and in step 3 that result becomes item rows. A Duplicate keeps its own copy of the steps, so it stays at 77 orders.

**Check the shipping now:** one row is one order, so a sum of `shipping_fee` on this table is the shipping the website charged. Select `shipping_fee`, **Transform** → **Statistics** → **Sum**: **72.50**. Write it down, then delete that step in **Applied steps** (it turned the table into one number).

## Step 3 · A list into rows (C2)

1. Click the expand button in the `items` header and choose **Expand to New Rows**.
2. The column now says **Record**. Expand it: `product_id`, `qty`, `price`. Set `qty` to **Whole Number** and `price` to **Decimal Number**.
3. Rename the query `online_order_lines`.

**What you should see:** 192 rows. One row is now one **item**: order 102844 appears five times, once per product, with its `order_id`, `status` and `shipping_fee` repeated on each line.

## Step 4 · Revenue, and the shipping trap (C3)

1. **Add Column** → **Custom Column**. **New column name:** `line_total`. **Formula:** `[qty] * [price]`. **OK**, and set it to **Decimal Number**.
2. **Close & Apply** (browser: **Save**, then refresh the report). A card with `line_total` (Sum), filter `status` = completed.
3. A second card with `shipping_fee` (Sum), no filter.

**What you should see:** `line_total` for completed orders: **6,121.50**, the same as SQL. `shipping_fee`: **107.50**, but the website charged **72.50**. After step 3 each order's fee sits on every line of that order, so the sum counts it once per item. Shipping belongs to the order, not the line: verify it with a third card from `online_orders[shipping_fee]` (Sum), with no filter: **72.50**. The comparison is over all statuses on both shipping cards. Do not remove duplicate fee values: two different orders can charge the same fee.

```sql
SELECT SUM(order_total) AS revenue, SUM(shipping_fee) AS shipping
FROM nakheel.orders
WHERE channel = 'online' AND FORMAT_DATE('%Y-%m', order_date) = '2026-08';
-- revenue for all 77 orders 7,956.00; add AND status = 'completed' for 6,121.50. shipping 72.50.
```

Save your changes before continuing: **File → Save** on Desktop; in the browser, **Save** Power Query changes, refresh the report and save the report.

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

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Use the [D17 guide](../README.md) for saving, browser navigation and row-count checks. Button and menu names can vary between Desktop and the browser. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [JSON connector](https://learn.microsoft.com/en-us/power-query/connectors/json), [Upload a file in Power Query Online](https://learn.microsoft.com/en-us/power-query/upload-file), [Parse text as JSON or XML](https://learn.microsoft.com/en-us/power-query/parse-json-xml), [Group by](https://learn.microsoft.com/en-us/power-query/group-by).
