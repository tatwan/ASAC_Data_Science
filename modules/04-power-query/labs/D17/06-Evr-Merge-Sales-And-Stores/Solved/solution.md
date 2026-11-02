# Solution · Activity 06: sales with their store

The [activity instructions](../README.md) carry the screens and the click path. This page gives the answers, why the fix works, and the same work in SQL.

## The answers

| | Rows | Rows with no governorate | Codes with no match |
|---|---:|---:|---|
| Before UPPERCASE | 1,901 | 404 (1,497 match) | NK-IRB-02 345 · NK-SLT-01 40 · NK-POP-01 19 |
| After UPPERCASE | 1,901 | 19 (1,882 match) | NK-POP-01 19 |

Completed revenue by governorate (left outer, after the fix):

| governorate | revenue |
|---|---:|
| Amman | 83,914.50 |
| Irbid | 62,116.50 |
| Aqaba | 20,774.50 |
| Zarqa | 16,134.50 |
| Karak | 8,495.50 |
| Balqa | 5,897.00 |
| Madaba | 3,908.00 |
| Mafraq | 3,239.50 |
| (Blank) | 858.00 |
| **Total** | **205,338.00** |

Before the fix the (Blank) bar was 37,373.00: Irbid City Centre and Salt were in it.

## Why the fix works

- **Text keys must match exactly, case included.** `NK-IRB-02` in the sales and `nk-irb-02` in the list are different text to Power Query. Read the match count before you click **OK**.
- **Fix the key where the problem is.** UPPERCASE in `stores` fixes every query that reads `stores`; a fix in the merged query would fix one result.
- **Left outer keeps every sale.** The stall's 19 orders stay, under (Blank), where someone can see them; the total stays 205,338.00 because each code matches at most one store. Check both the row count and the total.
- The most common error: leaving the temporary `(null)` filter in `store_sales_by_store`, so the chart shows only the (Blank) bar. Delete that **Filtered Rows** step before **Close & Apply**.

## The same in SQL (BigQuery)

Uses the views `store_sales` (solution 01) and `stores` (solution 05). BigQuery compares text with its case, like Power Query, so the same 404 rows fail to match.

| Power Query | SQL |
|---|---|
| Merge Queries as New, **Left Outer** | `LEFT JOIN ... ON s.store_code = t.store_code` |
| The match count in the dialog | `COUNT(t.store_code)`: rows that found a store |
| Expand `governorate`, `area`, `short_name` | list those columns in the `SELECT` |
| UPPERCASE on `stores[store_code]` | `UPPER(store_code)` in the `stores` view |
| (Blank) in the chart | `NULL` governorate, shown here as `'(Blank)'` |

```sql
-- Before the fix: 1,901 sales, 1,497 match
SELECT COUNT(*) AS sales, COUNT(t.store_code) AS matched
FROM nakheel_stores.store_sales AS s
LEFT JOIN nakheel_stores.stores AS t ON s.store_code = t.store_code;

-- The fix, where the problem is: the key in stores
CREATE OR REPLACE VIEW nakheel_stores.stores AS
SELECT UPPER(store_code) AS store_code,
       store_name,
       SUBSTR(store_name, STRPOS(store_name, ' ') + 1) AS short_name,
       SPLIT(`governorate - city - area`, ' - ')[OFFSET(0)] AS gov_code,
       SPLIT(`governorate - city - area`, ' - ')[OFFSET(1)] AS governorate,
       SPLIT(`governorate - city - area`, ' - ')[OFFSET(2)] AS area,
       CAST(SPLIT(`lat / long`, ' / ')[OFFSET(0)] AS FLOAT64) AS latitude,
       CAST(SPLIT(`lat / long`, ' / ')[OFFSET(1)] AS FLOAT64) AS longitude,
       SAFE_CAST(SPLIT(size, ' ')[OFFSET(0)] AS INT64) AS size_m2,
       opened
FROM nakheel_stores.stores_raw;

-- After the fix: completed revenue by governorate; (Blank) 858.00; total 205,338.00
SELECT IFNULL(t.governorate, '(Blank)') AS governorate,
       SUM(s.order_total) AS revenue
FROM nakheel_stores.store_sales AS s
LEFT JOIN nakheel_stores.stores AS t ON s.store_code = t.store_code
WHERE s.status = 'completed'
GROUP BY governorate
ORDER BY revenue DESC;
```

D18 activity 07 looks at the other side: Microsoft says a Power BI model's relationships compare text without case, unlike Power Query and SQL.
