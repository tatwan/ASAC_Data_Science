# D22 resources

## start/sales_lines.csv

D20's `sales_lines` with three columns added from D20's other start files, so the D22 dashboard needs one table. Made for Activity 00.

| Column | Type | Meaning |
|---|---|---|
| `order_id` | Whole number | The order; an order has one or more lines |
| `order_date` | Date | The day the order was placed |
| `year_month` | Text | `2026-04`: sorts correctly as text, but is a category on an axis |
| `month_start` | Date | The first day of the order's month: a continuous axis for the trend line |
| `channel` | Text | `store` or `online` |
| `status` | Text | `completed`, `cancelled` or `pending` |
| `product_name`, `category` | Text | From D20's `products.csv` |
| `customer_id`, `city` | Text | From D20's `customers.csv`; city is left as typed (`amman`, `Al Zarqa`, blanks) |
| `qty` | Whole number | Units on the line |
| `line_value` | Decimal | Price × quantity |

**Rows:** 7,516, September 2024 to August 2026. **Check:** completed revenue 316,023.50; store 205,338.00; online 110,685.50.

## channel_managers.csv

A small table made for this course. It maps each Nakheel channel manager's email to the one channel they manage. The emails use the reserved `.example` domain, so they belong to nobody.

| Column | Type | Meaning |
|---|---|---|
| `email` | Text | The manager's sign-in name (user principal name). One row per manager; this is the key |
| `channel` | Text | `store` or `online`, the same values as `sales_lines[channel]` |

**Rows:** 4 (two store managers, two online managers).

**How it is used:** loaded into the D22 model with **no relationship**. The Manager role looks up the channel for the signed-in email with `LOOKUPVALUE`, so each email must appear once.

**Check:** completed revenue for the store managers is 205,338.00 and for the online managers 110,685.50, from the D20 start files.
