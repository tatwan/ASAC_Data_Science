# Lab 05 (optional, PL-300): each product's share of its category

In this lab, you will answer D10's question "What share of its category's revenue does each product bring?" in DAX, removing the filter on one column instead of a whole table.

**When:** after class, self-guided, not submitted. · **Files:** your file from lab 04 · **Data:** `sales_lines`, `products` (activity 01); Completed Revenue (activity 03) · **Guide:** [the D19 page](../README.md)

**The question:** on D10 activity 02, `SUM(revenue) OVER (PARTITION BY category)` put each category's total beside its products: White thobe brought 24.1% of Tops. Here the bottom number must keep the category and drop the product.

| Step | The problem you will see | The tool |
|---|---|---|
| 1 | Each row needs both its category and its product | a **Table** visual |
| 2 | The bottom number must be the category's total | `REMOVEFILTERS(products[product_name])` |
| 3 | The share, sorted | `DIVIDE`, percentage, sort |

We follow **order 100003**'s Kids T-shirt (5.00, Tops).

## Step 1 · A table by category and product

**Why this step**

Each row gives the measure two filters from `products`. The Kids T-shirt row specifies `category = Tops` and `product_name = Kids T-shirt`. Keep both fields in the table so the category filter is available when you calculate the denominator.

Clear the category and channel slicers from Lab 04. Add a **Table** visual with `products[category]`, `products[product_name]` and **Completed Revenue**.

**Check:** **56** rows (four products never sold, D07).

**What just happened:** Kids T-shirt's row adds its completed lines, order 100003's 5.00 among them.

## Step 2 · Category Revenue

**Why this step**

To find a product's share of its own category, the bottom number needs revenue for every product in that category. `REMOVEFILTERS(products[product_name])` clears the name filter and leaves the category filter in place.

```dax
Category Revenue =
    CALCULATE(
        [Completed Revenue],
        REMOVEFILTERS(products[product_name])
    )
```

Add **Category Revenue** to the table.

**Check:** every Tops row reads **40,588.00**.

**What just happened**

On the Kids T-shirt row, **Completed Revenue** sums that T-shirt's completed lines. **Category Revenue** keeps `category = Tops` and the completed-status rule. The row still says Kids T-shirt, and its category total includes every Tops product. Using `REMOVEFILTERS(products)` here would clear both product filters and give **316,023.50**, the all-category total from Lab 04.

## Step 3 · % of Category

**Why this step**

Divide the product's completed revenue by its category's completed revenue. The denominator can change from one category to the next.

```dax
% of Category = DIVIDE([Completed Revenue], [Category Revenue])
```

Format it as **Percentage** with one decimal place. Add **% of Category** to the table and sort it highest first.

**Check:** White thobe **24.1%** of Tops first; Leather belt 22.2% of Accessories second.

**What just happened**

White thobe accounts for **9,768.00** of the **40,588.00** in completed Tops revenue, giving **24.1%**. Leather belt accounts for **22.2%** of the **43,525.00** in completed Accessories revenue.

## Check yourself

| Step | One value |
|---|---|
| 1 | 56 rows |
| 2 | 40,588.00 on every Tops row |
| 3 | White thobe 24.1% |

## If something goes wrong

- **Category Revenue reads 316,023.50 on every row.** Check that the table includes `products[category]` and the measure clears only `products[product_name]`.
- **Category Revenue equals Completed Revenue for each product.** Check the product field in the table. A filter on `product_id` would stay in place when the measure clears `product_name`.

## Bonus

Add a slicer on `products[product_name]` and select **White thobe**. On the White thobe row, **Category Revenue** still shows **40,588.00**. For that calculation, Power BI removes the filter on `products[product_name]` and keeps the row's **Tops** filter. The slicer still shows **White thobe**. Clear it when you finish.

## References

Microsoft: [REMOVEFILTERS](https://learn.microsoft.com/en-us/dax/removefilters-function-dax). D10 activity 02, each product's share of its category. Menu names are Power BI's in November 2026.
