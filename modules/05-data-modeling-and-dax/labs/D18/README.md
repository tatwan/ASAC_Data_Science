# D18: the model, a star of tables, relationships and a date table

You will turn Nakheel's four tables into one model: a fact table of order lines, `sales_lines`; a date table, `dates`; three relationships; a second date; and a tidy **Data** pane. In class your instructor shows each activity and you follow; anything you do not finish, you finish from the README.

**D18 starts with a new, blank Power BI file.** You need nothing from D17 or from Wednesday.

The model should let us ask the same revenue question by customer segment, product category or month. We first decide what one row represents (**grain**), so revenue is not counted twice. We then keep the sales amounts in a **fact table** and the fields we group by in **dimension tables**. Relationships let those grouping fields filter the sales. The charts check whether that filtering gives the answers we expect.

## Get the files

- **Nakheel's four tables**, the files you used on D16: [customers.csv](../../../../shared/datasets/nakheel/customers.csv), [products.csv](../../../../shared/datasets/nakheel/products.csv), [orders.csv](../../../../shared/datasets/nakheel/orders.csv), [order_items.csv](../../../../shared/datasets/nakheel/order_items.csv). On GitHub, open each file and click **Download raw file**; keep the four in one folder.
- **Two prepared files:** [`Resources/dates.pq`](Resources/dates.pq) (activity 02's date table, to paste if you prefer) and [`Resources/delivered_revenue.dax`](Resources/delivered_revenue.dax) (lab 04's measure).
- **Optional labs only:** lab 05's [`Resources/`](05-Lab-Optional-Shops-In-The-Model/Resources/) has D17's store sales and store list; lab 07 uses [`store_targets_2025-26.csv`](../../../../shared/datasets/nakheel_stores/store_targets_2025-26.csv).

The [Nakheel data guide](../../../../shared/datasets/nakheel/README.md) describes every column.

## The activities and labs

| | What you build | Start from |
|---|---|---|
| [Activity 01: build sales_lines and name each table's grain](01-Evr-Load-Tables-Build-Sales-Lines/README.md) | four tables loaded; `sales_lines` | a new file |
| [Activity 02: build, sort and mark the dates table](02-Evr-Date-Table/README.md) | `dates` | 01 |
| [Activity 03: relate the tables and answer the manager's questions](03-Evr-Relationships-And-Questions/README.md) | three relationships; five answers | 02 |
| [Lab 04: two dates and a tidy model](04-Lab-Two-Dates-Tidy-Model/README.md) | the delivered date, `Delivered revenue`; keys hidden | 03 |
| [Lab 05 (optional): the shops in the same model](05-Lab-Optional-Shops-In-The-Model/README.md) | `store_sales` and `stores` related | 04 (or 03) |
| [Lab 06 (optional, PL-300): cross filter direction Both and what it costs](06-Lab-Optional-Filter-Direction/README.md) | **Both**, then back to **Single** | a copy of 03 |
| [Lab 07 (optional, PL-300): finance's monthly targets in the model](07-Lab-Optional-Targets-By-Month/README.md) | `targets_long` | 05 |

## Desktop and the web

> **In Desktop:** open a new file and save it at once as `D18-checkpoint.pbix`; save after each activity. Keep the folder with the CSV files: the report reads them when you refresh.
> **On the web:** start from **+ New Report** → **Get data** → **Text/CSV** → **Upload file**, add the other files inside the same Power Query editor, and save the semantic model as `D18-nakheel` in **My workspace**. Later changes: **Open semantic model** → **Editing**. Changes on the web are saved at once and cannot be undone. If a step is missing on your screen, pair with a classmate on Desktop.

## Check rows and totals

- **Row counts:** **Table view** (the second icon on the left) → select a table: the status bar shows its rows. Power Query's `999+ rows` is not a count. Today: `sales_lines` 7,516 · `customers` 500 · `products` 60 · `dates` 1,096.
- **Revenue:** put `sales_lines[status]` = **completed** in **Filters on this visual**. The check is **316,023.50** (D16); 340,370.00 means the filter is missing.
- **The whole value on a card:** a **Card** shows `316.02K`. **Format visual** → **Visual** → **Callout** → **Value** → **Display units** → **None** (some versions say **Callout values**).

## Where the data comes from

Nakheel Retail, synthetic course data generated 24 September 2026 ([`shared/datasets/nakheel`](../../../../shared/datasets/nakheel/README.md)); the store files, course-made 28 October 2026 ([`shared/datasets/nakheel_stores`](../../../../shared/datasets/nakheel_stores/README.md)). Menu names are Power BI's in October 2026; if a name differs on your screen, look in the same tab or menu.
