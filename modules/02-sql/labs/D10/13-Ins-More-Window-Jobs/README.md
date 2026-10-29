# Four more jobs for a window

In this activity, you will see what window functions are used for at work beyond ranking: removing duplicates, measuring the time between events, splitting rows into equal groups, and smoothing a trend.

**Time:** 10 minutes · **Data:** `nakheel.customers`, `nakheel.orders` (D04 activity 03) · **File:** `Solved/more_window_jobs.sql`

Today you have used three families of window function. This step names all three, then shows four more jobs, each with one short query.

## Instructions

1. **The three families.** Every window function belongs to one of them.

    | Family | Functions | What each row gets |
    |---|---|---|
    | Aggregate | `SUM`, `AVG`, `COUNT`, `MIN`, `MAX` with `OVER` | a total or average of its window |
    | Ranking | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `PERCENT_RANK` | its position in the window |
    | Value | `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE` | a value from another row of the window |

    The jobs you have done today: a share of a total (2.2), the top N in each group (3.2), a running total and year to date (4.1), the change on the period before (4.1). Four more follow.

2. **One row per key: removing duplicates.** Nakheel's customers table has one person twice: Omar Nasser of Irbid, as C-1204 (3 completed orders) and C-1401 (18). To keep one row per person, number each person's accounts, the busiest first, and keep number 1:

    ```sql
    QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_name, city
                               ORDER BY completed_orders DESC, customer_id) = 1
    ```

    The `customer_orders` CTE before it is one row per account with its completed orders, built the way you built the D08 customer summary. The answer shows `customer_id`, `customer_name`, `city` and `completed_orders`, sorted by `customer_id`. You should see 499 rows from 500 accounts; C-1401 stays.

    The same pattern answers "What was each customer's most recent order?": `PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC`, keep number 1; show `customer_id`, `order_id`, `order_date` and `order_total`, sorted by `customer_id`. For completed orders you should see 452 rows, one per customer who has bought.

3. **Time between events.** `LAG` reads the same customer's previous order date; `DATE_DIFF` counts the days between:

    ```sql
    LAG(order_date) OVER (PARTITION BY customer_id
                          ORDER BY order_date, order_id) AS previous_order_date
    ```

    then, in the next step, `DATE_DIFF(order_date, previous_order_date, DAY) AS days_since_previous`, with `customer_id`, `order_id`, `order_date` and `previous_order_date`, sorted by customer, then date (`ORDER BY customer_id, order_date, order_id`). In BigQuery the later date comes first.

    You should see 2,771 rows, one per completed order. Each customer's first order has no order before it, so its gap is `NULL`: 2,319 orders have a gap, and the average gap is 60.8 days (a summary query: `COUNT(*) AS orders`, `COUNT(days_since_previous) AS gaps`, and the average rounded to 1 decimal, `AS average_gap_days`). On D12 a model will predict whether a customer orders again; this gap is the kind of column it learns from.

4. **Buckets.** `NTILE(4)` cuts the rows, in the window's order, into four groups of equal size:

    ```sql
    NTILE(4) OVER (ORDER BY revenue DESC, customer_id) AS quartile
    ```

    Then group by `quartile`: `COUNT(*) AS customers`, `revenue` rounded to 2 decimals and `share_pct` rounded to 1 decimal, sorted by `quartile`. You should see 4 rows of 113 customers each. The top quarter brings 254,613.00, 80.6% of completed revenue; the bottom quarter brings 1.8%. On D13 a model will find customer groups by itself; quartiles are the simplest version, chosen by you.

5. **A moving average.** A frame, `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`, makes each month's window that month and the two before it:

    ```sql
    AVG(revenue) OVER (ORDER BY month
                       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3m
    ```

    Show `month`, `revenue` and `moving_avg_3m`, sorted by month. You should see 24 rows. April 2026 is 20,237.00 on its own and 16,016.00 smoothed. September 2024 has no months before it, so its average is itself. Forecasting on D14 starts from smoothed lines like this one.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 2 | 499 | C-1401 Omar Nasser kept, 18 orders; C-1204 gone |
| 2, latest order | 452 | one row per customer who has bought |
| 3 | 2,771 | first order of each customer: gap NULL |
| 3, summary | 1 | 2,771 orders · 2,319 gaps · 60.8 days |
| 4 | 4 | quartile 1: 113 customers, 254,613.00, 80.6% |
| 5 | 24 | April 2026: 20,237.00 and 16,016.00 |

## Reference

`LEAD` reads the row after; `FIRST_VALUE` and `LAST_VALUE` read the first and last row of the window; `PERCENT_RANK` gives a row's position from 0 to 1. Recognise them when you see them; this course does not practise them.

## References

Nakheel Retail, course-owned synthetic data generated 24 September 2026. See [the dataset README](../../../../../shared/datasets/nakheel/README.md).
