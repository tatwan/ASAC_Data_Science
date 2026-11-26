# Activity 02 · the errors named

## Answer A

- **It returned** 6,951 completed orders. **It should be** 2,771. The revenue, 316,023.50, is right.
- **The error:** after the join, one row is one order line, not one order. `COUNT(*)` counts the 6,951 lines of the completed orders. The revenue is right because `qty * price` belongs to the line, so adding it over the lines is correct. A right number on the same row made the wrong one look checked.
- **The fix:** count each order once.

```sql
SELECT
  COUNT(DISTINCT o.order_id) AS completed_orders,
  SUM(i.qty * i.price) AS revenue
FROM nakheel.orders AS o
JOIN nakheel.order_items AS i
  ON i.order_id = o.order_id
WHERE o.status = 'completed';
```

Result: 2,771 and 316,023.50.

- **A follow-up that works:** "The revenue matches, but the count is 6,951, which is the number of order lines. Completed orders are 2,771. After the join one row is one line, so count distinct order_id."
- **Add to the prompt next time:** "Check: 2,771 completed orders and 316,023.50 revenue." Or ask for each number in its own query.

## Answer B

- **It returned** 447 of 452 customers (26 November 2026), and 452 from 30 November 2026. **It should be** 280.
- **The error:** the 90 days are counted back from `CURRENT_DATE()`, the day the query runs. The data ends on 31 August 2026, so almost every customer looks lapsed, and the count grows every day although no order changed. The prompt never said when the data ends, so the assistant could not know.
- **The fix:** count back from the last date in the data.

```sql
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

Result: 280.

- **A follow-up that works:** "This counts back from today, but the data ends on 31 August 2026, so 447 of 452 customers look lapsed. Count the 90 days back from 31 August 2026."
- **Add to the prompt next time:** the period the data covers ("orders from 1 September 2024 to 31 August 2026") and the date to measure from.

## Bonus

Take the end date from the data, so the query is right for any snapshot:

```sql
WHERE last_order_date < DATE_SUB((SELECT MAX(order_date) FROM nakheel.orders), INTERVAL 90 DAY)
```

Result: 280.
