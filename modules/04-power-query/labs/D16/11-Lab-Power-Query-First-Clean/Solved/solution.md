# Solution · Lab 11: Power Query, a first clean

## Walk through the clean and the charts

Start from `D16-nakheel-first-report`, with its completed-revenue card at **316,023.50**. The [lab instructions](../README.md) contain the tested browser screens and the full click paths.

1. Open Power Query. In the browser: open semantic model `D16-nakheel`, switch **Viewing → Editing**, then select **Transform data**. Select `customers` and its last step.
2. Profile `city` over the entire data set. There are six empty cities, five `amman` values, and seven `Al Zarqa` values. **Trim** and **Capitalize Each Word** combine `amman` with `Amman`: **196**.
3. Replace **Al Zarqa** with **Zarqa**, with **Match entire cell contents** ticked: **Zarqa 67**. Replace the empty city with **Unknown**, again matching the whole cell: **Unknown 6**. If the empty-text replacement does nothing, use the lab's null-value recovery. Rename the final step `City cleaned`. The cleaned column has eight cities plus `Unknown`.
4. Select `orders`. Check `order_total` is **Decimal Number**. Add the conditional column `order_size`: less than **50** → `small`; else if less than **150** → `medium`; else → `large`. Set the result to **Text**. Exactly 50 belongs to medium and exactly 150 to large, because the conditions use “less than”.
5. **Close & Apply**, or **Save** Power Query changes in the browser, return to the report and **Refresh**. Add a new report page.
6. Build two **Clustered column charts**, both using `order_size` on X-axis. One uses **Sum of order_total** on Y-axis; the other uses **Count of order_id**. Filter each visual to **completed**.

| Size | Completed orders | Completed revenue |
|---|---:|---:|
| small | 1,112 | 31,548.00 |
| medium | 1,183 | 101,835.00 |
| large | 476 | 182,640.50 |
| Total | 2,771 | 316,023.50 |

The largest orders are a smaller group but contribute more than half the revenue. A sum of numeric order IDs would not answer how many orders there were.

7. Add a **Line chart**: `order_date` on X-axis, **Sum of order_total** on Y-axis, with **completed** as its own visual filter. In the date hierarchy keep **Year** and **Month** only and select **Expand all down one level**. If no hierarchy is available, create the **Start of Month** column using the lab's alternative and refresh the report.
8. Check **24 months**, September 2024 to August 2026. Highest: **April 2026, 20,237.00**. Lowest: **November 2025, 9,772.50**. Removing Year would pool the two Septembers, two Octobers and so on into twelve points.
9. Save. Recheck the original completed-revenue card: cleaning customer cities and adding an order-size label should not change which orders it totals.

## The SQL behind each number

```sql
-- C2: cleaned cities
SELECT CASE
         WHEN city IS NULL OR TRIM(city) = '' THEN 'Unknown'
         WHEN INITCAP(TRIM(city)) = 'Al Zarqa' THEN 'Zarqa'
         ELSE INITCAP(TRIM(city))
       END AS city_clean,
       COUNT(*) AS customer_count
FROM nakheel.customers
GROUP BY city_clean
ORDER BY customer_count DESC;

-- C3: completed orders by size
SELECT CASE WHEN order_total < 50 THEN 'small'
            WHEN order_total < 150 THEN 'medium'
            ELSE 'large' END AS order_size,
       COUNT(*) AS orders,
       SUM(order_total) AS revenue
FROM nakheel.orders
WHERE status = 'completed'
GROUP BY order_size;

-- C3: completed revenue by month
SELECT FORMAT_DATE('%Y-%m', order_date) AS order_month,
       SUM(order_total) AS revenue
FROM nakheel.orders
WHERE status = 'completed'
GROUP BY order_month
ORDER BY order_month;
```

## The errors to name

1. **Size rules in the wrong order.** With `< 150` first, every small order becomes medium.
2. **Replace Values without Match entire cell contents.** On text columns the default replaces text inside cells; the empty replace then does nothing useful.
3. **Sum of order_id** left as the count of orders.
4. **Charts left without the `status` filter.**
5. **Year removed from the line chart's X-axis:** 12 points that add each month across the years.
