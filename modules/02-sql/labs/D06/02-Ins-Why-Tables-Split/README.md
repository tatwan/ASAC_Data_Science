# Why the data is split, and the Five Checks

In this activity, you will see why a database keeps customers and orders in separate tables, draw the one-to-many shape between them, and run the checks that come before every join.

**Time:** 18 minutes · **Data:** `D03.orders`, `D03.customers` (D03 activity 01) · **File:** `Solved/five_checks.sql`

## Instructions

1. Open `D03.orders` and `D03.customers` in BigQuery and look at the **Preview** tab of each. `orders` has a `customer_id` column but no names or cities. `customers` has one row per customer, with `customer_id`, name and city.

2. Ask yourself: what if every order row carried the customer's name and city? Lina Haddad (C-118) moves from Amman to Aqaba. How many rows would you have to change?

    In `D03` it is two, orders 1002 and 1005. At Nakheel it could be a hundred. Miss one and the database disagrees with itself: two cities for one customer, and no way to tell which is right. So the name and city are stored once, in `customers`, and each order stores only `customer_id`, which points to the right customer row. Changing Lina's city is one change in one row.

3. Look at the shape. One customer can have many orders; each order has one customer. That is a **one-to-many** relationship. `customers.customer_id` is the **primary key** (it names one customer); `orders.customer_id` is a **foreign key** (it points to a customer).

    ```mermaid
    erDiagram
        customers ||--o{ orders : "places"
        customers {
            string customer_id PK
            string customer_name
            string city
        }
        orders {
            int order_id PK
            string customer_id FK
            string status
        }
    ```

    Read the line between the tables from left to right: one customer (the end with two short bars) places zero or more orders (the end that splits into a fork). PK marks the primary key, FK the foreign key.

    Here is what that looks like for Lina. Her name is stored once in `customers`, and her `customer_id` appears on each of her orders:

    | customer_id | customer_name |
    |---|---|
    | C-118 | Lina Haddad |

    | order_id | customer_id | status |
    |---:|---|---|
    | 1002 | C-118 | cancelled |
    | 1005 | C-118 | completed |

    A **join** puts the columns of two tables side by side for one query, matching rows on a key. It does not change either table.

4. Learn the Five Checks. You run them before every join this week, and in Assignment 1. Here are the answers for `orders` and `customers`:

    1. **What is one row in each table?** `orders`: one order. `customers`: one customer.
    2. **Which key joins them?** `orders.customer_id = customers.customer_id`: the column on each side that holds the same value.
    3. **Is the key unique on the "one" side?** Every `customer_id` should appear once in `customers`. Steps 5 and 6 check it.
    4. **How many rows should come out?** Each order finds at most one customer, so at most 5 rows: the grain of the "many" side.
    5. **What happens to rows with no match?** C-377 and C-455 have no orders. `INNER JOIN` drops them; `customers LEFT JOIN orders` keeps them, with empty (`NULL`) order columns.

5. Open `Solved/five_checks.sql`. Predict the two numbers, then run query 1, check 3 on the "one" side. You should see 5 and 5. Equal counts mean every ID appears once: the key is unique.

6. Run query 2, the same check on the "many" side. You should see 5 and 3. The IDs repeat, and that is expected: one customer, many orders.

7. Why check at all? BigQuery does not enforce keys. Nothing stops a second `C-118` row from being loaded into `customers`. If that happened, every C-118 order would match two customer rows and appear twice after the join. Check 3 is how you find out.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 5 customer rows, 5 different IDs |
| 2 | 1 | 5 order rows, 3 different IDs |

## References

The D01 tables (the `D03` dataset), course-owned synthetic data, 19 September 2026.
