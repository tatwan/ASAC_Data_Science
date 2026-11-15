# Optional Lab 05 · Two new chart types: a histogram and a scatter plot

## The ask

Lab 04's overview shows **totals**: revenue by month, by category, by channel. A manager reading it asks two new questions that totals cannot answer:

1. **"What does a typical sale look like? Are most sales lines small, or big?"** A total of 316,023.50 hides whether that came from many small lines or a few large ones.
2. **"Do our cheaper products sell more units than the expensive ones?"** This compares two numbers for each product: its price and how many units sold.

You will answer each question with a chart built for it, on one new page, then write three short answers.

| Question | Chart | What one mark on the chart means |
|---|---|---|
| What does a typical sale look like? | **Histogram** | One bar = how many sales lines fall in an amount range (for example 10 to under 20) |
| Do cheaper products sell more units? | **Scatter plot** | One dot = one product, placed by its price (across) and units sold (up) |

**What you hand in.** Nothing; this lab is optional practice. You are done when your page has both charts, the three checks match and you can answer the three questions in Step 5.

## Before you start

1. Open the D20 file you used for [Lab 04](../04-Lab-Overview-Page/README.md). If you do not have one, build the model in [D20 Activity 01](../../../../05-data-modeling-and-dax/labs/D20/01-Evr-Load-Start-Files-And-Measures/README.md) first.
2. Add a **new blank page** and name it **Distribution and price**. You do not need anything from the overview page.
3. Add two **page filters** (Filters pane → **Filters on this page**): `sales_lines[status]` = **completed**, and `dates[date]` on or before **31 August 2026**. These are the same filters as Lab 04, Step 1.

| Step | What you do | Check |
|---|---|---|
| 1 | Learn what a bin is | 18.00 goes in the 10 to under 20 bin |
| 2 | Group the line amounts into bins | A bins field exists in `sales_lines` |
| 3 | Build the histogram | The 10 bar counts 2,142 lines |
| 4 | Build the scatter plot | Water bottle sits at price 5.50, 608 units |
| 5 | Read both charts | Three short answers |

## 1. Learn what a bin is

**What and why.** `sales_lines[line_value]` holds the amount of each sales line: 5.00, 18.00, 24.00, 48.00 and so on, 235 different values. A chart with one bar per exact amount would be unreadable. So you group nearby amounts into ranges called **bins**, and count how many lines fall in each. A chart of those counts is a **histogram**. It shows the **distribution**: which amounts are common and which are rare.

With bins 10 wide, starting at zero:

| Bin label | Amounts in this bin | Example from order 100003 |
|---|---|---|
| 0 | 0 up to, but not including, 10 | Kids T-shirt, 5.00 |
| 10 | 10 up to, but not including, 20 | Kids football boots, 18.00 |
| 20 | 20 up to, but not including, 30 | Fleece jacket, 24.00 |

The label is the **start** of the range. An amount of exactly 20.00 goes in bin 20, not bin 10.

**C1.** You can say why 18.00 goes in bin 10 and 24.00 does not.

**One thing to notice.** This histogram counts **sales lines**, not orders. Order 100003 has three lines, so it adds three to the counts (one in each bin above). A histogram of **order** totals would answer a different question and would need one total per order first.

## 2. Group the line amounts into bins

**What and why.** Power BI needs a new field that holds each line's bin (0, 10, 20, …) so the chart can use it on its axis. You can make it with Power BI's grouping dialog, or with one line of DAX. Use **one** of the two routes.

**How: route A, the grouping dialog (Desktop).**

1. In the **Data** pane, right-click `sales_lines[line_value]` → **New group**.
2. Set **Group type** to **Bin**, **Bin type** to **Size of bins**, and **Bin size** to `10`. Click **OK**.
3. A new field, **line_value (bins)**, appears in `sales_lines`.

**How: route B, a calculated column (Desktop or web).** Use this if you have no **New group** option.

1. Select `sales_lines` and choose **New column** (on the web, open the semantic model in **Editing** mode first).
2. Enter:

   ```dax
   Line band start = 10 * INT(sales_lines[line_value] / 10)
   ```

**How the formula works,** for a line worth 18.00:

- `sales_lines[line_value] / 10` gives 1.8.
- `INT(...)` rounds down to a whole number: 1.
- `10 * ...` gives 10, the start of the bin.

A calculated column runs this once for every row of `sales_lines`, as DAX Line Value did in Activity 03.

**C2.** The bins field (**line_value (bins)** or **Line band start**) is in `sales_lines`. In Table view, the 18.00 lines show 10.

## 3. Build the histogram

**What and why.** The bins go across the bottom. Up the side goes **how many lines** are in each bin. That needs a count, not a sum: summing `line_value` would show revenue per bin, which is a different chart.

**How.**

1. Create a measure in `sales_lines`:

   ```dax
   Sales Line Count = COUNTROWS(sales_lines)
   ```

   `COUNTROWS` counts the rows of a table that survive the current filters. Under a bin of 10, it counts the completed lines whose amount is 10 to under 20.

2. Add a **Clustered column chart**. Put your bins field on the **X-axis** and **Sales Line Count** on the **Y-axis**.
3. In **Format visual → X-axis**, set **Type** to **Categorical**, so each bin is its own bar.
4. Sort by the bins field, ascending: **…** → **Sort axis** → your bins field → **Sort ascending**.
5. Title the chart **Completed sales lines by amount (bins of 10)**. Name the axes **Line amount, bin start** and **Number of sales lines**.

**C3.** Hover the first three bars:

| Bin | Completed sales lines |
|---|---:|
| 0 | 936 |
| 10 | 2,142 |
| 20 | 1,265 |

The tallest bar is bin 10. The chart has a long tail to the right: a few lines are worth several hundred or over a thousand (bulk orders), but about 6 lines in 10 are under 30.

## 4. Build the scatter plot

**What and why.** A histogram looks at **one** number. A scatter plot compares **two** numbers for the same things. Here the things are products. Each product becomes one dot: across is its list price, up is how many units it sold.

**How.**

1. Create a measure in `sales_lines`:

   ```dax
   Units Sold = COALESCE(SUM(sales_lines[qty]), 0)
   ```

   - `SUM(sales_lines[qty])` adds the quantities of the lines in the current filter, here one product's completed lines.
   - `COALESCE(x, 0)` returns `x`, or 0 when `x` is blank. Four products have no completed sales; without COALESCE they would have no dot at all.

2. Add a **Scatter chart** and fill its wells:

   | Well | Field | Why |
   |---|---|---|
   | **Values** (called **Details** in some versions) | `products[product_id]` | Makes one dot per product. Leave it out and you get a single dot for everything |
   | **X-axis** | `products[list_price]`, set to **Average** | The price. One product has one price, so its average is that price |
   | **Y-axis** | **Units Sold** | Units of that product sold |
   | **Tooltips** | `products[product_name]` | Shows the name when you hover |

   Leave **Size** and **Play axis** empty.

3. Title it **List price and completed units sold, by product**. Name the axes **List price** and **Units sold**.
4. Hover the **highest** dot on the chart, near the left edge. It is Water bottle.

**C4.** Water bottle shows **list price 5.50** and **608 units sold**.

There are 60 products, but you may count fewer dots: products with the same price and units sit on top of each other.

## 5. Read both charts

**What and why.** A chart is only useful when you can say what it shows, and what it does not. Write one or two sentences for each:

1. **Histogram.** What does the bar labelled 10 count? Is this a chart of sales lines or of orders?
2. **Scatter plot.** Where is Water bottle, and what does that position say? Can two products with the same price sell different numbers of units?
3. **A limit.** Does this scatter plot prove that lowering a price would increase sales?

**Check your answers.**

1. The bar counts **2,142 completed sales lines** with amounts from 10 up to, but not including, 20. It is a chart of lines; order 100003 alone added three of them.
2. Water bottle is one of the cheapest products (5.50) and sold the most units of any product (608). Yes: products with the same price can sit at very different heights.
3. No. Products differ in what they are, their category and who buys them, so cheap and popular going together is not proof that cutting a price causes more sales. List price is also not always the price charged on each line.

Save the file.

## If something does not match

- **Bin 10 is not 2,142.** Check the two page filters, and clear any selection in another visual. If route A's bins do not start at 0, use route B.
- **The histogram shows money.** You have `line_value` on the Y-axis. Use **Sales Line Count**.
- **The scatter has one dot.** `product_id` is missing from **Values** (or **Details**).
- **Water bottle is not 608.** Check the completed filter. Units Sold sums `qty`; it does not count lines.
- **Clicking a bar changes the scatter.** That is a cross-filter between visuals (D21 covers it). Click the bar again to clear it.

References: [Microsoft: grouping and binning](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-grouping-and-binning) · [Microsoft: scatter charts](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-scatter)
