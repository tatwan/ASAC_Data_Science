# Lab 04 · Build Nakheel's first overview page, then give it a theme

**The ask.** Nakheel's manager wants one page that answers three questions at a glance:

1. How big was the business? (revenue, orders, average order value)
2. How did revenue move month by month, and which category earned the most?
3. Which months grew compared with the same month last year?

You will build that page with four kinds of visual: **cards**, a **line chart**, a **bar chart** and a **donut chart**, plus a table with colour on the growth column. Then you will apply a **report theme** and watch every visual change colour at once.

**What you need.** The model from [D20 Activity 01](../../../../05-data-modeling-and-dax/labs/D20/01-Evr-Load-Start-Files-And-Measures/README.md) with Revenue LY and YoY % from [Activity 02](../../../../05-data-modeling-and-dax/labs/D20/02-Evr-Time-Intelligence/README.md), and the theme file [nakheel-theme.json](../Resources/nakheel-theme.json) (right-click → save it to your computer).

| Step | What you do | Check |
|---|---|---|
| 1 | Limit the page to completed sales through August 2026 | The page shows no month after 2026-08 |
| 2 | Add three cards | 316,023.50 · 2,771 · 114.05 |
| 3 | Add a line chart, a bar chart and a donut | April 20,237.00 · Outerwear 76,637.00 · store about 65% |
| 4 | Import the theme and compare before and after | The bars and donut change colour |
| 5 | Colour the YoY % column | April +58.2% sits on a green cell |

## 1. Set the page scope

**What and why.** A page filter applies to every visual on the page. You want every number on this page to describe the same thing: **completed** orders up to **31 August 2026**, the last day in the data. Without the status filter, the order card would also count cancelled and pending orders and show 3,000 instead of 2,771.

**How.**

1. Add a new report page and rename it **Overview** (double-click the page tab).
2. Click an empty part of the canvas so no visual is selected. Open the **Filters** pane on the right.
3. Drag `sales_lines[status]` into **Filters on this page** and tick **completed**.
4. Drag `dates[date]` into **Filters on this page**. Choose **Advanced filtering**, set **is on or before** `8/31/2026` (or `31/08/2026` if your computer uses day-first dates), then **Apply filter**.

**C1.** Both filters are listed under **Filters on this page**. Every visual you add from now on uses them.

## 2. Add three cards

**What and why.** A card shows one number in large type. Readers look at the top-left of a page first, so put the three "size of the business" figures there.

**How.**

1. Select **Card** in the Visualizations pane and drag **Completed Revenue** into **Fields**.
2. Add a second card with **Orders**, and a third with **Average Order Value**.
3. Rename the last two so a reader knows they also count completed orders only: in the **Fields** well, double-click the field name (or use its drop-down → **Rename for this visual**) and type **Completed orders** and **Completed average order value**.
4. For each card, open **Format visual → Callout value** and set **Display units** to **None**. Set **Value decimal places** to 2 for the two money cards and 0 for the order card.
5. Place the three cards in a row along the top of the page.

**C2.** The cards show **316,023.50**, **2,771** and **114.05**. If Orders shows 3,000, the status filter from Step 1 is missing.

## 3. Add a line chart, a bar chart and a donut

**What and why.** Each chart type answers a different kind of question:

| Chart | Answers | Why this shape |
|---|---|---|
| Line | How did revenue change month by month? | A line joins the months in order, so the eye follows the trend |
| Bar | Which category earned the most? | Bars side by side make lengths easy to compare and rank |
| Donut | What share of revenue came from each channel? | Two parts of one whole; use a donut only when there are very few parts |

**How: the line chart.**

1. Add a **Line chart**. Put `dates[year_month]` on the **X-axis** and **Completed Revenue** on the **Y-axis**.
2. Sort it by month: open the visual's **…** menu → **Sort axis** → **year_month**, then **Sort ascending**. Without this, Power BI may sort the months by revenue, and the line would no longer be a timeline.
3. Hover over **2026-04**.

**How: the bar chart.**

4. Add a **Clustered bar chart**. Put `products[category]` on the **Y-axis** and **Completed Revenue** on the **X-axis**.
5. Sort it by revenue, largest first: **…** → **Sort axis** → **Completed Revenue**, **Sort descending**.

**How: the donut.**

6. Add a **Donut chart**. Put `sales_lines[channel]` in **Legend** and **Completed Revenue** in **Values**.
7. In **Format visual → Detail labels**, set **Label contents** to **Percent of total**.

**C3.** The line reads **20,237.00** at 2026-04. Outerwear is the top bar at **76,637.00**. The donut shows store at about **65%** and online at about **35%**; hover a slice to see 205,338.00 and 110,685.50.

Look at the colours now, before Step 4. They are Power BI's default theme. Take a screenshot if you want to compare.

## 4. Apply the Nakheel theme and see what it changes

**What a theme is.** A theme is a small JSON file of **default colours** for the whole report. Power BI reads it and recolours every visual that has not been coloured by hand. One file gives every page the same look, so you do not format 20 visuals one by one.

Open [nakheel-theme.json](../Resources/nakheel-theme.json) in any text editor. Each line sets one default:

| Key in the file | What it changes | Where you will see it on this page |
|---|---|---|
| `dataColors` | The colours given to data, in order: first series, second series, … | The bar colour (first colour) and the two donut slices (first and second colours) |
| `foreground` | Default text colour, including table values | Card numbers and table text |
| `background` | Background of labels, buttons and the filter pane | Subtle; mostly in tooltips and the filter pane |
| `tableAccent` | The grid line colour of tables and matrices | The table you add in Step 5 |
| `minimum`, `center`, `maximum` | The three default colours of a gradient in conditional formatting | The YoY % colours in Step 5 |
| `good`, `neutral`, `bad` | Status colours for KPI and waterfall visuals | Not used on this page |

**How.**

1. In Desktop, open the **View** ribbon. In the **Themes** group, open the drop-down arrow and choose **Browse for themes**. (Newer builds may show a **Design** ribbon with **Import theme**; use that if you see it.)
2. Select `nakheel-theme.json` and confirm the message that the theme was imported.
3. On the web, open the report in **Edit**, then **View → Theme**, and use **Import** in the Theme pane. If your account offers no import, skip to Step 5; the checks there still work with default colours.

**C4.** The bars turn indigo (`#3B4AE0`), and the donut slices turn indigo and teal (`#0F766E`). The numbers did not change: a theme changes how things look, never what they calculate.

**If a colour did not change.** You probably coloured that visual by hand earlier. Manual formatting wins over the theme. Open the visual's **Format** pane and choose **Reset to default** on the colour setting.

## 5. Colour the YoY % column

**What and why.** A table of 24 percentages is hard to scan. Colour lets the reader find the good and bad months first, then read the exact number. You will use a **gradient**: red for falls, white for no change, green for growth. Its three default colours come from the theme's `minimum`, `center` and `maximum`.

**How.**

1. Add a **Table** with `dates[year_month]`, **Completed Revenue**, **Revenue LY** and **YoY %**.
2. In the **Columns** well, open the drop-down on **YoY %** → **Conditional formatting** → **Background color**.
3. Set **Format style** to **Gradient** and tick **Add a middle color**.
4. Set **Minimum** to **Lowest value**, **Center** to **Number** with value `0`, and **Maximum** to **Highest value**. Check that the colours are red, white and green (from the theme), then **OK**.

**Check yourself.** April 2026 shows **+58.2%** on a green cell (Power BI may drop the plus sign). Months that fell are red. Months from 2024-09 to 2025-08 show no YoY % at all: the data starts in September 2024, so there is no "last year" to compare with, and DIVIDE returns blank. No row after 2026-08 appears, because of the page filter.

Save the file. You will use this page in D21.

**What just happened.** You built the page in the order a reader uses it: the size of the business first, then trend and comparison, then where to look closer. The theme set the colours once for all of it, including the gradient you used last.

[Microsoft: report themes](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-report-themes) · [Microsoft: theme JSON colours](https://learn.microsoft.com/en-us/power-bi/create-reports/report-themes-create-custom) · [Microsoft: table conditional formatting](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-conditional-table-formatting)
