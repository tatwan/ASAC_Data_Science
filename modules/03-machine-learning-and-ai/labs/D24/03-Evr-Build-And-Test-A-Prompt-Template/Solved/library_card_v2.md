# Library card · Nakheel SQL questions (solved)

| Field | Value |
|---|---|
| Name | nakheel-sql-question |
| Version | 2 |
| Owner | (your name) |
| Purpose | Turn a business question about Nakheel orders into one BigQuery SQL query |
| Variables | `{question}`, `{definition}`, `{check}` |

## The template, version 2

```text
SETTING
BigQuery SQL. Dataset: nakheel. Return one query.

DATA
- orders(order_id, customer_id, order_date, channel, status, order_total): one row is one order
- order_items(order_id, product_id, qty, price): one row is one order line
- products(product_id, category): one row is one product
Values: status is 'completed', 'cancelled' or 'pending'. channel is 'store' or 'online'.

PERIOD
Orders from 1 September 2024 to 31 August 2026. The data ends on 31 August 2026.
Measure "the last N days" back from 31 August 2026, never from today.

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
| 1 | Average value of a completed order | 114.05 | Pass | Pass |
| 2 | Completed revenue from the online channel | 110,685.50 | Pass | Pass |
| 3 | Customers with at least one completed order | 452 | Pass | Pass |
| 4 | Customers with no completed order in the last 90 days | 280 | Fail: counted back from `CURRENT_DATE()` (447 on 26 November 2026) | Pass |

Usual results. Assistants differ: if test 1, 2 or 3 failed for you, the fix also goes into the template (for example, a rule "after a join to order_items, count orders with COUNT(DISTINCT order_id)"), with its own line in the change log.

## Change log

| Version | Date | Change | Fixes |
|---|---|---|---|
| 1 | 26 November 2026 | First version | |
| 2 | 26 November 2026 | Added PERIOD: the data ends on 31 August 2026; "last N days" counts back from that date | Test 4 |

## Queries that pass

```sql
-- Test 1: 114.05
SELECT ROUND(SUM(i.qty * i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_completed_order
FROM nakheel.orders AS o
JOIN nakheel.order_items AS i ON i.order_id = o.order_id
WHERE o.status = 'completed';

-- Test 2: 110,685.50
SELECT SUM(i.qty * i.price) AS online_revenue
FROM nakheel.orders AS o
JOIN nakheel.order_items AS i ON i.order_id = o.order_id
WHERE o.status = 'completed' AND o.channel = 'online';

-- Test 3: 452
SELECT COUNT(DISTINCT customer_id) AS customers
FROM nakheel.orders
WHERE status = 'completed';

-- Test 4: 280
WITH last_order AS (
  SELECT customer_id, MAX(order_date) AS last_order_date
  FROM nakheel.orders
  WHERE status = 'completed'
  GROUP BY customer_id
)
SELECT COUNT(*) AS lapsed_customers
FROM last_order
WHERE last_order_date < DATE_SUB(DATE '2026-08-31', INTERVAL 90 DAY);
```
