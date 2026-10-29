# The customer and product views

In this activity, you will save two more views in `bi`: `dim_customer`, one row per customer with the D07 cleaning rules built in, and `dim_product`, one row per product, and check that each has exactly one row per ID.

**Time:** 20 minutes · **Data:** `nakheel.customers`, `nakheel.products` (D04 activity 03) · **Starter:** `Unsolved/dimension_views.sql`

**Before you start:** you need the `bi` dataset and `bi.fact_sales` from [Save a query as a view](../07-Ins-First-View/README.md). If `bi` is missing, create it: in the **Explorer**, **⋮** next to your project → **Create dataset** → **Dataset ID** `bi` → the same location as `nakheel` (the [D04 upload guide](../../D04/03-Evr-Upload-Nakheel/README.md) used **Multi-region**, **US**) → **Create dataset**.

Power BI works best with one table of events and small tables that describe them. The events are the order lines in `bi.fact_sales`: the rows you add up, often called a **fact** table. The tables that describe them have one row per customer and one row per product: **dimension** tables, hence the `dim_` names. You put the D07 cleaning rules into the customer view once, and no report has to repeat them.

## Instructions

1. Create `bi.dim_customer`: one row per customer with `customer_id`, `customer_name`, the cleaned city, the cleaned segment and `signup_date`.

    Translate: `CREATE OR REPLACE VIEW bi.dim_customer AS`, then a `SELECT` from `nakheel.customers`. The city uses the `CASE` rule from [A cleaning rule of your own](../../D07/05-Evr-City-Rule/README.md), named `city`. The segment is `LOWER(TRIM(segment))`, named `segment`. Keep these two names: every report will use them.

    You should see "This statement created a new view named …dim_customer".

2. Create `bi.dim_product`: `product_id`, `product_name`, `category` and `list_price` from `nakheel.products`, as they are.

3. Refresh the **Explorer** and expand `bi`. You should see three views, each with the view icon: `fact_sales`, `dim_customer` and `dim_product`. Click `dim_customer`: **Schema** lists 5 columns, and there is no **Preview** tab, because a view stores no rows.

4. "Is `dim_customer` one row per customer, and did the cleaning work?" Predict each number, then count the rows, the different `customer_id` values, the different segments and the different cities, reading from `bi.dim_customer`.

5. "Is `dim_product` one row per product?" Count the rows, the different `product_id` values and the different categories.

6. Why check that the rows equal the different IDs? It is Check 3 of the Five Checks from D06. Every report will join `fact_sales` to these views on the ID. If an ID appeared twice here, the join would copy that customer's or product's order lines and every total would grow.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 4 | 1 | 500 rows; 500 customers; 2 segments; 9 cities (8 cities and unknown) |
| 5 | 1 | 60 rows; 60 products; 6 categories |

10 cities means the `al zarqa` line is missing from the `CASE`. 8 cities means the `WHEN city IS NULL THEN 'unknown'` line is missing: `COUNT(DISTINCT ...)` does not count `NULL`. More than 2 segments means `LOWER(TRIM(...))` is missing.

## Hint

A view is read exactly like a table: `SELECT COUNT(*) AS customer_rows, COUNT(DISTINCT customer_id) AS different_customers, … FROM bi.dim_customer;`.

## If something goes wrong

| Problem | Fix |
|---|---|
| `Not found: Dataset <project>:bi` | `bi` is missing or spelled differently. Create it (see **Before you start**) |
| An error that a table was "not found in location" | `bi` is in a different location from `nakheel`. Delete `bi` and create it again in the same location, then create all three views again |
| The view appears but has the wrong columns | Fix the query and run it again; `OR REPLACE` overwrites the old view |

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../D04/03-Evr-Upload-Nakheel/Resources/README.md).
