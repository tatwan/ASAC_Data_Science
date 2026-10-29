# Choose columns, sort and limit

In this activity, you will type four queries that choose columns, rename one, sort the rows and keep only the top few.

**Time:** 10 minutes · **Data:** `D03.orders`, `D03.order_items` (activity 01) · **Starter:** `Unsolved/columns_sort_limit.sql`

## Instructions

1. Show only `order_id`, `order_date` and `status` from `D03.orders`.

2. Run the same query with `order_id` shown as `order_number`. Open the table's Preview afterwards: is the column in the table renamed?

3. Show every row of `D03.order_items`, most expensive unit price first. Show `item_id`, `order_id`, `product_id`, `qty` and `price`.

4. Show the three order lines with the largest quantity: `item_id`, `order_id`, `product_id` and `qty`. Add `item_id` as a second sort column so everyone gets the three rows in the same order.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 5 | three columns only |
| 2 | 5 | first column is headed `order_number` |
| 3 | 12 | first row has `price` 42.00 (BigQuery shows `42.0`) |
| 4 | 3 | item 9010, qty 4, is first |

## Hint

`ORDER BY price DESC` sorts largest first. `ASC`, smallest first, is the default, so you can leave it out.

## References

The D03 tables, course-owned synthetic data, 19 September 2026.
