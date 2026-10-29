# First questions

In this activity, you will answer four questions from the store manager using the `D03` tables, on your own. They are the four tables you met on D01.

**Time:** 10 minutes · **Data:** `D03.orders`, `D03.order_items`, `D03.customers` (activity 01) · **Starter:** `Unsolved/first_questions.sql`

For every question: write down what one row of the table is, predict how many rows you will get, then run.

## Instructions

1. "Which orders were cancelled? I need the order number and the date."

    Translate: `orders`, the rows where `status` is `cancelled`, columns `order_id` and `order_date`.

2. "Show me every order line that sold for more than 15 dinars a unit, most expensive first."

    Translate: `order_items`, the rows where `price` is over 15, columns `item_id`, `order_id`, `product_id` and `price`, sorted by `price`, largest first.

3. "Which customers have we got no city for?"

    Translate: `customers`, the rows where `city` is empty, columns `customer_id` and `customer_name`.

4. "Which orders has customer C-118 placed with us? Newest first."

    Translate: `orders`, the rows for one `customer_id`, columns `order_id`, `order_date` and `status`, sorted by `order_date`, newest first.

## Check yourself

| Question | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | order 1002, 2026-08-03 |
| 2 | 8 | first row has `price` 42.00 (BigQuery shows `42.0`) |
| 3 | 1 | C-455, Sami Odeh |
| 4 | 2 | first row is order 1005 |

If a count differs, check the value in `WHERE`. For question 3, use `IS NULL` for the missing city.

## Hint

For question 3, `= NULL` stops with `Operands of = cannot be literal NULL`. You met the fix a few minutes ago.

## Bonus

Find every retail customer, however "retail" was typed, without typing any of the three spellings. Show `customer_id`, `customer_name` and `segment`. Expect 3 rows. When would your query give the wrong answer?

## References

The D03 tables, course-owned synthetic data, 19 September 2026.
