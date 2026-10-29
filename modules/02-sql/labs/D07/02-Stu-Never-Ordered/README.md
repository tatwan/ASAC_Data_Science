# Never ordered, never sold

In this activity, you will find the customers who have never placed an order and the products that have never been sold, using a `LEFT JOIN` and `IS NULL`.

**Time:** 10 minutes · **Data:** `nakheel.customers`, `nakheel.orders`, `nakheel.products`, `nakheel.order_items` (D04 activity 03) · **Starter:** `Unsolved/never_ordered.sql`

## How the tables connect

```mermaid
erDiagram
    customers ||--o{ orders : "places"
    orders ||--|{ order_items : "contains"
    products ||--o{ order_items : "appears on"
    customers {
        string customer_id PK
        string customer_name
        string city
        string segment
        date signup_date
    }
    orders {
        int order_id PK
        string customer_id FK
        date order_date
        timestamp order_ts
        string channel
        string status
        float order_total
        float shipping_fee
        date delivered_date
    }
    order_items {
        int item_id PK
        int order_id FK
        string product_id FK
        int qty
        float price
    }
    products {
        string product_id PK
        string product_name
        string category
        float list_price
    }
```

Join keys: `orders.customer_id = customers.customer_id`, `order_items.order_id = orders.order_id` and `order_items.product_id = products.product_id`.

PK is the primary key: it names one row. FK is a foreign key: it points to a row in another table. The line between two tables shows the join: the end with two short bars is the "one" side, and the end that splits into a fork is the "many" side.

## Instructions

1. "Which customers have signed up but never placed an order? The marketing team wants to contact them."

    Translate: `customers LEFT JOIN orders`, keep the rows where the order side is empty. Show each customer's ID, name, city and signup date, sorted by ID.

2. "Which products have never sold? The buying team is deciding whether to stop stocking them."

    Translate: `products LEFT JOIN order_items`, keep the rows where the item side is empty. Show each product's ID, name and category, sorted by ID.

## Check yourself

| Question | Rows returned | One value to check |
|---|---:|---|
| 1 | 39 | C-1013, Anas Abbadi, is first by ID |
| 2 | 4 | P-009, Hiking boot, is first by ID |

## Hint

After a `LEFT JOIN`, test a column from the right-hand table that is never empty in real rows, such as its key: `WHERE o.order_id IS NULL` for customers, `WHERE i.item_id IS NULL` for products.

## Bonus

How many of the never-ordered customers are in each city, as typed? Expect 9 rows.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../D04/03-Evr-Upload-Nakheel/Resources/README.md).
