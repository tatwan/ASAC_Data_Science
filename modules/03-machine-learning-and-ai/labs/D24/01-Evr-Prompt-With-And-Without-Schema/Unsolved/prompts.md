# Activity 01 · the two prompts

## Prompt 1 · short

```text
Write SQL for revenue by category.
```

## Prompt 2 · with the context (send it in a new chat)

```text
BigQuery SQL. Dataset: nakheel.

Tables:
- orders(order_id, status, order_total): one row is one order
- order_items(order_id, product_id, qty, price): one row is one order line
- products(product_id, category): one row is one product

Task: completed revenue by category. Revenue = qty * price.
Only orders with status = 'completed'.

Expected: 6 rows. The total is 316,023.50.

Explain the joins in two lines, then give the SQL.
```
