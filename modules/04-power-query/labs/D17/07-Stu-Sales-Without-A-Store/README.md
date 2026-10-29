# Who has no match? Anti joins

In this activity, you will use two more join kinds to answer the questions an auditor asks after any merge: which sales have no store, which stores have no sales, and what an inner merge would have hidden.

**In class:** on your own · **Data:** `store_sales` and `stores` (after the UPPERCASE fix in activity 06) · **Tool:** Power BI Desktop or the browser

## The story

Head office's auditor is not satisfied with a chart that has a **(Blank)** bar. She wants the list of sales that belong to no store in the list, the list of stores that sold nothing, and to know how much an inner merge would have left out. On D06 you found customers who never ordered with a `LEFT JOIN … WHERE … IS NULL`. Power Query has join kinds for that.

## Before you start

You need `store_sales` and `stores` from activities 01 to 06, with `stores`' `store_code` in capitals.

## Instructions

1. Which sales have no store in the store list? How many, from which store code, and how much completed revenue?

    Translate: **Merge Queries as New**, `store_sales` on top, `stores` below, both on `store_code`, **Join Kind:** **Left Anti (rows only in first)**. Name the query `sales_without_store`.

2. Which store in the list has no sales at all?

    Translate: the same merge with **Right Anti (rows only in second)**. The columns from `store_sales` are empty; expand `store_code` and `store_name` from the `stores` column, with **Use original column name as prefix** left ticked (`store_sales` already has a `store_code` column).

3. If activity 06 had used **Inner (only matching rows)**, how many rows would the merged table have, and what would the governorate chart add up to? Which join answers "revenue by governorate" honestly?

    Translate: one more merge, **Inner**, named `store_sales_inner`; **Close & Apply**, then a card with `order_total` (Sum) **from `store_sales_inner`**, filter `status` = completed. A card on `store_sales` would still show 205,338.00.

## Check yourself

| Question | Rows returned | One value to check |
|---|---:|---|
| 1 | 19 | all `NK-POP-01`; completed revenue 858.00 |
| 2 | 1 | `NK-JRS-01`, Nakheel Jerash |
| 3 | 1,882 | completed total 204,480.00 |

A different count is information, not failure. If question 1 returns more than 19 rows, check that the UPPERCASE step from activity 06 is in `stores`.

## Hint

Left anti is the SQL you wrote on D06:

```sql
SELECT s.*
FROM store_sales AS s
LEFT JOIN stores AS st ON s.store_code = st.store_code
WHERE st.store_code IS NULL;
```

## Bonus

Untick **Enable load** on the three audit queries from this activity: they answer a question once, and the model does not need them.

## References

Nakheel Retail store files, synthetic course data; see [`shared/datasets/nakheel_stores`](../../../../../shared/datasets/nakheel_stores/README.md). Button and menu names are those of Power BI Desktop in October 2026. Power BI changes every month: if a name on your screen differs, look in the same tab or menu. Microsoft: [Left anti join](https://learn.microsoft.com/en-us/power-query/merge-queries-left-anti), [Merge queries overview](https://learn.microsoft.com/en-us/power-query/merge-queries-overview).
