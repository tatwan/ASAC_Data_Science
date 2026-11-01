# Which shop, which month?

In this activity, you will answer two questions a regional manager would ask, using the table you combined from the shop files, and spot one file that does not belong to a shop.

**In class:** on your own · **Data:** `store_files_sales` from activity 02 · **Tool:** Power BI Desktop or the browser

## The story

The regional manager has the shop files in one table now and asks: which shop brings in the most, which month was the best, and is every file really a shop? Each answer is one chart.

## What you will learn

- Build completed-revenue charts by store and by calendar month.
- Keep a count of all orders separate from a completed-only revenue total.
- Use the source note and order dates to identify a temporary store.

## Before you start

You need `store_files_sales` from activity 02, loaded, with its `store_code` column. If you do not have it, do activity 02 first.

## Instructions

1. Which shop had the highest completed revenue over the two years, and how much?

    Translate: a **Clustered bar chart**, `store_code` on the **Y-axis**, `order_total` (Sum) on the **X-axis**, filter `status` = completed, sorted by the sum.

2. Which month was the best for the shops, and which was the worst?

    Translate: a **Line chart**, `order_date` on the **X-axis**, `order_total` (Sum) on the **Y-axis**, the same filter. In the **X-axis** well keep **Year** and **Month** and remove **Quarter** and **Day**, then click **Expand all down one level in the hierarchy** above the chart to see all 24 months.

3. One store code in your chart from question 1 is not like the others. Which one, and what does `notes.txt` in the folder say about it? How many orders did it take, and on which dates?

    Translate: filter `store_code` to that code; look at the smallest and largest `order_date`.

Save your changes before continuing: **File → Save** on Desktop; in the browser, **Save** Power Query changes, refresh the report and save the report.

## Check yourself

| Question | One value to check |
|---|---|
| 1 | 12 bars; the top shop took 44,776.50 |
| 2 | 24 points; the best month took 13,585.50, the worst 4,405.00 |
| 3 | 19 orders over two weeks in March 2025 |

A different number is information, not failure. Check the `status` filter first: without it every total is higher.

## Hint

For question 2, if your line has 12 points, you removed **Year** too: each point then adds up a calendar month across both years.

If no automatic date hierarchy is available, open Power Query, select `store_files_sales[order_date]` and choose **Add Column → Date → Month → Start of Month**. Apply/save the change, refresh the report and use that new full-date column on X-axis. It keeps September 2024 separate from September 2025.

## Bonus

Add a slicer on `store_code` beside the line chart and click through the Irbid shops. Do they peak in the same months?

## References

Use the [D17 guide](../README.md) for saving, browser navigation and row-count checks. Button and menu names can vary between Desktop and the browser. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md).
