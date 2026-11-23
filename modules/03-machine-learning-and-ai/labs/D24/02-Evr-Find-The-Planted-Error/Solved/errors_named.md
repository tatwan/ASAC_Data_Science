# Activity 02 · the errors named

## Answer A · SQL

- **It returned** 3,000. **It should be** 2,771.
- **The error:** the query counts every row of `nakheel.orders`. One row is one order of any status, and the question asked for completed orders. The column is named `completed_orders`, which makes the result look right.
- **The fix:**

```sql
SELECT COUNT(*) AS completed_orders
FROM nakheel.orders
WHERE status = 'completed';
```

- **A follow-up that works:** "This returns 3,000, which is every order. Completed orders are 2,771. Count only rows where status = 'completed'."

## Answer B · DAX

- **It shows** 100.0% on every row. **Outerwear should be** 24.3%.
- **The error:** on the Outerwear row, the category filter applies to the top number and to the bottom number, so the measure divides 76,637.00 by 76,637.00. A measure divided by itself inside the same filters is always 1.
- **The fix** (D19, percent of total):

```dax
Share of Revenue =
DIVIDE(
    [Completed Revenue],
    CALCULATE([Completed Revenue], REMOVEFILTERS(products))
)
```

- **A follow-up that works:** "Every row shows 100%. Outerwear should be 24.3% of 316,023.50. The bottom number must ignore the category filter."

## Bonus

`REMOVEFILTERS`, inside `CALCULATE`.
