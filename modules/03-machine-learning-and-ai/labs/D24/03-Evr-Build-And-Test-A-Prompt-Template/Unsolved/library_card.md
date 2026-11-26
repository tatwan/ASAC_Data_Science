# Library card · Nakheel SQL questions

| Field | Value |
|---|---|
| Name | nakheel-sql-question |
| Version | 1 |
| Owner | (your name) |
| Purpose | Turn a business question about Nakheel orders into one BigQuery SQL query |
| Variables | `{question}`, `{definition}`, `{check}` |

## The template, version 1

```text
SETTING
BigQuery SQL. Dataset: nakheel. Return one query.

DATA
- orders(order_id, customer_id, order_date, channel, status, order_total): one row is one order
- order_items(order_id, product_id, qty, price): one row is one order line
- products(product_id, category): one row is one product
Values: status is 'completed', 'cancelled' or 'pending'. channel is 'store' or 'online'.

RULES
- Revenue = qty * price, from order_items.
- Only orders with status = 'completed', unless the task says otherwise.

TASK
{question}

DEFINITION
{definition}

CHECK
{check}

HOW TO ANSWER
First list your assumptions. Then give the SQL with a two-line explanation.
```

## Tests

| Test | Question | Known answer | Version 1 | Version 2 |
|---|---|---:|---|---|
| 1 | Average value of a completed order | 114.05 | | |
| 2 | Completed revenue from the online channel | 110,685.50 | | |
| 3 | Customers with at least one completed order | 452 | | |
| 4 | Customers with no completed order in the last 90 days | 280 | | |

## Change log

| Version | Date | Change | Fixes |
|---|---|---|---|
| 1 | 26 November 2026 | First version | |
| 2 | | | |
