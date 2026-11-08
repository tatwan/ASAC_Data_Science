# Activity 03: one measure in a card, a table and under slicers, then CALCULATE

In this activity, you will put Total Revenue and Customers in a table by category and under a channel slicer, see why each place shows a different number, then write Completed Revenue with `CALCULATE`.

**Files:** your file from activity 02 · **Data:** `sales_lines`, `products` (activity 01); the measures (activity 02) · **Guide:** [the D19 page](../README.md)

**The question:** "Why does the same measure give 316,023.50 in the card, 76,637.00 on the Outerwear row and 110,685.50 under an online slicer?" Each place has different filters: its filter context.

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | One measure, a different number on each row | a **Table** by `products[category]` |
| 2 | The rows of Customers do not add up to the total | the total row is calculated again |
| 3 | A slicer changes the card | a **Slicer** on `channel` |
| 4 | The status slicer is needed on every page | `CALCULATE` |

We follow **order 100003**, a store order: Fleece jacket 24.00 (Outerwear), Kids football boots 18.00 (Sportswear), Kids T-shirt 5.00 (Tops).

## Step 1 · Total Revenue by category

**Why this step:** to see one measure give six answers, one per row.

Keep activity 02's completed slicer on. A **Table** visual: `products[category]` and **Total Revenue**.

**Check:** Outerwear **76,637.00**; the total row 316,023.50.

**What just happened:** each row's category filters `products`, the filter runs along the relationship to `sales_lines` (D18), and `SUM` adds the lines left. Order 100003's 47.00 is split: 24.00 in Outerwear, 18.00 in Sportswear, 5.00 in Tops.

## Step 2 · Customers by category

**Why this step:** the total row is a cell too, calculated on its own rows; for a distinct count it is not the sum of the rows.

Add **Customers** to the table.

**Check:** Shoes **284**; the total row 452 (the six rows add up to 1,835).

**What just happened:** C-1357 bought in all six categories, so is counted in six rows and once in the total. Shoes 284 is D18's answer to "how many customers bought Shoes?".

## Step 3 · A slicer on channel

**Why this step:** a slicer is another source of filters; every visual on the page gets it.

A second **Slicer** with `sales_lines[channel]`; tick **online**. Look at the Total Revenue card. Then clear the channel slicer.

**Check:** **110,685.50**.

**What just happened:** order 100003 is a store order, so none of its 47.00 is in 110,685.50.

## Step 4 · Completed Revenue with CALCULATE

**Why this step:** on D18 every visual needed the completed filter added by hand; today a slicer does it. `CALCULATE` writes the filter into one measure, so no visual and no slicer needs it.

1. Clear the status slicer (or delete it).
2. A new measure on `sales_lines`:

```dax
Completed Revenue =
    CALCULATE(
        [Total Revenue],
        sales_lines[status] = "completed"
    )
```

3. A **Table** visual: `sales_lines[status]`, **Total Revenue** and **Completed Revenue**.

*Why the same number on every row:* the row already filters `status`; `CALCULATE` replaces a filter on the same column with its own. On the category table from step 1, it keeps the category filter and adds the status filter.

**Check:** Completed Revenue **316,023.50** on every status row (Total Revenue: 316,023.50 · 21,998.50 · 2,348.00).

**What just happened:** order 100003 is completed, so its 47.00 is inside Completed Revenue on every row.

## Check yourself

| Step | One value |
|---|---|
| 1 | Outerwear 76,637.00 |
| 2 | Shoes 284; total 452 |
| 3 | 110,685.50 |
| 4 | 316,023.50 on every status row |

## If something goes wrong

- **Every category row shows 316,023.50 in step 1:** `products` is not related to `sales_lines` (activity 01, step 2).
- **An error on "completed":** DAX text needs double quotes, not single quotes.
- **Completed Revenue reads 21,998.50 on the cancelled row:** you used a visual filter or `KEEPFILTERS`. Use the measure exactly as written.

## Bonus

Add Completed Revenue to step 1's category table with no status slicer on the page. Which column changes, Total Revenue or Completed Revenue, and why?

## References

Microsoft: [CALCULATE function](https://learn.microsoft.com/en-us/dax/calculate-function-dax) (Remarks: filters on columns already in the filter context are overwritten). Menu names are Power BI's in November 2026.
