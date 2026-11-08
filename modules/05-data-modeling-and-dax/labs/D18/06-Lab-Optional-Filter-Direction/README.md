# Lab 06 (optional, PL-300): cross filter direction Both and what it costs

In this optional lab, you will set one relationship to **Both**, see it answer the Shoes question, and see what else it changes in the report.

**When:** after class; exam practice for PL-300. Not submitted. · **Files:** a copy of your file from activity 03 (**File** → **Save as**) · **Data:** `sales_lines`, `customers`, `products` (activities 01–03) · **Guide:** [the D18 page](../README.md)

**The question:** activity 03 counted the customers who bought Shoes in the fact table (284). Could the relationship do it instead?

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | Count of customers reads 500 on every category | **Cross filter direction: Both** |
| 2 | Both reaches every visual of customers | a slicer and a card |
| 3 | The report now behaves differently everywhere | back to **Single** |

We follow customer **C-1357**, who bought Outerwear, Sportswear and Tops in order 100003.

## Step 1 · Set Both on customers–sales_lines

**Why this step:** with **Single**, a filter on a category reaches `sales_lines` and stops; it cannot travel back to `customers`.

1. A bar chart: `products[category]` on the Y-axis, Count of `customers[customer_id]` on the X-axis, `sales_lines[status]` = completed: 500 on every bar.
2. Model view: double-click the `customers`–`sales_lines` line → **Cross filter direction** → **Both** → **OK**. The line now has two arrowheads.

**Check:** Shoes **283** (Bottoms 320, Sportswear 310).

**What just happened:** the Shoes filter now flows `products` → `sales_lines` → `customers`. It reads 283, not 284: **Both** counts rows of `customers`, and C-0999 has none; the fact table still holds its code.

These are two populations: 284 distinct IDs in completed Shoes sales, and 283 matching customer records. The missing customer record explains the difference. A smaller number after changing the relationship is not automatically a better answer; first say whether the question asks for IDs on sales or people present in the customer list.

## Step 2 · See what else Both changed

**Why this step:** a relationship setting applies to every visual on every page, not just the chart you were fixing.

On a new page: a **Slicer** on `products[category]` and a **Card** with Count of `customers[customer_id]` (no `status` filter). Pick Shoes.

**Check:** the card reads **297**: every customer with a Shoes line, any status.

The bar chart's completed-status filter applies only to that visual. This new card has no such filter, so 297 is not the completed-only 283 from step 1. Read the selected category, status scope and table being counted together before comparing results.

**What just happened:** C-1357 is counted only while its categories are picked. Every visual of customers now follows the product slicer, whether its author wanted that or not.

## Step 3 · Set the direction back to Single

**Why this step:** Microsoft: "minimize the use of bi-directional relationships": they can slow queries and confuse report users. Count in the fact table instead (activity 03, step 4), or, for one measure that needs it, `CROSSFILTER` (D19 onward).

Double-click the line → **Single** → **OK**.

**Check:** the card reads **500** again.

**What just happened:** the report is back to filters that run from the thing to its events.

## Check yourself

| Step | One value |
|---|---|
| 1 | Shoes 283 |
| 2 | 297 |
| 3 | 500 |

## If something goes wrong

- **Still 500 after step 1:** you changed `products`–`sales_lines`; it must be `customers`–`sales_lines`.

## References

Microsoft: [Bi-directional relationship guidance](https://learn.microsoft.com/en-us/power-bi/guidance/relationships-bidirectional-filtering). Menu names are Power BI's in October 2026.
