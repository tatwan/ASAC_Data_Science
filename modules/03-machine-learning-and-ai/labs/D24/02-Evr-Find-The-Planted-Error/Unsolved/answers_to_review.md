# Activity 02 · two answers to review

These answers were written for the course in the style of an AI assistant. The prompts are the kind you learned to write in Activity 01: the tables, the columns, what one row is, and the task. Each query runs. Each one is wrong.

## Answer A

**The prompt:**

```text
BigQuery SQL. Dataset: nakheel.

Tables:
- orders(order_id, customer_id, order_date, status, order_total): one row is one order
- order_items(order_id, product_id, qty, price): one row is one order line

Task: how many completed orders do we have, and what is their revenue?
Revenue = qty * price. Only orders with status = 'completed'.

Explain the query in two lines, then give the SQL.
```

**The assistant's answer:**

> The query joins each order line to its order so it can keep only completed orders. It then counts the orders and adds up `qty * price` for their revenue.

```sql
SELECT
  COUNT(*) AS completed_orders,
  SUM(i.qty * i.price) AS revenue
FROM nakheel.orders AS o
JOIN nakheel.order_items AS i
  ON i.order_id = o.order_id
WHERE o.status = 'completed';
```

**It returned:**

| completed_orders | revenue |
|---:|---:|
| 6,951 | 316,023.50 |

## Answer B

**The prompt:**

```text
BigQuery SQL. Dataset: nakheel.

Tables:
- orders(order_id, customer_id, order_date, status, order_total): one row is one order

Task: how many customers have not placed a completed order in the last 90 days?
Count only customers who have at least one completed order.

Explain the query in two lines, then give the SQL.
```

**The assistant's answer:**

> The query finds each customer's most recent completed order, then counts the customers whose last order is more than 90 days ago.

```sql
WITH last_order AS (
  SELECT customer_id, MAX(order_date) AS last_order_date
  FROM nakheel.orders
  WHERE status = 'completed'
  GROUP BY customer_id
)
SELECT COUNT(*) AS lapsed_customers
FROM last_order
WHERE last_order_date < DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
```

**It returned** (run on 26 November 2026):

| lapsed_customers |
|---:|
| 447 |
