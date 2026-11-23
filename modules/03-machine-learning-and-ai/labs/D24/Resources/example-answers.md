# Example answers for Activity 01

These were written for the course to show what an assistant typically returns. They are not transcripts of a particular product. Use them if you have no assistant to hand, or if yours is unavailable.

## To the short prompt

> **Prompt:** Write SQL for revenue by category.

> Here is a query that calculates revenue by category:
>
> ```sql
> SELECT category, SUM(revenue) AS total_revenue
> FROM sales
> GROUP BY category
> ORDER BY total_revenue DESC;
> ```
>
> This assumes a table named `sales` with `category` and `revenue` columns. Let me know your table structure and I can adjust it.

What it decided for you: a table named `sales`, a column named `revenue`, and that every order counts. Some assistants ask for your tables instead of guessing. Either way, it cannot write your query without them.

## To the full prompt

> The lines in `order_items` join to `orders` on `order_id` to get each line's status, and to `products` on `product_id` to get its category. Revenue is summed on the lines, so no order value is repeated.
>
> ```sql
> SELECT
>   p.category,
>   SUM(i.qty * i.price) AS revenue
> FROM nakheel.order_items AS i
> JOIN nakheel.orders AS o ON i.order_id = o.order_id
> JOIN nakheel.products AS p ON i.product_id = p.product_id
> WHERE o.status = 'completed'
> GROUP BY p.category
> ORDER BY revenue DESC;
> ```
>
> This should return 6 rows that add up to 316,023.50.

The last sentence repeats your check line. The assistant has not run the query, so it does not know the total; you run it or compare it with the table in the README.
