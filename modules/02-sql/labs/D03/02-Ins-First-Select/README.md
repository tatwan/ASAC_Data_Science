# Your first SELECT

In this activity, you will run the shortest useful query, every column of every row from one table, and learn what each part of the table's name means.

**Time:** 8 minutes · **Data:** `D03.orders`, `D03.order_items` (activity 01) · **File:** `Solved/first_select.sql`

## Instructions

1. Open `Solved/first_select.sql`. In query 1, replace `your-project-id` with your own project ID (it is shown next to the project name in the BigQuery **Explorer**).

    `SELECT *` means "every column". `FROM` names the table. A full table name is `project.dataset.table`, written in backticks because project IDs contain hyphens: `` `your-project-id.D03.orders` ``.

2. Before you press **Run**, read the grey line above the results: "This query will process … when run." That is the bytes estimate. Read it every time. On a five-row table it is tiny; on a public table it can be gigabytes.

3. Say how many rows you expect. `D03.orders` has five orders, so five rows. Run query 1.

4. Run query 2. The query runs inside your project, so you can leave the project part out and write `D03.orders`. The result is the same.

5. Predict the row count of `D03.order_items`, then run query 3. Without `ORDER BY`, BigQuery can return the rows in any order, so yours may not start with item 9001.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 5 | order 1001, C-204, completed |
| 2 | 5 | the same as query 1 |
| 3 | 12 | includes item 9001, order 1001 |

## References

The D03 tables, course-owned synthetic data, 19 September 2026.
