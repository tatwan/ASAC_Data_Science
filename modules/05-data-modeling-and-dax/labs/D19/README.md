# D19: DAX measures, filter context and CALCULATE

You will write your first DAX measures on Nakheel's star and check each one against a number you already have from SQL: total revenue, orders, customers and average order value. Then you will see why one measure shows a different number in a card, a table and under a slicer (filter context), change that with `CALCULATE`, and finish with each category's share of the total. In class your instructor shows each activity and you follow; anything you do not finish, you finish from the README.

**D19 starts with a new, blank Power BI file.** You need nothing from D18: the four start files below are D18's finished tables.

## Get the files

The four start files, in [`Resources/start/`](Resources/start/): [sales_lines.csv](Resources/start/sales_lines.csv), [customers.csv](Resources/start/customers.csv), [products.csv](Resources/start/products.csv), [dates.csv](Resources/start/dates.csv). On GitHub, open each file and click **Download raw file**; keep the four in one folder. [`Resources/README.md`](Resources/README.md) describes their columns.

## The activities and labs

| | What you build | Start from |
|---|---|---|
| [Activity 01: load the four start files and relate the tables](01-Evr-Load-And-Relate-Start-Files/README.md) | the star: four tables, four relationships | a new file |
| [Activity 02: write the base measures and check them against SQL](02-Evr-Base-Measures/README.md) | Total Revenue, Orders, Customers, Average Order Value | 01 |
| [Activity 03: one measure in a card, a table and under slicers, then CALCULATE](03-Evr-Filter-Context-And-Calculate/README.md) | two tables, two slicers; Completed Revenue | 02 |
| [Lab 04: percent of total by category, checked against SQL](04-Lab-Percent-Of-Total/README.md) | All Categories Revenue, % of Total | 03 |
| [Lab 05 (optional, PL-300): each product's share of its category](05-Lab-Optional-Share-Of-Category/README.md) | % of Category | 04 |

## Desktop and the web

> **In Desktop:** open a new file and save it at once as `D19-measures.pbix`; save after each activity. Keep the folder with the CSV files: the report reads them when you refresh. A new measure: select `sales_lines` in the **Data** pane → **Home** → **New measure**.
> **On the web:** start from **+ New Report** → **Get data** → **Text/CSV** → **Upload file**, add the other three files inside the same Power Query editor, and save the semantic model as `D19-nakheel` in **My workspace**. Relationships and measures: **Open semantic model** → **Editing** → select `sales_lines` → **New measure** in the ribbon. Changes on the web are saved at once and cannot be undone. If a step is missing on your screen, pair with a classmate on Desktop.

## Writing a measure

- Type the measure's name, an equals sign, then the formula: `Total Revenue = SUM(sales_lines[line_value])`. Press **Enter**.
- Let autocomplete fill table and column names: type `sales` and pick `sales_lines[line_value]` from the list.
- A measure used inside another measure is written in square brackets with no table name: `[Total Revenue]`.
- DAX text goes in double quotes: `"completed"`.

## Check rows and totals

- **Row counts:** **Table view** (the second icon on the left) → select a table: the status bar shows its rows. Today: `sales_lines` 7,516 · `customers` 500 · `products` 60 · `dates` 1,096.
- **The whole value on a card:** a **Card** shows `340.37K`. **Format visual** → **Visual** → **Callout value** → **Display units** → **None** (some versions say **Callout values**).
- **The SQL answers** you check against: 340,370.00 every line; 316,023.50 completed (D16); 2,771 completed orders (D07); 452 buying customers (D09); 114.05 average order (D04).

## Where the data comes from

Nakheel Retail, synthetic course data generated 24 September 2026 ([`shared/datasets/nakheel`](../../../../shared/datasets/nakheel/README.md)); the start files are D18's tables written from it on 4 November 2026. Menu names are Power BI's in November 2026; if a name differs on your screen, look in the same tab or menu.
