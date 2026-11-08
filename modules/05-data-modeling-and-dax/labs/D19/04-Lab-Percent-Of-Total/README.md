# Lab 04: percent of total by category, checked against SQL

In this lab, you will compute each category's share of completed revenue with two measures, `CALCULATE` with `REMOVEFILTERS` and then `DIVIDE`, and check the shares against D10's window query.

**When:** shown in class after the break; finish it on your own if class ran out of time. Not submitted. · **Files:** your file from activity 03 · **Data:** `sales_lines`, `products` (activity 01); Completed Revenue (activity 03) · **Guide:** [the D19 page](../README.md)

**The question:** "What share of completed revenue does each category bring?" On D10 you answered it with `SUM(revenue) OVER ()`, a window that puts the grand total beside every row.

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | A measure divided by itself is 100% on every row | (the planned dead end) |
| 2 | The bottom number must see every category | `CALCULATE` with `REMOVEFILTERS(products)` |
| 3 | The share itself | `DIVIDE`, formatted as a percentage |
| 4 | The share of online revenue | a slicer on `channel` |

We follow **order 100003**: its Fleece jacket (24.00) is one of Outerwear's lines.

## Step 1 · The dead end: a measure divided by itself

**Why this step:** the first idea most people try, and why it fails, is what the next step fixes.

A **Table** visual: `products[category]` and **Completed Revenue**. A new measure on `sales_lines`, added to the table:

```dax
Share (wrong) = DIVIDE([Completed Revenue], [Completed Revenue])
```

**Check:** **100%** (shown as 1.00) on every row.

**What just happened:** on the Outerwear row the top and the bottom both see only Outerwear: 76,637.00 ÷ 76,637.00. Delete `Share (wrong)`.

## Step 2 · All Categories Revenue

**Why this step:** for a share, the bottom number must be the same on every row: completed revenue for all categories. `REMOVEFILTERS`, used inside `CALCULATE`, clears the filters on a table for that one calculation.

```dax
All Categories Revenue =
    CALCULATE(
        [Completed Revenue],
        REMOVEFILTERS(products)
    )
```

Add it to the table. *Why two measures and not one:* you can check this one on its own before dividing.

**Check:** **316,023.50** on every row.

**What just happened:** the Outerwear row still asks for Outerwear, but `REMOVEFILTERS(products)` takes that filter away for this measure, so it adds every completed line, order 100003's three lines included.

## Step 3 · % of Total

**Why this step:** the share is one measure divided by the other.

```dax
% of Total = DIVIDE([Completed Revenue], [All Categories Revenue])
```

Select the measure → **Measure tools** → **Format** → **Percentage**, one decimal place. Add it to the table.

> **On the web:** select the measure in **Editing** mode; **Format** is in the **Properties** pane.

**Check:** Outerwear **24.3%**; the total row 100.0%.

**What just happened:** 76,637.00 ÷ 316,023.50 = 24.3%. Order 100003's 24.00 is part of Outerwear's 76,637.00.

## Step 4 · The share of online revenue

**Why this step:** `REMOVEFILTERS(products)` removes only the products filter, so other filters, a slicer for example, stay.

A **Slicer** with `sales_lines[channel]`; tick **online**.

**Check:** Outerwear **22.9%** (All Categories Revenue reads 110,685.50 on every row).

**What just happened:** the bottom number is now online revenue for all categories. Order 100003 is a store order, so it is in neither number.

## Check yourself

| Step | One value |
|---|---|
| 1 | 100% on every row |
| 2 | 316,023.50 on every row |
| 3 | Outerwear 24.3%, total 100.0% |
| 4 | Outerwear 22.9% |

## If something goes wrong

- **Every row shows 24.3%, or the shares do not change by row:** `REMOVEFILTERS` went into the top number. Only All Categories Revenue has it.
- **0.24 instead of 24.3%:** format % of Total as **Percentage**.
- **8.0% in step 4:** you wrote `REMOVEFILTERS()` with nothing inside: it removes every filter, the slicer too, so the bottom number is all completed revenue (316,023.50).

## Hint

`ALL(products)` does the same as `REMOVEFILTERS(products)` inside `CALCULATE`. Exam questions use both names.

## Bonus

Swap the table's rows to `customers[segment]`. Do the shares still add up to 100%? Why does `REMOVEFILTERS(products)` not give each segment's share, and which table should the bottom number remove instead?

## References

Microsoft: [CALCULATE function](https://learn.microsoft.com/en-us/dax/calculate-function-dax) (its example `Revenue % Total Channel` is the same pattern), [REMOVEFILTERS](https://learn.microsoft.com/en-us/dax/removefilters-function-dax). Menu names are Power BI's in November 2026.
