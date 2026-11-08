# D19 start files

D18's finished tables as four CSV files, so D19 starts from a new Power BI file. Load all four with **Get data** → **Text/CSV** and draw the relationships (activity 01). No Power Query work is needed.

| File | Rows | One row is | Columns |
|---|---:|---|---|
| `start/sales_lines.csv` | 7,516 | one line of an order | `order_id`, `customer_id`, `product_id`, `order_date`, `delivered_date` (empty for cancelled and pending orders), `channel`, `status`, `qty`, `price`, `line_value` (`qty` × `price`) |
| `start/customers.csv` | 500 | one customer | `customer_id`, `customer_name`, `city`, `segment` (Retail or Wholesale, already fixed), `signup_date` |
| `start/products.csv` | 60 | one product | `product_id`, `product_name`, `category`, `list_price` |
| `start/dates.csv` | 1,096 | one day, 2024-01-01 to 2026-12-31 | `date`, `year`, `month_no`, `month`, `year_month`, `fiscal_year` (September to August) |

`sales_lines` is D18's activity 01 (`order_items` merged with `orders`) after Lab 04 removed `item_id` and `order_ts`. One order has no customer row: `C-0999` (order 101664), as on D18.
