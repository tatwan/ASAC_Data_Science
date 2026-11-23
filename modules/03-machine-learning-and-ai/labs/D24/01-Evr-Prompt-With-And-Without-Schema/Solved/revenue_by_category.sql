-- Activity 01 · reference query: completed revenue by category
-- Expected: 6 rows; Outerwear 76,637.00 first; the revenue column adds up to 316,023.50.
SELECT
  p.category,
  SUM(i.qty * i.price) AS revenue
FROM nakheel.order_items AS i
INNER JOIN nakheel.orders AS o
  ON i.order_id = o.order_id
INNER JOIN nakheel.products AS p
  ON i.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- The usual wrong answer: order_total repeats on every line of an order.
-- This returns 988,971.50, about 3.1 times the real figure.
-- SELECT SUM(o.order_total)
-- FROM nakheel.orders AS o
-- JOIN nakheel.order_items AS i ON i.order_id = o.order_id
-- WHERE o.status = 'completed';
