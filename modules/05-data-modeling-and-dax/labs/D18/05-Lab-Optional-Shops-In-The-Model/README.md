# Lab 05 (optional): the shops in the same model

In this optional lab, you will add D17's store sales and store list to today's model, get D17's revenue by governorate back through a relationship instead of a Merge, and see why we keep these two fact tables separate in this model.

**When:** after class, if you want more. Not submitted. · **Files:** your file from lab 04 (or from activity 03) · **Data:** [`Resources/store_sales.csv`](Resources/store_sales.csv) (D17's appended store sales, 1,901 rows) and [`Resources/stores.csv`](Resources/stores.csv) (D17's cleaned store list, 12 rows), D17's two finished tables saved as files; `sales_lines`, `dates` (activities 01–03) · **Pages:** the appendix of the D18 slides · **Guide:** [the D18 page](../README.md)

**The question:** D17 merged the store list into the sales to chart revenue by governorate. Can the model answer it without copying anything?

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | The shops are not in today's model | **Get data** → **Text/CSV** |
| 2 | `stores` and `dates` do not reach `store_sales` | two relationships |
| 3 | D17 needed a Merge for this chart | a bar chart by `stores[governorate]` |
| 4 | A tempting line between the two fact tables | the two-paths check |

We follow **order 100003**, a store order: one row in `store_sales`, three in `sales_lines`.

## Step 1 · Load the two store files

**Why this step:** `store_sales` (one row per store order) and `stores` (one row per shop) are a fact table and a dimension table of their own.

**Transform data** → **New Source** → **Text/CSV** → `store_sales.csv`, then `stores.csv`. Rename the queries `store_sales` and `stores`. **Close & Apply**.

**Check:** `store_sales` **1,901** rows (Table view).

**What just happened:** order 100003 is one row of `store_sales`: its shop, its date, 47.00.

## Step 2 · Relate stores and dates to store_sales

**Why this step:** a shop filters its own sales; the same `dates` table should filter both fact tables.

In Model view, drag `stores[store_code]` onto `store_sales[store_code]` (if Power BI has not already), and `dates[date]` onto `store_sales[order_date]`. If Power BI drew a line between `store_sales` and `sales_lines` on `order_id`, delete it (step 4 says why).

**Check:** **two** new solid lines into `store_sales`, one to many, **Single**.

**What just happened:** order 100003's shop and day can now filter its `store_sales` row.

This is where a shared calendar becomes useful: selecting September 2024 in `dates` selects that month's rows in both fact tables. A date field taken from `sales_lines` alone would not filter `store_sales` through these single-direction relationships. The common grouping field must come from the shared dimension.

## Step 3 · Revenue by governorate, through a relationship

**Why this step:** this is D17's chart, with nothing copied.

A **Clustered bar chart**: `stores[governorate]` on the Y-axis, `store_sales[order_total]` on the X-axis, `store_sales[status]` = completed. *Why that `status`:* the one on `sales_lines` does not reach `store_sales`.

**Check:** total **205,338.00** (Amman 83,914.50, Irbid 62,116.50 … (Blank) 858.00).

**What just happened:** (Blank) is `NK-POP-01`, the Ramadan stall, which is in no store list: a blank row, as for customer C-0999. Jerash has a row in `stores` and no sales, so it is not on the chart until **Show items with no data**.

## Step 4 · Why the two fact tables stay apart

**Why this step:** `stores` reaches `store_sales` but not `sales_lines`, so "store revenue by category" is not in this model. Relating `store_sales` to `sales_lines` on `order_id` looks like the fix, but it gives `dates` two paths to the same lines.

A **Matrix**: `dates[year_month]` on rows; Sum of `store_sales[order_total]` and Sum of `sales_lines[line_value]`; filters `store_sales[status]` = completed, `sales_lines[status]` = completed, `sales_lines[channel]` = store. Then compare April through the two paths:

| Path from `dates` to `sales_lines` | April 2026, completed lines |
|---|---:|
| direct, on `order_date` | 20,237.00 (every line ordered in April) |
| through `store_sales`, then `order_id` | 13,585.50 (only lines of a store order; online's 6,651.50 never found) |

**Check:** in the matrix, April 2026 reads **13,585.50** in both columns.

Each matrix row selects all the calendar days in one month. Those dates filter each fact table independently. The store-channel and completed-status filters make the two columns describe the same sales, once as orders and once as lines. They should agree; adding the two columns together would count the same store revenue twice.

The path table above explains the proposed relationship's problem; do not add that line for this check. Its 20,237.00 includes online revenue before the store-channel restriction, whereas the matrix deliberately compares store sales only. Keeping these facts separate is the choice for this model, not a rule that every pair of fact tables can never have a relationship.

**What just happened:** both fact tables agree, month by month, through the shared `dates`. Two paths would give two answers, so Power BI keeps only one active; the model keeps the facts apart and lets them meet in `dates`.

## Check yourself

| Step | One value |
|---|---|
| 1 | 1,901 rows |
| 2 | 2 new lines |
| 3 | 205,338.00 |
| 4 | April 2026: 13,585.50 in both |

## If something goes wrong

- **Every governorate bar is the same:** the value came from `sales_lines`; use `store_sales[order_total]`.
- **The matrix columns disagree:** one of the three filters is missing.

## Hint

A dimension filters only the fact tables it has a line to.

## References

Nakheel's store files, course-made 28 October 2026 ([`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md)); the two files here are what D17's activities 01, 04 and 05 built. Microsoft: [Model relationships: relationship evaluation](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-relationships-understand). Menu names are Power BI's in October 2026.
