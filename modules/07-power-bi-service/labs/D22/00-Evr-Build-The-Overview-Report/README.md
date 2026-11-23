# Activity 00 · Build the Nakheel overview report from one file

The Nakheel sales director wants one page that answers three questions: how much did we sell, which channel sold it, and is it growing? You build that page in Power BI Desktop from a single file, then use it for the rest of D22: you analyse it, publish it, pin it, secure it and plan its refresh. You do not need any file from an earlier day.

People often call a page like this a dashboard. In Power BI, a **dashboard** is something else: a page of tiles pinned from reports in the Service. You make one from this report in Activity 03.

| Step | What the director needs | Tool |
|---|---|---|
| 1 | The sales in Power BI | Get data → Text/CSV |
| 2 | One number for completed sales | New measure |
| 3 | The page: totals, channels, months and categories | Cards, line chart, bar chart, slicer |

**Data:** [Resources/start/sales_lines.csv](../Resources/start/sales_lines.csv) → table `sales_lines`. It is D20's `sales_lines` with the product's category, the customer's city and the month already added, so it needs no other table. One row is one line on an order: 7,516 rows, September 2024 to August 2026.

## 1. Load the file

**Why this step.** Today is about sharing a report, not modelling one. One table publishes, refreshes and takes a security role exactly as a four-table model does, and it loads in a minute.

Open a new file in Power BI Desktop. Select **Get data → Text/CSV**, choose `sales_lines.csv` and select **Load**. Save the file as `D22.pbix`.

In **Table view**, check the column types: `order_date` and `month_start` are **Date**, `line_value` is **Decimal number**, `year_month` is **Text**. Change any that are not.

**Check.** The table `sales_lines` has 7,516 rows: Table view shows the count at the bottom left, or put `order_id` on a card. **Count of order_id** shows **7516**. It counts rows, one per order line, not orders: an order with three products has three lines, so there are fewer orders (3,000).

![image-20261123143601731](images/image-20261123143601731.png)

## 2. Add two measures

**Why this step.** The file holds completed, cancelled and pending lines. The director counts completed sales only, and every card, chart and security role today reuses that one number.

Select **Home → New measure** and type the first measure. Repeat for the second.

```DAX
Total Revenue = SUM(sales_lines[line_value])
```

```DAX
Completed Revenue = CALCULATE([Total Revenue], sales_lines[status] = "completed")
```

**Check.** A card with Completed Revenue shows **316,023.50**. A card with Total Revenue shows 340,370.00: the difference is cancelled and pending lines.

## 3. Build the page

**Why this step.** Each visual answers one of the director's questions. Together they are the page you will publish in Activity 03.

Rename the page `Overview`. Add these five visuals. Give each card its own title (**Format → General → Title**): with the default title, all three cards say *Completed Revenue* and the reader cannot tell them apart.

| Visual | Fields | Title |
|---|---|---|
| Card | Completed Revenue | Completed revenue |
| Card | Completed Revenue, with `channel` = store in **Filters on this visual** | Store revenue |
| Card | Completed Revenue, with `channel` = online in **Filters on this visual** | Online revenue |
| Line chart | X-axis `month_start`, Y-axis Completed Revenue | Completed revenue by month |
| Clustered bar chart | Y-axis `category`, X-axis Completed Revenue | Completed revenue by category |

For the line chart: in the X-axis well, open the arrow on `month_start` and select **month_start** (not Date Hierarchy). 

![image-20261123144603608](images/image-20261123144603608.png)

Add a **Slicer** with `channel` at the side of the page.

**Check.**

| Visual | Value |
|---|---|
| Store revenue | 205,338.00 |
| Online revenue | 110,685.50 |
| Highest month on the line | April 2026, 20,237.00 |
| Longest bar | Outerwear, 76,637.00 |

![image-20261123145123244](images/image-20261123145123244.png)

If the first card shows **316,024**, Power BI rounded it for display (**Display units: Auto**). The value is still 316,023.50. To show the decimals, select the card, then **Format → Visual → Callout value** and set **Display units** to **None** and **Value decimal places** to **2**.

Select **online** in the slicer and predict each card before you look. The first card shows **110,685.50**, the line and bars shrink, the online card stays **110,685.50**, and the store card goes **blank**. Clear the slicer before the next step.

**What just happened.** Store and online add up to the first card: 205,338.00 + 110,685.50 = 316,023.50. A slicer and a visual filter both apply, and a row must pass both. The store card asks for channel = store *and* channel = online, which no row satisfies, so it is blank. That is the D21 rule on filter levels: each level narrows the rows the measure adds.

## What you built

| Page | Visual | Answers |
|---|---|---|
| Overview | Three cards | How much, and which channel |
| Overview | Line by month | When revenue rose and fell |
| Overview | Bars by category | What sells |

**If you already have a working D21 or D20 file**, you may use it instead: Completed Revenue on a card must show 316,023.50. The rest of D22 works on either file.

Next: [Activity 01](../01-Evr-Analytics-Pane-Lines/README.md) adds the Analytics pane to the monthly line; [Activity 02](../02-Evr-AI-Visuals/README.md) adds the AI visuals on a second page. [Activity 03](../03-Evr-Publish-Pin-Alert/README.md) publishes the report.
