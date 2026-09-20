# w01_retail

Four small tables used on D01, on the sample-data slide and in the table-reading worksheet. They
are small on purpose: you should be able to read every row on a projector and reason about them
without a tool.

| Fact | Value |
|---|---|
| Source | Synthetic. Written for this course on 19 September 2026. No third-party data |
| Terms | Course-owned. Reuse freely inside ASAC materials |
| Encoding | UTF-8, comma-separated, header row |
| Currency | Jordanian dinar. `price` is the unit price, not the line total |

## Files

| File | Rows | Columns |
|---|---:|---|
| `orders.csv` | 5 | `order_id`, `customer_id`, `order_date`, `status` |
| `order_items.csv` | 12 | `item_id`, `order_id`, `product_id`, `qty`, `price` |
| `products.csv` | 5 | `product_id`, `product_name`, `category` |
| `customers.csv` | 5 | `customer_id`, `customer_name`, `city`, `segment`, `signup_date` |

Working out what one row of each table represents, and which column could be a key, is the D01 lab.
The answers are released at the debrief, not here.

Some of what you find in these tables looks wrong. That is deliberate and it is part of the
exercise, so do not clean it.
