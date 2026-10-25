-- D10 · Lab (after class): Best sellers and trends

-- C1. Products ranked by units sold inside each category, with RANK and DENSE_RANK.
--     category, product_name, units, unit_rank, unit_dense_rank. ORDER BY category, unit_rank, product_name.
WITH product_units AS (

)
SELECT *
FROM product_units;


-- C2. Each channel by month: change on the month before, and a running total.
--     channel, month, revenue, change, running_total. ORDER BY channel, month.


-- C2 audit: the last running total of each channel against the channel's completed revenue.
--     channel, revenue; GROUP BY channel, ORDER BY channel.


-- C3. The top three products by units in each category, with their share of the category's units.
--     category, product_name, units, unit_rank, share_of_category_units (rounded to 1 decimal).
--     ORDER BY category, unit_rank.


-- More practice (not checked). Each customer's most recent completed order.
--     customer_id, order_id, order_date, order_total. ORDER BY customer_id.


-- More practice, optional. The city rule as a function: CREATE TEMP FUNCTION clean_city(city STRING) AS ( ... );
