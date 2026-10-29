# Filter rows with WHERE

In this activity, you will filter rows with `WHERE`, then meet two filters written the way most people would write them. BigQuery refuses to run the first one. The second runs and gives the wrong answer, with no warning.

**Time:** 8 minutes · **Data:** `D03.orders`, `D03.order_items`, `D03.customers` (activity 01) · **File:** `Solved/where_and_null.sql`

## Instructions

1. Open `Solved/where_and_null.sql`. Run queries 1 to 3. `WHERE` keeps the rows where the condition is true. Text goes in single quotes (`'completed'`); numbers do not (`price > 20`). The comparison operators are `=`, `<>` (not equal), `>`, `>=`, `<` and `<=`.

2. Run query 4, `WHERE city = NULL`. It does not run: BigQuery stops with `Operands of = cannot be literal NULL`. `NULL` means "no value", and a comparison with "no value" is never true, not even `NULL = NULL`, so this filter could never keep a row.

3. Run query 5, the fix: `IS NULL`. Use `IS NULL` and `IS NOT NULL` whenever you test for an empty value.

4. Run query 6, `WHERE segment = 'retail'`. It returns one customer, but there are three retail customers.

5. Run query 7 to see why. It shows `customer_id` and `segment`, sorted by `segment` (`ORDER BY segment`). They are typed `Retail`, `retail` and `RETAIL ` (with a space at the end). Text comparison is exact. Look at every spelling in a column before you filter on it.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 4 | orders 1001, 1003, 1004, 1005 |
| 2 | 4 | item 9004, price 42.00 (BigQuery shows `42.0`) |
| 3 | 4 | no cancelled order |
| 4 | error | `Operands of = cannot be literal NULL` |
| 5 | 1 | C-455, Sami Odeh |
| 6 | 1 | C-204 |
| 7 | 5 | `RETAIL ` first: capital letters sort before small ones |

## BigQuery does this differently

In PostgreSQL, SQL Server and MySQL, `WHERE city = NULL` runs, returns 0 rows and gives no warning. BigQuery checks the query before it runs, sees a comparison with the word `NULL` that can never be true, and stops with an error. The rule is the same in every database; BigQuery tells you sooner. It cannot catch every case: `WHERE city = other_city`, where one side happens to be empty, still leaves those rows out silently. That is why `IS NULL` is the habit to learn, not the error message.

Source: GoogleSQL for BigQuery, [Comparison operators](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/operators#comparison_operators) and [`IS` operators](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/operators#is_operators). The error text is BigQuery's own.

## References

The D03 tables, course-owned synthetic data, 19 September 2026.
