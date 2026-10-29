# Filter rows

In this activity, you will filter three tables, then run a query that fails and use the error to learn the order in which a query runs.

**Time:** 9 minutes · **Data:** `D03.customers`, `D03.orders`, `D03.order_items` (activity 01) · **Starter:** `Unsolved/filter_rows.sql`

## Instructions

1. Show the customers in Irbid: `customer_id`, `customer_name` and `city`.

2. Show the orders placed on or after 15 August 2026: `order_id`, `order_date` and `status`.

3. Show the order lines with a quantity of 2 or more, largest quantity first: `item_id`, `order_id`, `product_id` and `qty`.

4. Run query 4 in the starter file as it is. Read the error message aloud, then fix the query.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 | C-204 and C-401, both Omar Nasser |
| 2 | 2 | orders 1004 and 1005 |
| 3 | 7 | first row is item 9010, qty 4 |
| 4 | error | `Unrecognized name: order_number` |
| 4 (fixed) | 1 | `order_number` 1003, completed |

## Why query 4 fails

You write a query in this order: `SELECT`, `FROM`, `WHERE`, `ORDER BY`, `LIMIT`. BigQuery runs it in a different order:

```text
FROM      which table
WHERE     which rows
SELECT    which columns, and their new names
ORDER BY  in what order
LIMIT     how many
```

`WHERE` runs before `SELECT`, so the name `order_number` does not exist yet when `WHERE` needs it. `ORDER BY` runs after `SELECT`, which is why sorting by a new name works.

## Hint

A date in a condition is written in quotes, as `'2026-08-15'`. BigQuery reads it as a date because `order_date` is a `DATE` column.

## References

The D03 tables, course-owned synthetic data, 19 September 2026.
