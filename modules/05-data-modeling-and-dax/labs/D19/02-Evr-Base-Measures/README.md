# Activity 02: write the base measures and check them against SQL

In this activity, you will write four explicit measures (Total Revenue, Orders, Customers and Average Order Value) and check each one against the answer you got in SQL.

**Files:** your file from activity 01 · **Data:** `sales_lines` (activity 01) · **Guide:** [the D19 page](../README.md)

**The question:** "What are completed revenue, completed orders, buying customers and the average order?" You know all four from SQL: 316,023.50 (D16), 2,771 (D07), 452 (D09) and 114.05 (D04).

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | Sum of `line_value` is named and made by Power BI | **New measure**: Total Revenue |
| 2 | `sales_lines` has one row per line, not per order | `DISTINCTCOUNT` |
| 3 | The measures count every status | a **Slicer** on `status` |
| 4 | `AVERAGE` gives the average line | `DIVIDE` with two measures |

We follow **order 100003**: three rows of `sales_lines`, one order, worth 47.00.

## Step 1 · Total Revenue

**Why this step:** a measure is a named calculation, stored in the model, that every visual can use. Written once, it can be used inside other measures (step 4).

1. Select `sales_lines` in the **Data** pane → **Home** → **New measure**. *Why select it first:* the measure lands in the selected table.
2. In the formula bar type the measure and press **Enter**:

```dax
Total Revenue = SUM(sales_lines[line_value])
```

3. In activity 01's card, replace **Sum of line_value** with **Total Revenue** (it has a calculator icon in the **Data** pane).

> **On the web:** in **Editing** mode, select `sales_lines` and click **New measure** in the ribbon; the formula bar is the same.

**Check:** **340,370.00**, the same as Sum of `line_value`.

**What just happened:** for order 100003 alone, Total Revenue would be 24.00 + 18.00 + 5.00 = 47.00: the measure adds whatever rows the visual keeps.

## Step 2 · Orders and Customers

**Why this step:** `sales_lines` has one row per order line (D18's grain), so counting rows counts lines. `DISTINCTCOUNT` counts each order once.

Two more measures on `sales_lines`, each in its own card:

```dax
Orders = DISTINCTCOUNT(sales_lines[order_id])
Customers = DISTINCTCOUNT(sales_lines[customer_id])
```

**Check:** Orders **3,000**, Customers **462**.

**What just happened:** order 100003 is three rows and counts as one order; C-1357 counts once however many lines it has.

## Step 3 · A slicer on status

**Why this step:** the three cards count every status, including cancelled and pending orders. SQL's answers count completed orders only.

A **Slicer** with `sales_lines[status]`; tick **completed**.

**Check:** **316,023.50 · 2,771 · 452**: D16's revenue, D07's completed orders and D09's buying customers.

**What just happened:** the measures did not change. The slicer chose the rows they add up and count. Order 100003 is completed, so its 47.00 is still inside. Part 3 of the slides explains this.

## Step 4 · Average Order Value with DIVIDE

**Why this step:** `AVERAGE(sales_lines[line_value])` averages the rows, and a row is a line: it gives 45.46, the average line. The average order is revenue divided by orders.

```dax
Average Order Value = DIVIDE([Total Revenue], [Orders])
```

*Why `DIVIDE` and not `/`:* `DIVIDE` returns a blank if the bottom number is zero or blank; the slash returns Infinity. *Why square brackets:* a measure inside a measure is written by its name, with no table in front.

**Check:** **114.05** (the completed slicer is still on).

**What just happened:** for order 100003, `AVERAGE` of its lines gives 15.67, but the order is worth 47.00. Divide the measures, not the rows.

## Check yourself

| Step | One value |
|---|---|
| 1 | 340,370.00 |
| 2 | 3,000 orders, 462 customers |
| 3 | 316,023.50 · 2,771 · 452 |
| 4 | 114.05 |

## If something goes wrong

- **The measure fills every row of a table with the same number, or shows in Table view:** you made a **New column**. Delete it and use **New measure**.
- **Orders reads 7,516:** you counted rows (`COUNTROWS`, or Count of `order_id`). Use `DISTINCTCOUNT`.
- **The measure landed in another table:** select it → **Measure tools** → **Home table** → `sales_lines`. It works either way.

## Hint

Leave the completed slicer on: activity 03 starts with it.

## References

Microsoft: [Create measures for data analysis](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-measures), [DIVIDE function vs divide operator](https://learn.microsoft.com/en-us/dax/best-practices/dax-divide-function-operator). Menu names are Power BI's in November 2026.
