# Optional Lab 06 · PL-300 DAX workout: a second report page

You will practise PL-300 skills on the model you used in Activities 01–03: a calculated table, a second date role, a fiscal year, a calculation group, visual calculations, a DAX query and closing stock. They all go on one new report page called **Exam workout**. Each step ends with a number you can check. The April 2026 row and Outerwear category recur across the exercise, so you can compare the methods.

**Before you start.** Open the model from [Activity 01](../01-Evr-Load-Start-Files-And-Measures/README.md) with Revenue YTD and Revenue LY from [Activity 02](../02-Evr-Time-Intelligence/README.md). Save a copy named `D20-workout`. Step 3 changes a model setting that you cannot undo, so keep the copy separate from your Lab 04 report. Add a page named **Exam workout** and filter it to `sales_lines[status]` = completed.

| Step | PL-300 skill (domain) | What you build |
|---|---|---|
| 1 | Create calculated tables or columns (Model the data) | A category summary table |
| 2 | Implement role-playing dimensions; implement time intelligence measures (Model the data) | Delivered revenue and fiscal year to date |
| 3 | Create calculation groups (Model the data) | Current, YTD and Last year columns for any measure |
| 4 | Create visual calculations by using DAX (Visualize and analyze the data) | A running total and a share of the total |
| 5 | Identify poorly performing visuals by using Performance Analyzer and DAX query view (Model the data) | The DAX query behind a visual |
| 6 | Create semi-additive measures (Model the data) | Closing stock from weekly snapshots |

**On the web.** Steps 1 and 2 use the same formulas in the semantic model's **Editing** mode, which supports measures, calculated columns and calculated tables. The other steps differ:

- **Step 3.** Microsoft describes creating a calculation group in Desktop only. If the web editor has no **Calculation group** button, read D20 pages 72–73 and do Step 3 in Desktop.
- **Step 4.** Visual calculations are written in the report, not the model: open the report in **Edit** mode and look for **New calculation**.
- **Step 5.** In the service, open the report, choose **Edit**, then **View → Performance analyzer**. The service has **Copy query** but not **Run in DAX query view**. To run the query, open the semantic model's **…** menu in the workspace and choose **Write DAX queries**. That needs write permission on the model, and your workspace admin may need to turn on editing data models in the service.

## 1. Store a category summary as a table

**Why this step.** The exam asks when a stored table or column makes sense and when a measure does. A calculated table is computed when the model refreshes, so it does not respond to slicers.

1. In **Table view**, choose **New table** and enter:

   ```dax
   Category Revenue =
   ADDCOLUMNS(
       VALUES(products[category]),
       "Completed Revenue", [Completed Revenue]
   )
   ```

2. In `sales_lines`, choose **New column** and enter `Category = RELATED(products[category])`.

*Why a measure inside ADDCOLUMNS works:* the measure runs once for each category row, and DAX turns that row into a filter. This is the context transition from D20 page 40.

**Check.** The table has 6 rows, and the Outerwear row reads 76,637.00. Put a channel slicer on the page: the table's stored values stay the same.

**What just happened.** Outerwear's 76,637.00 is now stored in the model. The `Category` column copies each line's category from `products` through the relationship.

## 2. Use the delivery date and Nakheel's fiscal year

**Why this step.** `sales_lines` has two dates, but only one relationship to `dates` can be active. Nakheel's `fiscal_year` column starts each year on 1 September.

```dax
Delivered Revenue =
CALCULATE(
    [Completed Revenue],
    USERELATIONSHIP(dates[date], sales_lines[delivered_date])
)

Revenue FYTD =
TOTALYTD([Completed Revenue], dates[date], "8/31")
```

The third argument gives the last day of the fiscal year, written as month/day. Microsoft says the string is read in the model's locale, so a machine set to another locale may read it differently. If the Check below does not match, or the formula is rejected, use this version, which uses the `fiscal_year` column and no date string:

```dax
Revenue FYTD =
VAR LastDay = MAX(dates[date])
VAR ThisFY = MAX(dates[fiscal_year])
RETURN
    CALCULATE(
        [Completed Revenue],
        REMOVEFILTERS(dates),
        dates[fiscal_year] = ThisFY,
        dates[date] <= LastDay
    )
```

*Why it works:* in the April 2026 row, `LastDay` is 30 April 2026 and `ThisFY` is 2025-26. CALCULATE clears the month filter and keeps the days of 2025-26 up to 30 April.

Add a matrix to the page with `dates[year_month]` on Rows and these values: Completed Revenue, Delivered Revenue, Revenue YTD and Revenue FYTD.

**Check.** In the April 2026 row:

- Completed Revenue is 20,237.00 and Delivered Revenue is 17,815.50.
- Revenue YTD is 62,497.50 (from 1 January) and Revenue FYTD is 113,664.50 (from 1 September 2025).

**What just happened.** The April 2026 filter reached `sales_lines` through a different path or start date in each measure. Delivered Revenue now uses the inactive delivery-date relationship.

## 3. Create a time calculation group for revenue and orders

**Why this step.** Without a calculation group, each period needs its own measure: a YTD and an LY version of revenue, then of orders, and so on. A calculation group writes each period once and applies it to whichever measure the visual uses.

1. In **Model view**, choose **Calculation group** on the ribbon. If Power BI asks to turn on **Discourage implicit measures**, choose **Yes**. From now on, a dragged column is not summed automatically, so use explicit measures.
2. In the **Data** pane, double-click the new group to rename it `Time View`, and its column to `Period`. To add an item, right-click **Calculation items** and choose **New calculation item**. Write the three items:

   ```dax
   Current   = SELECTEDMEASURE()
   YTD       = CALCULATE(SELECTEDMEASURE(), DATESYTD(dates[date]))
   Last year = CALCULATE(SELECTEDMEASURE(), SAMEPERIODLASTYEAR(dates[date]))
   ```

3. Make a new matrix: `dates[year_month]` on Rows, `Time View[Period]` on Columns, and Completed Revenue and Orders in Values.

**Check.** In the April 2026 row:

| Measure | Current | YTD | Last year |
|---|---|---|---|
| Completed Revenue | 20,237.00 | 62,497.50 | 12,791.00 |
| Orders | 137 | 539 | 103 |

The revenue values match Revenue YTD and Revenue LY. Orders needs the page's completed filter.

**What just happened.** Three formulas produced six results. `SELECTEDMEASURE()` stood for whichever measure was in each Values cell.

## 4. Add a running total and a share inside the visuals

**Why this step.** A visual calculation is DAX that runs on the visual's own rows and columns. It is quick to write but stays in that one visual. A model measure can be reused anywhere.

1. Add a table with `dates[year_month]` and Completed Revenue. Filter this visual to `dates[year]` = 2026 and months up to 2026-08. Select it, choose **New calculation** and enter `Running total = RUNNINGSUM([Completed Revenue])`.
2. Add a bar chart with `products[category]` and Completed Revenue. Choose **New calculation** and enter:

   ```dax
   Share = DIVIDE([Completed Revenue], COLLAPSEALL([Completed Revenue], ROWS))
   ```

   Format it as a percentage.

**Check.** The running total reaches 122,583.00 in 2026-08: the same January–August total as Activity 02. Outerwear's Share is 24.3%, which matches D19's `% of Total`. Remove Completed Revenue from the bar chart: Share now has no input.

**What just happened.** `COLLAPSEALL` read the grand total from the visual's own total, where D19's measure used `REMOVEFILTERS(products)`.

## 5. Read the query behind a visual

**Why this step.** Every visual sends a DAX query to the model. Performance Analyzer shows how long each visual takes. DAX query view runs the query so you can read it or change it.

1. In **Report view**, open **Optimize → Performance analyzer**, then choose **Start recording** and **Refresh visuals**. Expand the Step 3 matrix and choose **Run in DAX query view**. If you see only **Copy query**, open **DAX query view** (the icon on the left side of Desktop), paste the query into a new tab and choose **Run**.
2. In a new DAX query tab, run:

   ```dax
   EVALUATE
   SUMMARIZECOLUMNS(
       products[category],
       "Completed Revenue", [Completed Revenue]
   )
   ORDER BY [Completed Revenue] DESC
   ```

**Check.** The first result row is Outerwear, 76,637.00, as in Step 1's table. In Performance Analyzer, compare the **DAX query** time with the **Visual display** time: they show whether the model or the drawing took longer.

**What just happened.** `SUMMARIZECOLUMNS` grouped by category like SQL's `GROUP BY`. The same Outerwear total came back through a query, a stored table, a visual calculation and a measure.

## 6. Use the last weekly snapshot as closing stock

**Why this step.** Revenue adds across dates. Stock on hand is a balance that you can add across products on the same date. To show closing stock for a month, select its last recorded snapshot instead of summing every Friday.

1. Download [inventory_snapshots.csv](Resources/inventory_snapshots.csv). Read its [data dictionary](Resources/README.md). Import it as `inventory_snapshots`, with snapshot_date as **Date**, product_id as **Text** and units_on_hand as **Whole number**. In Desktop, use **Home → Get data → Text/CSV**. On the web, open the semantic model in **Editing** mode and use its **Get data** route to upload the CSV.

   **Check.** The table has 32 rows: four products on eight Fridays.

2. In Model view, create active **1:* / Single** relationships from `dates[date]` to `inventory_snapshots[snapshot_date]` and from `products[product_id]` to `inventory_snapshots[product_id]`. Keep both dimensions on the **1** side.

   *Why these relationships:* the month filter reaches the snapshot dates, while a product filter selects the balance of that product. The stock table has no direct relationship to sales_lines.

   **Check.** Both relationship lines are solid, and both arrows point from the dimension towards inventory_snapshots.

3. Create the measure:

   ```dax
   Stock on Hand =
   CALCULATE(
       SUM(inventory_snapshots[units_on_hand]),
       LASTNONBLANK(
           dates[date],
           CALCULATE(COUNTROWS(inventory_snapshots))
       )
   )
   ```

   *Why the inner CALCULATE:* LASTNONBLANK tests each candidate date. CALCULATE turns that date into a filter on the snapshot rows. COUNTROWS is blank when there is no snapshot, so the function finds the last populated date within the selected period.

   Add a matrix with `dates[year_month]` on Rows and Stock on Hand in Values. Filter this matrix to March and April 2026. Keep product and calculation-group selections clear. The page’s completed-status filter affects sales_lines and does not filter the stock fact through these Single relationships.

   **Check.** March shows **137** and April **79** units. The total over both months is **79**, the last recorded balance in that period, rather than 216. A total is a fresh evaluation of the measure.

4. Add this comparison measure to the matrix:

   ```dax
   Stock at Calendar Month End =
   CLOSINGBALANCEMONTH(
       SUM(inventory_snapshots[units_on_hand]),
       dates[date]
   )
   ```

   **Check.** The comparison is blank for both months: neither 31 March nor 30 April has a snapshot. A plain SUM of units_on_hand would instead show 580 and 400.

**What just happened.** The March filter selected four Fridays. The measure retained 27 March and added its four product balances, giving 137. In April, it selected 24 April and returned 79. This is a semi-additive measure: it adds products on one date and selects a balance across dates. The supplied file has every product on every Friday. Do not treat this formula as a general carry-forward rule for incomplete snapshots.

**Finish the page.** Arrange the two matrices, the running-total table, share bars and stock matrix into a page you could show a manager. Give each visual a title that names its period. Save the file.

[Calculation groups](https://learn.microsoft.com/en-us/power-bi/transform-model/calculation-groups) · [Visual calculations](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-visual-calculations-overview) · [DAX query view](https://learn.microsoft.com/en-us/power-bi/transform-model/dax-query-view) · [Performance Analyzer](https://learn.microsoft.com/en-us/power-bi/create-reports/performance-analyzer) · [USERELATIONSHIP](https://learn.microsoft.com/en-us/dax/userelationship-function-dax) · [TOTALYTD](https://learn.microsoft.com/en-us/dax/totalytd-function-dax) · [Edit models in the service](https://learn.microsoft.com/en-us/power-bi/transform-model/service-edit-data-models)
