# Lab 05 (optional, PL-300): each product's share of its category

In this lab, you will answer D10's question "What share of its category's revenue does each product bring?" in DAX, removing the filter on one column instead of a whole table.

**When:** after class, self-guided, not submitted. · **Files:** your file from lab 04 · **Data:** `sales_lines`, `products` (activity 01); Completed Revenue (activity 03) · **Guide:** [the D19 page](../README.md)

**The question:** on D10 activity 02, `SUM(revenue) OVER (PARTITION BY category)` put each category's total beside its products: White thobe brought 24.1% of Tops. Here the bottom number must keep the category and drop the product.

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | A table with two levels: category and product | a **Table** visual |
| 2 | The bottom number must be the category's total | `REMOVEFILTERS(products[product_name])` |
| 3 | The share, sorted | `DIVIDE`, percentage, sort |

We follow **order 100003**'s Kids T-shirt (5.00, Tops).

## Step 1 · A table by category and product

**Why this step:** each row now has two filters from `products`: its category and its product.

Clear lab 04's channel slicer. A **Table** visual: `products[category]`, `products[product_name]` and **Completed Revenue**.

**Check:** **56** rows (four products never sold, D07).

**What just happened:** Kids T-shirt's row adds its completed lines, order 100003's 5.00 among them.

## Step 2 · Category Revenue

**Why this step:** removing the filter on `product_name` only, not the whole `products` table, keeps the row's category.

```dax
Category Revenue =
    CALCULATE(
        [Completed Revenue],
        REMOVEFILTERS(products[product_name])
    )
```

**Check:** every Tops row reads **40,588.00**.

**What just happened:** Kids T-shirt's row now sees every Tops line, with the category filter still on.

## Step 3 · % of Category

**Why this step:** the share, as on D10.

```dax
% of Category = DIVIDE([Completed Revenue], [Category Revenue])
```

Format it as **Percentage**, one decimal; sort the table by % of Category, highest first.

**Check:** White thobe **24.1%** of Tops first; Leather belt 22.2% of Accessories second.

**What just happened:** the same answer as D10's window query, with no SQL.

## Check yourself

| Step | One value |
|---|---|
| 1 | 56 rows |
| 2 | 40,588.00 on every Tops row |
| 3 | White thobe 24.1% |

## If something goes wrong

- **Category Revenue reads 316,023.50 on every row:** you removed the whole table, `REMOVEFILTERS(products)`. Name the column.
- **Category Revenue equals Completed Revenue:** the table's product column is `product_id`, not `product_name`. Remove the filter on the column the table uses.

## References

Microsoft: [REMOVEFILTERS](https://learn.microsoft.com/en-us/dax/removefilters-function-dax). D10 activity 02, each product's share of its category. Menu names are Power BI's in November 2026.
