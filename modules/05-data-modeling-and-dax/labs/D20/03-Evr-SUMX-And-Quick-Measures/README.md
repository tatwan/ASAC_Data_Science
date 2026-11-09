# Activity 03 · Evaluate each sales line with SUMX

You will reproduce a wrong total, create a calculated column and use the same row calculation in a `SUMX` measure. Open the model from [Activity 01](../01-Evr-Load-Start-Files-And-Measures/README.md).

| Step | What you need to know | Tool |
|---|---|---|
| 1 | Why do bare column references fail in this measure? | New measure |
| 2 | What happens if you multiply the totals? | SUM |
| 3 | How can the model store the amount for each line? | New column |
| 4 | How can a measure add the selected line amounts? | SUMX |

## 1. Try the two columns in a measure

**Why this step.** A sales-line table can contain several quantities and prices for the selected order.

Try `Revenue attempt = sales_lines[qty] * sales_lines[price]` as a measure. Read the error and cancel the edit. Put product and line amount in a table. Use a page filter or slicer for order 100003 so the table and both cards use the same order.

**Check.** The table has three lines worth 24.00, 18.00 and 5.00. The standalone measure has no current line to supply a pair.

## 2. Multiply the column totals

**Why this step.** Adding each column first loses the pairing of the original sales lines.

```dax
Wrong Revenue =
SUM(sales_lines[qty]) * SUM(sales_lines[price])
```

Put it on a card with the same order filter. **Check.** Order 100003 gives 141.00. Its three quantities add to 3 and its prices add to 47.00.

## 3. Store a value for each line

**Why this step.** A calculated column evaluates the formula for each row of `sales_lines`. On the Compression top row, DAX reads the quantity and price from that row. This is **row context**.

1. In Desktop, right-click `sales_lines` in the **Data** pane and choose **New column**. On the web, open the semantic model in **Editing** mode, select `sales_lines` and choose **New column** in the ribbon.
2. Enter this DAX formula and press **Enter**.

   ```dax
   DAX Line Value = sales_lines[qty] * sales_lines[price]
   ```

3. On the report page, change the order filter to **100142**. In the table, put `products[product_name]` beside `qty`, `price` and **DAX Line Value** from `sales_lines`. Choose **Don't summarize** for the numeric fields so you can inspect the line values.

**Check.** Compression top has quantity **3** and price **16.00**. The new column shows **48.00** on that line. Its value matches the supplied `line_value`.

Add a slicer using `products[category]` and select **Outerwear**. The table shows only the Hooded sweatshirt line, worth **18.00**. Clear the category selection to see the Compression top line at **48.00** again. The filter changes which lines appear, while the column stores the value on each line. Return to order **100003** for Step 4.

## 4. Evaluate the expression on each selected line

**Why this step.** SUMX evaluates quantity times price on the current row before it adds the resulting amounts.

```dax
Revenue (SUMX) =
SUMX(sales_lines, sales_lines[qty] * sales_lines[price])
```

Compare Revenue (SUMX) with Total Revenue under identical filters.

| Filter | Both measures |
|---|---:|
| Order 100003 | 47.00 |
| Clear order and status | 340,370.00 |
| Completed status only | 316,023.50 |

**Check yourself.** Select order 100142. Its three amounts are 18.00, 48.00 and 28.00. SUMX returns 94.00. The wrong measure gives 288.00.

## Continue with the quick-measure example

Study the final quick-measure page in the [D20 PDF](../../../slides_pdf/D20-Time_Intelligence_SUMX_Report_Design.pdf). In Desktop, choose **New quick measure → Year-to-date total** with Completed Revenue and the date field. Inspect the generated expression. Compare December 2025 and April 2026 with the handwritten Revenue YTD. If the model or editor cannot generate the quick measure, use the handwritten route and compare its two results.

[Microsoft calculated columns](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-calculated-columns) · [Edit a model on the web](https://learn.microsoft.com/en-us/power-bi/transform-model/service-edit-data-models#create-calculated-columns) · [Microsoft SUMX](https://learn.microsoft.com/en-us/dax/sumx-function-dax) · [Microsoft quick measures](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-quick-measures)
