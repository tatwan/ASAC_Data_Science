# PL-300 cheat sheet · Model the data (DAX and the semantic model)

Use this sheet to revise for the **Model the data** domain of PL-300 (25–30% of the exam; [skills as of 20 April 2026](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/pl-300)). The examples use the Nakheel model from D18–D20: `sales_lines` (one row per order line), `customers`, `products` and `dates`. The questions at the end come with explained answers. Use them to find what to re-read in the D18, D19 and D20 PDFs.

## 1. Where a calculation lives

| Option | Stored in the model? | Reacts to slicers? | Use it when | Nakheel example |
|---|---|---|---|---|
| Power Query column | Yes, at refresh | No | Cleaning or shaping, or the source should hold the value | `line_value` arrives already calculated |
| DAX calculated column | Yes, at refresh | No | You need a value per row to slice, filter or sort by | `Category = RELATED(products[category])` |
| DAX calculated table | Yes, at refresh | No | A helper or summary table, a date table, a role-playing copy | `CALENDAR(DATE(2024,1,1), DATE(2026,12,31))` |
| Measure | No, runs per visual cell | Yes | Any total, ratio or comparison that must follow filters | `Completed Revenue`, `YoY %` |
| Visual calculation | No, it lives in one visual | Yes, within that visual | A running total, rank or share of one visual's rows | `RUNNINGSUM([Completed Revenue])` |

Calculated columns and tables add memory and refresh time. A measure adds neither. If the question says "respond to the user's selections", the answer is a measure, or a visual calculation when it concerns one visual only.

## 2. The three ideas behind every DAX result

- **Filter context:** the filters that decide which rows a measure sees: slicers, filters, the visual's rows and columns, and CALCULATE's arguments. The Outerwear row of a table filters `products[category]` = Outerwear. The relationship carries that filter to `sales_lines`.
- **Row context:** "the current row". It exists in a calculated column and inside iterators (`SUMX`, `AVERAGEX`, `FILTER`, `ADDCOLUMNS`). On its own, a row context does not filter other tables.
- **Context transition:** inside a row context, `CALCULATE`, or any measure, turns the current row into a filter. That is why `ADDCOLUMNS(VALUES(products[category]), "Rev", [Completed Revenue])` gives a different number on each category row: Outerwear gets 76,637.00.

## 3. Functions by exam skill

| Exam skill | Functions to recognise | One-line rule |
|---|---|---|
| Single aggregation measures | `SUM`, `AVERAGE`, `MIN`, `MAX`, `COUNT`, `COUNTA`, `COUNTROWS`, `DISTINCTCOUNT`, `DISTINCTCOUNTNOBLANK` | `COUNTROWS` counts rows of a table. `DISTINCTCOUNT` counts a blank as one value; `DISTINCTCOUNTNOBLANK` does not |
| Safe arithmetic | `DIVIDE(top, bottom, [alternate])`, `BLANK()`, `COALESCE` | `DIVIDE` returns BLANK (or the alternate) when the bottom is 0 or blank, where `/` gives Infinity or an error |
| CALCULATE | `CALCULATE(expr, filter, …)` | A filter like `t[col] = "x"` **replaces** any existing filter on that column |
| CALCULATE modifiers | `REMOVEFILTERS`, `ALL`, `ALLEXCEPT`, `ALLSELECTED`, `KEEPFILTERS`, `USERELATIONSHIP`, `CROSSFILTER` | `KEEPFILTERS` **intersects** with the existing filter. `ALLSELECTED` keeps slicer filters and drops the visual's own rows (a "% of visible total"). `ALLEXCEPT(products, products[category])` clears every `products` filter except category |
| Table filters | `FILTER(table, condition)`, `VALUES`, `DISTINCT` | Prefer a simple column filter in CALCULATE. Use `FILTER` when the condition needs a measure, such as months with revenue above 15,000 |
| Iterators | `SUMX`, `AVERAGEX`, `MINX`, `MAXX`, `COUNTX`, `RANKX` | `SUMX(sales_lines, qty * price)` multiplies each line, then adds. `SUM(qty) * SUM(price)` multiplies totals, which is wrong: 141.00 instead of 47.00 for order 100003 |
| Relationships in DAX | `RELATED` (many → one), `RELATEDTABLE` (one → many) | `RELATED` needs a row context on the many side |
| Conditions and helpers | `IF`, `SWITCH(TRUE(), …)`, `SELECTEDVALUE`, `HASONEVALUE`, `ISBLANK` | `SELECTEDVALUE(products[category], "All categories")` returns the one selected value, or the fallback when there are several or none |
| Readability | `VAR … RETURN` | A variable is evaluated once, where it is defined, so its value does not change later in the formula |
| Time intelligence | `TOTALYTD`/`DATESYTD`, `TOTALQTD`, `TOTALMTD`, `SAMEPERIODLASTYEAR`, `DATEADD`, `PARALLELPERIOD`, `DATESBETWEEN`, `DATESINPERIOD`, `PREVIOUSMONTH` | All need a marked date table with contiguous dates. A fiscal year uses the year-end argument: `TOTALYTD([Completed Revenue], dates[date], "8/31")` |
| Basic statistics | `AVERAGE`, `MEDIAN`, `MEDIANX`, `MIN`, `MAX`, `STDEV.P`, `PERCENTILE.INC` | A few large orders pull the mean above the median. Average order value is `DIVIDE([Revenue], [Orders])`, not `AVERAGE(line_value)` (45.46 against 114.05) |
| Semi-additive measures | `LASTDATE`, `LASTNONBLANK`, `CLOSINGBALANCEMONTH`, `OPENINGBALANCEMONTH` | Stock or a balance adds across products but **not across dates**: take the last date in the period |
| Calculated tables | `CALENDAR`, `CALENDARAUTO`, `ADDCOLUMNS`, `SUMMARIZECOLUMNS`, `DATATABLE` | Computed at refresh, so a calculated table never reacts to a slicer |
| Calculation groups | `SELECTEDMEASURE()`, `SELECTEDMEASURENAME()` | One item, such as YTD, applies to any **explicit** measure. Creating a group turns on *Discourage implicit measures* |
| Visual calculations (listed under *Visualize and analyze the data*) | `RUNNINGSUM`, `MOVINGAVERAGE`, `PREVIOUS`, `NEXT`, `FIRST`, `LAST`, `COLLAPSE`, `COLLAPSEALL`, `EXPAND` | They read the visual's own grid. They are not reusable and cannot use `RELATED` or `USERELATIONSHIP` |
| Quick measures | (generated DAX) | Power BI writes a normal measure that you can read and edit. Check it against your own formula |

**Nakheel's April 2026 checks:**

- Completed Revenue: 20,237.00
- YTD: 62,497.50
- Last year: 12,791.00
- YoY: +58.2%
- By delivery date: 17,815.50
- Fiscal YTD (from 1 Sep): 113,664.50

## 4. The model rules the exam tests

- **Star schema.** Facts (numbers, many rows) sit in the middle and dimensions (the "by" words) around them. Relationships go one-to-many from the dimension to the fact, with **single** cross-filter direction by default.
- **Star or snowflake.** A snowflake splits a dimension into chained tables, such as product → subcategory → category. Power BI works best with a star, so flatten those chains into one dimension in Power Query.
- **Cardinality:**
  - One-to-many: the normal case.
  - One-to-one: often a sign that the two tables should be merged.
  - Many-to-many: a bridge table or a relationship set to many-to-many. It needs care, because totals can surprise you.
- **Both directions** let a fact filter a dimension. They can create ambiguous paths and slow the model. Prefer `CROSSFILTER(…, Both)` inside the one measure that needs it.
- **Date table:**
  - one row per day, with no gaps and no duplicates;
  - a Date-type column;
  - full years recommended;
  - marked with **Mark as date table**;
  - Auto date/time turned off in real models.
- **Role-playing dimension.** A table can have only one active relationship to `dates`, so `sales_lines[delivered_date]` gets an **inactive** one. Use it with `USERELATIONSHIP` inside CALCULATE, or load a second date table when users need to slice by both dates.
- **Table and column properties** (all in Model view or Column tools):
  - *Sort by column*: month name by month number.
  - Data type and format.
  - *Data category*: City, Country, URL, so maps and links work.
  - *Summarize by*: set None for IDs and years.
  - Hide foreign keys and helper columns.
  - Hierarchies (Year → Month → Date).
  - Display folders.
  - Synonyms for Q&A.
- **Performance:**
  - Remove columns and rows nobody uses.
  - Split high-cardinality columns, such as datetime into date and time.
  - Reduce granularity: daily instead of per-transaction, if no question needs the detail.
  - Find slow visuals with **Performance Analyzer**: DAX query, Visual display and Other time.
  - Read and test the query in **DAX query view** (`EVALUATE`, `DEFINE MEASURE`).

## 5. Traps that cost marks

1. A measure divided by itself is 100% on every row. The bottom number needs `REMOVEFILTERS` or `ALL`.
2. `CALCULATE([Revenue], products[category] = "Shoes")` shows Shoes on **every** row of a category table, because the filter replaced the row's filter. Use `KEEPFILTERS` to intersect.
3. A YoY % for a month with no sales yet shows −100%. Guard against it, or filter the report to the last complete date (31 August 2026 for Nakheel).
4. Comparing a part year with a full year is not growth. 2026 against all of 2025 reads −16.9%; January–August against January–August reads +27.1%.
5. Time-intelligence functions return nothing useful if the date table is not marked or has gaps.
6. `VALUES(column)` can include a blank row for unmatched keys (C-0999 in `sales_lines`). `DISTINCT(column)` does not.
7. Calculated columns and tables do not respond to slicers. A question about selections needs a measure.
8. A visual calculation disappears from a visual when you remove its input field, and you cannot reuse it in another visual.
9. With a calculation group in the model, implicit measures stop working. Every value needs an explicit measure.
10. Bi-directional relationships "to make the slicer work" are rarely the best answer. Look for a measure-level option or a model fix.

## 6. Test yourself

Answer before you open each explanation.

**Q1.** You need a column that shows each product's category on `sales_lines`, so that you can use it in a slicer. Which is correct?
A. `Category = RELATED(products[category])` as a measure · B. `Category = RELATED(products[category])` as a calculated column · C. `Category = RELATEDTABLE(products)` as a calculated column · D. `Category = VALUES(products[category])` as a measure

<details><summary>Answer</summary>

**B.** `RELATED` follows a many-to-one relationship from the current row of `sales_lines`, and a calculated column has that row context. A measure has no current row (A, D), and a slicer needs a column. `RELATEDTABLE` goes the other way, from one to many, and returns a table.
</details>

**Q2.** A manager wants revenue by **delivery** month. The relationship from `dates[date]` to `sales_lines[delivered_date]` exists but is inactive. What do you add?
A. Make it active and the order-date one inactive · B. `CALCULATE([Completed Revenue], USERELATIONSHIP(dates[date], sales_lines[delivered_date]))` · C. Set the relationship to Both directions · D. `CALCULATE([Completed Revenue], ALL(dates))`

<details><summary>Answer</summary>

**B.** USERELATIONSHIP activates the inactive path for this measure only, giving 17,815.50 for April 2026. A breaks every existing order-date measure. C changes the filter direction, not which path is active. D removes date filters altogether.
</details>

**Q3.** `% of Total = DIVIDE([Completed Revenue], [Completed Revenue])` shows 100% on every category row. What should the denominator be?
A. `CALCULATE([Completed Revenue], REMOVEFILTERS(products))` · B. `CALCULATE([Completed Revenue], KEEPFILTERS(products[category]))` · C. `SUMX(products, [Completed Revenue])` · D. `[Completed Revenue] * 1`

<details><summary>Answer</summary>

**A.** The bottom number must ignore the category filter from the row, so Outerwear gives 76,637.00 / 316,023.50 = 24.3%. B keeps the row's filter, which gives 100% again. C adds the categories in the current filter, so it still equals the row's value. D changes nothing.
</details>

**Q4.** Revenue YTD returns the same value on every month row. What is the most likely cause?
A. The measure uses DIVIDE · B. The date column used in the visual comes from `sales_lines`, or `dates` is not related or not marked · C. The visual has totals turned on · D. The model has too many rows

<details><summary>Answer</summary>

**B.** Time intelligence shifts dates in the date table. The visual must use `dates` columns, and `dates` must be related and marked with contiguous dates. A, C and D do not change how dates are shifted.
</details>

**Q5.** Nakheel's fiscal year ends on 31 August. Which measure returns fiscal year-to-date revenue?
A. `TOTALYTD([Completed Revenue], dates[date])` · B. `TOTALYTD([Completed Revenue], dates[date], "8/31")` · C. `SAMEPERIODLASTYEAR(dates[date])` · D. `DATESINPERIOD(dates[date], MAX(dates[date]), -1, YEAR)`

<details><summary>Answer</summary>

**B.** The third argument sets the year end, giving 113,664.50 for April 2026. A uses the calendar year (62,497.50). C returns a table of dates, not a measure. D is a rolling 12 months, not a fiscal year to date.
</details>

**Q6.** You must show Current, YTD and Last year for revenue, orders and average order value without writing nine measures. What do you create?
A. Three calculated tables · B. A calculation group with three items that use `SELECTEDMEASURE()` · C. A field parameter · D. Nine quick measures

<details><summary>Answer</summary>

**B.** Each item is written once and applies to any explicit measure. A field parameter (C) lets users switch which fields a visual shows, but does not change the calculation. A stores static results. D still creates nine measures.
</details>

**Q7.** Stock on hand is recorded every Friday. Report users see a sum of all Fridays in a month. Which formula fixes the monthly value?
A. `SUM(Inventory[Units])` · B. `AVERAGE(Inventory[Units])` · C. `CALCULATE(SUM(Inventory[Units]), LASTNONBLANK(dates[date], CALCULATE(SUM(Inventory[Units]))))` · D. `SUMX(dates, SUM(Inventory[Units]))`

<details><summary>Answer</summary>

**C.** Stock is semi-additive: it adds across products but not across dates. C takes the last date in the period that has a snapshot. `LASTDATE` alone would pick the 31st, which may have no snapshot and return blank. A and D add the Fridays. B averages them, which is a different question.
</details>

**Q8.** A table visual by month needs a running total that is used only in that visual. What is the quickest correct option?
A. A calculated column · B. A visual calculation `RUNNINGSUM([Completed Revenue])` · C. A Power Query index column · D. A calculated table

<details><summary>Answer</summary>

**B.** A visual calculation reads the visual's own rows (2026-08 reaches 122,583.00). A, C and D store values at refresh, so they would not follow the visual's filters. If the running total must be reused across visuals, write a model measure instead.
</details>

**Q9.** In a table of categories, a measure must show Shoes revenue on the Shoes row and BLANK on the other rows. Which filter do you use?
A. `CALCULATE([Revenue], products[category] = "Shoes")` · B. `CALCULATE([Revenue], KEEPFILTERS(products[category] = "Shoes"))` · C. `CALCULATE([Revenue], ALL(products))` · D. `FILTER(products, products[category] = "Shoes")`

<details><summary>Answer</summary>

**B.** KEEPFILTERS intersects with the row's filter, and Outerwear ∩ Shoes is empty, so the result is BLANK. A replaces the row's filter, so every row shows Shoes. C removes the filter. D returns a table, not a value.
</details>

**Q10.** A report page is slow. Which tool shows how long each visual's DAX query takes, and lets you open that query?
A. Query diagnostics in Power Query · B. Performance Analyzer · C. Column profile · D. Manage relationships

<details><summary>Answer</summary>

**B.** Performance Analyzer times each visual: DAX query, Visual display and Other. It can copy the query or run it in DAX query view. Query diagnostics (A) times Power Query steps during refresh, not report visuals.
</details>

**Q11.** Which change reduces the model's size **without** losing any question the business asks? The business only reports by day.
A. Turn on Both-direction relationships · B. Replace the transaction-level fact with one row per day per product · C. Add a calculated column with the transaction time · D. Keep Auto date/time on

<details><summary>Answer</summary>

**B.** Reducing granularity to the level of the questions shrinks the fact table. You lose only questions about individual transactions, which nobody asks here. C adds a high-cardinality column. D adds hidden date tables. A changes filtering, not size.
</details>

**Q12.** `Average Order Value = AVERAGE(sales_lines[line_value])` gives 45.46. The expected value is 114.05. Why?
A. AVERAGE ignores blanks · B. The table has one row per order line, so the result is the average line, not the average order · C. The status filter is missing · D. AVERAGE needs a date table

<details><summary>Answer</summary>

**B.** The grain is one row per line. An order's value is the sum of its lines, so use `DIVIDE([Revenue], [Orders])`, or `AVERAGEX(VALUES(sales_lines[order_id]), [Revenue])`. C would change both numbers, not explain the gap. A and D are not involved.
</details>

**Q13.** When is a calculated **table** the right choice?
A. To show revenue that responds to a channel slicer · B. To create a second date table for a role-playing date that users must slice by, or a static summary · C. To calculate YoY % · D. To format a visual

<details><summary>Answer</summary>

**B.** Calculated tables are computed at refresh. That suits a date table, a role-playing copy or a fixed summary. Anything that must respond to slicers (A, C) is a measure.
</details>

**Q14.** You create a calculation group. Visuals that used the `qty` column dragged straight into Values stop summing. Why?
A. Calculation groups delete columns · B. Creating a calculation group turns on Discourage implicit measures, so you need explicit measures · C. `qty` became text · D. The relationship became inactive

<details><summary>Answer</summary>

**B.** Calculation groups work only with explicit measures, so Power BI discourages implicit ones. Write `Units = SUM(sales_lines[qty])` and use it in the visual.
</details>

## Where to revise

| Topic | Where to read it |
|---|---|
| All 16 Model-the-data skills in exam order | [Standalone study guide](../slides_pdf/PL300-Study-Guide-Model-The-Data.pdf), with a linked index and explained questions |
| Star schema, grain, relationships, date table, role-playing dates | D18 PDF; study guide pages 6–31 |
| Measures, filter context, CALCULATE, percent of total, KEEPFILTERS, ALL | D19 PDF (pages 61–67 for study) |
| Time intelligence, SUMX, row context, context transition, VAR | D20 PDF (pages 8–44) |
| Calculated tables, visual calculations, semi-additive, calculation groups, statistics, quick measures | D20 PDF (pages 63–76), D20 Lab 06 |
| Performance Analyzer and DAX query view | Study guide pages 82–87; D20 Lab 06, Step 5 |
| Weekly snapshots and closing stock | Study guide pages 55–60; D20 Lab 06, Step 6 |

Microsoft Learn: [Model data with Power BI](https://learn.microsoft.com/en-us/training/paths/model-data-power-bi/) · [Create DAX calculations](https://learn.microsoft.com/en-us/training/modules/dax-power-bi-create-calculations/) · [PL-300 practice assessment](https://learn.microsoft.com/en-us/credentials/certifications/data-analyst-associate/practice/assessment?assessment-type=practice&assessmentId=46)
