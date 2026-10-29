# Lab 11 · Power Query, a first clean

In this self-guided lab, you will finish cleaning Nakheel's customers in Power Query, add an order-size column with a conditional column (Power Query's `CASE`), and draw revenue month by month, checking every number against SQL.

**When:** after class, at your own pace. Not submitted. · **Data:** `customers.csv` and `orders.csv` from [`shared/datasets/nakheel`](../../../../../shared/datasets/nakheel/README.md) · **Start from:** your `D16-nakheel-first-report` from [activity 10](../10-Evr-PowerBI-End-To-End/README.md)

## The story

In class you cleaned `segment` and matched the completed revenue. A manager's next questions are where the customers live, whether big orders or small orders bring in the money, and how revenue moved month by month. Each needs one more Power Query step or one more chart, and each has a SQL answer you can check it against.

## What you will learn

- To clean a city column with **Trim**, **Capitalize Each Word** and **Replace Values**, and to decide what an empty value should become.
- To add a **Conditional Column**, the Power Query version of `CASE WHEN … THEN … END`.
- To draw a line chart over dates and read its highest and lowest month.

## How to read the steps

As in activity 10, the steps are written for **Power BI Desktop**, and a box marked **In the browser** gives the browser steps where they differ. Every step ends with **What you should see**; do not go on until your screen matches it.

## Checkpoints

- **C1:** `customers` and `orders` loaded; a card showing 316,023.50 with `status` = completed.
- **C2:** `city` cleaned to eight cities and `Unknown`: Amman 196, Zarqa 67, Unknown 6.
- **C3:** an `order_size` column on `orders` and charts of completed orders by size; a line chart of completed revenue by month.

## Before you start (C1)

1. Open your report from activity 10:
    - **Desktop:** in your folder, double-click `D16-nakheel-first-report.pbix`. It opens in Power BI Desktop.
    - **In the browser:** go to `app.powerbi.com` → **My workspace**, click the report `D16-nakheel-first-report`, then click **Edit** in the bar at the top.
2. Check the card: it shows **316,023.50** with the filter `status` is completed.

If you have no report from activity 10, do [activity 10](../10-Evr-PowerBI-End-To-End/README.md) steps 1 to 6 first.

**What you should see:** your report with the bar chart, the card at 316,023.50 and the column chart by channel. The **Data** pane lists `customers` and `orders`.

## Step 1 · Open Power Query and profile city (C2)

1. On the **Home** tab, click **Transform data** (the top half of the button). The Power Query Editor opens.

    > **In the browser**
    >
    > 1. Go back to **My workspace**. Find the semantic model `D16-nakheel` (its type says **Semantic model**).
    > 2. Click **More options (...)** beside it → **Open semantic model**. The model opens in a new tab.
    > 3. At the top right, switch the mode from **Viewing** to **Editing**.
    > 4. On the **Home** ribbon, click **Transform data**. Power Query opens.
    >
    > Power Query in the browser does not save as you go. When you finish step 3, save and apply your changes with the button at the bottom right of Power Query. If you click **Cancel** or close the window, Microsoft's page warns that "any changes made to queries will be discarded."

2. In **Queries** on the left, click `customers`.
3. In **Applied steps** on the right, check that the last step, **Capitalized Each Word**, is selected.
4. Check that the profiling options from activity 10 are still on: **View** → **Column quality**, **Column distribution**, **Column profile** (in the browser, **View** → **Data view**). Check that the status bar at the bottom left says **Column profiling based on entire data set**; if it says top 1000 rows, click it and change it.
5. Click the `city` column header.
6. Read the three lines under the header, then hover over each bar in **Value distribution** at the bottom.

**What you should see:**

- **Column quality** shows a small **Empty** share, about 1%: six customers have no city.
- **Column distribution** shows **11 distinct**: ten spellings, plus the empty value, which Power Query counts as one more value.
- **Value distribution** shows Amman 191, Irbid 113, Zarqa 60, Aqaba 39, Salt 26, Madaba 22, Karak 19, Mafraq 12, **Al Zarqa 7**, the empty value 6 and **amman 5**.

Two problems besides the empty cells: `amman` in lower case (5 customers), and `Al Zarqa` (7) used for the same city as `Zarqa` (60).

**Think:** is an empty city an error to fix, or a fact to keep? What would the manager want to see on a chart?

## Step 2 · Clean city (C2)

1. With the `city` column selected, click **Transform** → **Format** → **Trim**.
2. With `city` still selected, click **Transform** → **Format** → **Capitalize Each Word**.

    **Check:** `amman` has joined `Amman`: hovering over the first bar shows **Amman 196**.

3. Right-click the `city` header → **Replace Values**. A small window opens.
    1. **Value To Find:** `Al Zarqa`
    2. **Replace With:** `Zarqa`
    3. Click **Advanced options** and tick **Match entire cell contents**.
    4. Click **OK**.

    **Check:** the `Al Zarqa` bar has gone and **Zarqa** reads **67**.

4. Right-click the `city` header → **Replace Values** again.
    1. Leave **Value To Find** empty.
    2. **Replace With:** `Unknown`
    3. Click **Advanced options** and tick **Match entire cell contents**.
    4. Click **OK**.

    **Check:** a new bar, **Unknown 6**, and the **Empty** share under the header is 0%.

5. In **Applied steps**, right-click the last step (**Replaced Value1**) → **Rename**, type `City cleaned` and press **Enter**.

Why **Match entire cell contents**: for a text column, **Replace Values** on its own replaces a piece of text wherever it appears inside a cell. Ticking the box makes it replace only cells whose whole value matches, which is what you want here, and it is the only way an empty **Value To Find** means "an empty cell".

The same in SQL, for comparison:

```sql
SELECT CASE
         WHEN city IS NULL OR TRIM(city) = '' THEN 'Unknown'
         WHEN INITCAP(TRIM(city)) = 'Al Zarqa' THEN 'Zarqa'
         ELSE INITCAP(TRIM(city))
       END AS city_clean,
       COUNT(*) AS customer_count
FROM nakheel.customers
GROUP BY city_clean
ORDER BY customer_count DESC;
```

**What you should see:** `city` shows **9 distinct**: Amman 196, Irbid 113, Zarqa 67, Aqaba 39, Salt 26, Madaba 22, Karak 19, Mafraq 12, Unknown 6 (500 in all). **Applied steps** gained four steps: **Trimmed Text1**, **Capitalized Each Word1**, **Replaced Value** and **City cleaned**. (Power Query adds the `1` because `segment` already used those names.)

## Step 3 · Order size, a conditional column (C3)

1. In **Queries**, click `orders`.
2. Look at the `order_total` header. The icon at its left should read **1.2** (decimal number). If it reads **ABC** (text), click the icon and choose **Decimal number** before going on: the rules below compare numbers.
3. Click the **Add Column** tab → **Conditional Column**. A window opens.
4. **New column name:** `order_size`.
5. Fill in the first row (**If**):
    - **Column name:** `order_total`
    - **Operator:** `is less than`
    - **Value:** `50`
    - **Output:** `small`
6. Click **Add Clause**. A second row (**Else If**) appears. Fill it in:
    - **Column name:** `order_total`
    - **Operator:** `is less than`
    - **Value:** `150`
    - **Output:** `medium`
7. In **Else** at the bottom, type `large`.
8. Click **OK**.
9. The new `order_size` column has the icon **ABC123** (any type). Click that icon and choose **Text**.

| | Column name | Operator | Value | Output |
|---|---|---|---|---|
| If | `order_total` | is less than | 50 | `small` |
| Else If | `order_total` | is less than | 150 | `medium` |
| Else | | | | `large` |

The rules are read top to bottom, and the first one that is true wins, exactly like `CASE WHEN order_total < 50 THEN 'small' WHEN order_total < 150 THEN 'medium' ELSE 'large' END`. An order of exactly 50.00 is `medium`; one of exactly 150.00 is `large`.

10. **Home** → **Close & Apply**.

    > **In the browser:** save and apply your changes with the button at the bottom right of Power Query. Then go back to **My workspace**, open the report `D16-nakheel-first-report` and click **Edit**.

**What you should see:** in the **Data** pane, `orders` now has an `order_size` field.

## Step 4 · Which orders bring in the money? (C3)

To keep step 5 clear, put these charts on a new page: click the **+** at the bottom of the report to add a page.

1. Click an empty spot on the page. **Visualizations** → **Build visual** → **Clustered column chart**.
2. From `orders`, drag `order_size` into **X-axis** and `order_total` into **Y-axis** (**Sum of order_total**).
3. With the chart selected, drag `status` into **Filters on this visual** and tick **completed** only.
4. Click an empty spot on the page. Add a second **Clustered column chart**.
5. Drag `order_size` into **X-axis** and `order_id` into **Y-axis**. Because `order_id` is a whole number, Power BI adds the IDs up: the box says **Sum of order_id**, which means nothing.
6. In the **Y-axis** box, click the arrow beside **Sum of order_id** and choose **Count**. The box now says **Count of order_id**: the number of orders.
7. Add the same `status` = completed filter to this chart.
8. Hover over each column in both charts to read the exact values.

**What you should see** (completed orders; the columns are sorted from largest to smallest):

| order_size | Orders | Revenue |
|---|---:|---:|
| small | 1,112 | 31,548.00 |
| medium | 1,183 | 101,835.00 |
| large | 476 | 182,640.50 |
| **Total** | **2,771** | **316,023.50** |

The large orders are about one in six orders and well over half the revenue.

## Step 5 · Revenue by month (C3)

1. Click an empty spot on the page. **Visualizations** → **Build visual** → **Line chart**.
2. From `orders`, drag `order_date` into **X-axis**. Power BI builds a date hierarchy: under `order_date` in the **X-axis** box you see **Year**, **Quarter**, **Month** and **Day**.
3. Remove **Quarter** and **Day**: click the **X** beside each in the **X-axis** box. **Year** and **Month** stay.
4. Drag `order_total` into **Y-axis** (**Sum of order_total**).
5. Add the `status` = completed filter to this chart.
6. The chart now shows three points, one per year. Hover over the chart: icons appear above it. Click **Expand all down one level in the hierarchy** (the forked arrow pointing down). The chart now shows one point for every month of every year.
7. Hover over the highest and the lowest points to read their months and values.

Do not remove **Year** as well: with **Month** alone, Power BI adds up each month across the years and draws 12 points, not 24.

**If there is no Year, Quarter, Month, Day under `order_date`** (Power BI's automatic date hierarchy is switched off on your file):

- **Desktop:** **File** → **Options and settings** → **Options** → under **Current file**, **Data Load** → tick **Auto date/time** → **OK**. Then start this step again.
- **In the browser, or if you prefer:** open Power Query, select `orders`, click the `order_date` header → **Add Column** → **Date** → **Month** → **Start of Month**. Apply the change (step 3, item 10), then put the new **Start of Month** field on the **X-axis** in place of `order_date`. Each point is then the first day of a month.

**What you should see:** 24 months from September 2024 to August 2026. The highest is **April 2026 (20,237.00)**, the lowest **November 2025 (9,772.50)**.

The SQL to check the highest month:

```sql
SELECT FORMAT_DATE('%Y-%m', order_date) AS order_month,
       SUM(order_total) AS revenue
FROM nakheel.orders
WHERE status = 'completed'
GROUP BY order_month
ORDER BY revenue DESC
LIMIT 1;
```

Change `DESC` to `ASC` to check the lowest.

Save your work: **File** → **Save** (Desktop and browser).

## Check yourself

| Step | One value to check |
|---|---|
| Before you start | card: 316,023.50 |
| 1 | `city`: 11 distinct (ten spellings and the empty value) · 6 empty |
| 2 | `city`: 9 distinct · Amman 196 · Zarqa 67 · Unknown 6 |
| 4 | large: 476 orders · 182,640.50 |
| 5 | April 2026: 20,237.00 · November 2025: 9,772.50 |

## If something goes wrong

| What you see | Why | What to do |
|---|---|---|
| Zarqa still reads 60 and Al Zarqa 7 | The replace ran before **Capitalize Each Word**, or **Value To Find** has a typing error | Click the **Replaced Value** step's gear icon in **Applied steps**, check the text, click **OK** |
| The empty replace changed nothing | **Match entire cell contents** was not ticked, or the empty cells are `null` | See the hint below |
| There are no `small` orders | The rules are in the wrong order: `< 150` comes first, so it catches every small order too | Click the gear icon beside **Added Conditional Column** in **Applied steps** and put `< 50` first |
| The conditional column window will not accept `50` | `order_total` is text | Step 3, item 2 |
| The second chart says **Sum of order_id** | The default for a number field | Step 4, item 6 |
| Revenue by size adds up to more than 316,023.50 | A chart has no `status` filter | Add it to that chart |
| The line chart has 12 points | **Year** was removed from the **X-axis** box | Drag `order_date` in again and remove only **Quarter** and **Day** |

## Hint

If **Replace Values** with an empty **Value To Find** changes nothing, the empty cells may be `null` rather than empty text. Run **Replace Values** again with **Value To Find** set to the word `null`, **Match entire cell contents** ticked, and **Replace With** `Unknown`. To see which kind you have, click the drop-down arrow on the `city` header: an empty-text value appears in the list as an empty line, a missing one as `(null)`.

## Bonus

**More practice, not checked:** add a conditional column `segment_code` on `customers` (Retail → R, Wholesale → W), then try **Add Column** → **Column From Examples**: type `Amman (R)` in the first row and let Power Query work out the rule. Open **Home** → **Advanced Editor** and read the M code your clicks wrote.

## References

Nakheel Retail, synthetic course data; see [`shared/datasets/nakheel`](../../../../../shared/datasets/nakheel/README.md). Microsoft: [Add a conditional column](https://learn.microsoft.com/en-us/power-query/add-conditional-column), [Replace values](https://learn.microsoft.com/en-us/power-query/replace-values), [Data profiling tools](https://learn.microsoft.com/en-us/power-query/data-profiling-tools), [Edit semantic models in the Power BI service](https://learn.microsoft.com/en-us/power-bi/transform-model/service-edit-data-models), and the Microsoft Learn module [Clean, transform, and load data in Power BI](https://learn.microsoft.com/en-us/training/modules/clean-data-power-bi/).
