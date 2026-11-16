# Activity 06 · Count rows, a Top N filter, a second data label and a single-select slicer

**The ask.** Assignment 3 uses four steps we have not made in class yet. You make each one here, on the Nakheel model
you know, so that in the assignment you only repeat them on the taxi data. You will:

1. count rows in Power Query **without removing them**,
2. keep only the **Top 5** in a chart (a **Top N** filter),
3. show a **second number** on each bar (a data label **detail**),
4. make a slicer **single select** (last, because a single-select slicer always keeps one item chosen).

**Start from** your D21 file with the channel slicer from [Activity 02](../02-Evr-Slicers-Sync-Interactions/README.md),
or the file described on the [D21 entry page](../README.md). With no channel chosen, a card with Completed Revenue
shows **316,023.50**.

| Step | What you do | Check |
|---|---|---|
| 1 | Count two kinds of rows, keep them | 565 empty delivery dates · 525 cancelled lines · 7,516 rows kept |
| 2 | A Top 5 products chart | Denim jacket first, 12,818.00 · online: Running shoe first, 6,596.00 |
| 3 | Shares as a second data label | Outerwear 76,637.00 and 24.3% |
| 4 | Make the channel slicer single select | online 110,685.50 or store 205,338.00, never both |

## 1. Count rows without removing them

**What and why.** Some odd rows are real, and removing them would hide something true. A cancelled order line is
still a line the shop handled; an empty delivery date means the order has not arrived yet. You often need to **know
how many** there are (for a note, or a slide) and still keep them. In Assignment 3 you count 0-mile taxi trips this
way.

**How.**

1. **Home → Transform data.** Select the `sales_lines` query.
2. At the bottom left, change **Column profiling based on top 1000 rows** to **entire data set**. Turn on
   **View → Column profile**.
3. Select `delivered_date`. In **Column statistics**, read **Empty**.
4. To count a value, filter for it: select the arrow on `status`, tick only **cancelled**, **OK**. Select any column
   and read **Count** in its statistics.
5. In **Applied steps**, select the **X** beside the filter step you just made. The step is gone and so is the filter.

**C1.** `delivered_date` has **565** empty values. The filter shows **525** cancelled lines. After you delete the
step, `sales_lines` has **7,516** rows again. For a numeric column, the same statistics also have a **Zero** line:
that is how you count 0-mile trips in the assignment.

**On the web.** If your editor shows no column statistics, count after loading instead, on a new page with no
page filters: drag `order_id` into a card and set it to **Count** (select the arrow beside the field in the well; not
Sum, not Count (Distinct)). The card reads 7,516. Drag `status` into **Filters on this visual** and tick
**cancelled**: 525. Remove that filter, then drag `delivered_date` in and tick **(Blank)**: 565. Then delete the page.

## 2. Keep only the Top 5 products

**What and why.** Sixty products in one chart is a wall of bars. Most readers want the few that matter. A **Top N**
filter keeps the N largest items **by a measure you choose**, and it is recalculated whenever a slicer changes, so
the Top 5 of online is not the Top 5 of all sales.

**How.**

1. Add a **Clustered bar chart**: `products[product_name]` on the **Y-axis**, **Completed Revenue** on the **X-axis**.
2. With the chart selected, open the **Filters** pane. Under **Filters on this visual**, expand `product_name`.
3. Set **Filter type** to **Top N**. **Show items: Top**, type **5**.
4. Drag **Completed Revenue** into **By value**. Select **Apply filter**.
5. Sort the bars: **More options (…) → Sort axis → Completed Revenue**, descending.

**C2.** With no channel chosen, five bars, **Denim jacket**
first with **12,818.00** and **Wool overcoat** fifth with **10,320.00**. Click **online** on the slicer: the list
changes, and **Running shoe** is first with **6,596.00**. Click **online** again to clear it.

## 3. Show each category's share as a second data label

**What and why.** A bar's length shows the amount; the reader often also wants its **share** of the total. A data
label **detail** puts a second number under the first, so the bar can show both without a second chart. In the
assignment, the borough chart shows trips and the share of trips this way.

**How.**

1. Make a share measure (D19 Lab 04):

   ```text
   % of Revenue =
   DIVIDE ( [Completed Revenue], CALCULATE ( [Completed Revenue], REMOVEFILTERS ( products ) ) )
   ```

   Then **Measure tools → Format → Percentage**, with **1** decimal.
2. Select the category bar chart from D20 Lab 04 (`products[category]`, **Completed Revenue**). If your file has none,
   add a **Clustered bar chart** with `products[category]` on the **Y-axis** and **Completed Revenue** on the **X-axis**.
3. **Format visual** (the paintbrush) **→ Visual → Data labels**: turn it on.
4. Inside **Data labels**, expand **Detail**, turn it on, and choose **% of Revenue** as its data.

**C3.** With no channel chosen, the Outerwear bar reads **76,637.00** and under it **24.3%**; Shoes reads
**62,373.50** and **19.7%**. If your version has no **Detail** setting, put **% of Revenue** in the chart's
**Tooltips** box instead and hover the bar.

## 4. Make the channel slicer single select

**What and why.** Some measures only make sense for one item at a time. A "change on last year" card with **both**
years chosen compares two years with one, and shows a number that means nothing. **Single select** makes the reader
choose exactly one.

**How.**

1. Select the channel slicer from Activity 02.
2. **Format visual → Visual → Slicer settings → Selection**: turn on **Single select**.
3. Click **online**, then **store**. Try to choose both with Ctrl+click.
4. Leave one channel chosen before you save, so the page opens on it.

**C4.** The card reads **110,685.50** for online and **205,338.00** for store. You cannot choose both: a click on
the other button moves the choice.

## What you can now do in Assignment 3

| Here | In Assignment 3 |
|---|---|
| 1. Count, then delete the filter step | Part 1.6: 0-mile trips, 0 passengers, Unknown zones (Help H1) |
| 2. Top N by a measure | The page 2 table and dropoff chart, the page 3 zones (Help H2) |
| 3. Data label detail | The page 2 borough chart with `% of Trips` (Help H3) |
| 4. Single select | The year slicers on pages 1 and 2 (Help H4) |
