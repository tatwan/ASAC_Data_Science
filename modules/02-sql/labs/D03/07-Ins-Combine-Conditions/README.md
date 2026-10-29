# Combine conditions

In this activity, you will combine conditions with `AND` and `OR`, see why brackets matter, and use four shortcuts: `IN`, `BETWEEN`, `LIKE` and `DISTINCT`.

**Time:** 10 minutes · **Data:** `D03` tables (activity 01) · **File:** `Solved/combine_conditions.sql`

## Instructions

1. Open `Solved/combine_conditions.sql`. Run query 1. `AND`: both conditions must be true. (`OR`: at least one must be true.)

2. The question: "Completed orders from C-118 or C-204." Run query 2, written without brackets. It returns 4 rows, including C-118's cancelled order 1002. `AND` is worked out before `OR`, so the query reads "C-118 with any status, or C-204 and completed".

3. Run query 3. Brackets around the `OR` say what you mean, and the answer is right: 3 rows.

4. Run query 4. `IN ('C-118', 'C-204')` is a short way to write several `OR`s on one column. Run query 5: `IN` also catches the three spellings of retail.

5. Run query 6. `BETWEEN '2026-08-01' AND '2026-08-11'` includes both end dates.

6. Run query 7. `LIKE 'Omar%'` matches a pattern: `%` stands for any characters, including none. Then run query 8. `LIKE` is case-sensitive: `'%Shoe%'` does not find "Trail shoe", so it returns nothing.

7. Run query 9. `SELECT DISTINCT customer_id` shows each value once: five orders, three different customer IDs.

## Check yourself

| Query | Rows returned | One value to check |
|---|---:|---|
| 1 | 2 | orders 1004, 1005 |
| 2 | 4 | includes cancelled order 1002 |
| 3 | 3 | orders 1001, 1003, 1005 |
| 4 | 3 | the same as query 3 |
| 5 | 3 | C-118, C-204, C-377 |
| 6 | 3 | orders 1001, 1002, 1003 |
| 7 | 2 | C-204, C-401 |
| 8 | 0 | no rows |
| 9 | 3 | C-118, C-204, C-401 in some order |

## References

The D03 tables, course-owned synthetic data, 19 September 2026.
