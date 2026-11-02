# Solution · Activity 10: from a CSV file to a chart

## Walk through the report

Use the [activity instructions](../README.md) for the full Desktop and browser click paths and the captured screens. The final report has three visuals, all using the same `customers` and `orders` tables.

1. Import `customers.csv` with **Transform Data**. In the browser, start with **+ New Report → Get data**, upload the CSV and continue with **Next** into Power Query.
2. Profile `segment` over the whole data set. The raw counts are `Retail` 408, `Wholesale` 61, `retail` 18, `RETAIL ` 9 and `wholesale` 4. Power Query treats those spellings separately.
3. Select `segment`, then **Transform → Format → Trim**, followed by **Capitalize Each Word**. The two cleaned groups are **Retail 435** and **Wholesale 65**. Keep the last Applied step selected.
4. **Close & Apply** on Desktop, or **Create a report** in the browser, with semantic model name `D16-nakheel`. Build a **Clustered bar chart**: `segment` on Y-axis; `customer_id` on X-axis as **Count**, not a sum. The two bars should account for all 500 customers.
5. Add `orders.csv`. Desktop: **Home → Get data → Text/CSV → Load**. Browser: **Open semantic model → Editing → Get data → Text/CSV**, upload, continue into Power Query and **Save**; return to the report and **Refresh**. Both tables must belong to this model.
6. Add a **Card** with **Sum of order_total** from `orders`. Before filtering it reads **340,370.00**. Set **Format visual → Visual → Callout → Apply settings to: Sum of order_total → Value → Display units → None**. Add `orders[status]` to **Filters on this visual**, keeping **completed**: **316,023.50**.
7. Add a **Clustered column chart** with `orders[channel]` on X-axis and **Sum of order_total** on Y-axis. Give this chart its own **completed** filter. It shows **store 205,338.00** and **online 110,685.50**. Those two values add up to the card.
8. Save the report as `D16-nakheel-first-report` (`.pbix` on Desktop). The browser workspace contains both a report and a semantic model; the report displays the data stored in its model.

The cleaning check belongs in Power Query, where text comparisons distinguish case. The revenue check belongs on each visual, where its filter determines which orders are added.

| Power Query step | SQL you already know |
|---|---|
| `Source`, `Promoted Headers` | the upload: first row as column names |
| `Changed Type` | the schema: `signup_date` DATE, the rest STRING |
| `Trimmed Text` | `TRIM(segment)` |
| `Capitalized Each Word` | `INITCAP(...)` |

## The SQL behind each number

```sql
-- Step 2: the five spellings
SELECT segment, COUNT(*) AS customers
FROM nakheel.customers
GROUP BY segment
ORDER BY customers DESC;

-- Steps 3 and 4: the two segments
SELECT INITCAP(TRIM(segment)) AS segment_clean, COUNT(*) AS customers
FROM nakheel.customers
GROUP BY segment_clean;

-- Step 5: every order, then completed revenue
SELECT SUM(order_total) AS all_orders FROM nakheel.orders;               -- 340,370.00
SELECT SUM(order_total) AS revenue FROM nakheel.orders
WHERE status = 'completed';                                              -- 316,023.50

-- Step 6: completed revenue by channel
SELECT channel, SUM(order_total) AS revenue
FROM nakheel.orders
WHERE status = 'completed'
GROUP BY channel;
```

## The errors to name at the review

1. **A visual without the `status` filter.** The card counts cancelled (21,998.50, 212 orders) and pending (2,348.00, 17 orders) as revenue: 316,023.50 + 21,998.50 + 2,348.00 = 340,370.00. The column chart in step 6 does not inherit the card's filter.
2. **Load instead of Transform Data,** so the cleaning never happened. Inspect the Power Query profile; the model can group case variants in the chart.
3. **Add Column → Format instead of Transform → Format:** Power Query adds a new cleaned column (named after the step, for example `Trimmed Text`) and leaves `segment` as it was. Check the original column's profile to confirm which field was cleaned.
4. **Picking a visual type while another visual is selected:** the bar chart turns into a card.
