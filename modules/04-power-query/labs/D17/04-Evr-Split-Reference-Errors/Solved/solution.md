# Solution · Activity 04: the store list, first steps

The [activity instructions](../README.md) carry the screens and the click path. This page gives the answers, why each step is there, and the same work in SQL.

## The answers

| Step | Value |
|---|---|
| 1 | `stores_raw`: 12 rows, 6 columns |
| 2 | `stores` has one step, `Source = stores_raw` |
| 3 | `gov_code`, `governorate`, `area`; Abdali reads AM / Amman / Abdali; 9 governorates (Amman 3, Irbid 2, the rest 1 each) |
| 4 | `size.1` as Whole Number: Valid 92% (11), Error 8% (1: Jerash, `unknown`) |
| 5 | 12 rows; Jerash's size `null`; the 11 known sizes add up to **2,880 m²** |

| store_code | store_name | gov_code | governorate | area | size_m2 |
|---|---|---|---|---|---:|
| NK-AMM-01 | Nakheel Abdali | AM | Amman | Abdali | 420 |
| NK-AMM-02 | Nakheel Sweifieh | AM | Amman | Sweifieh | 380 |
| nk-irb-02 | Nakheel Irbid City Centre | IR | Irbid | Irbid | 240 |
| … | … | … | … | … | … |
| NK-JRS-01 | Nakheel Jerash | JA | Jerash | Jerash | null |

Two codes are typed in lower case (`nk-irb-02`, `nk-slt-01`). Nothing here fixes them; activity 06 shows why they matter.

## Why each step is there

- **Reference keeps the raw query as the file is.** `stores` reads `stores_raw` and adds its own steps; a change to `stores_raw` flows through (the bonus). Duplicate would copy the steps and drift apart.
- **One column, one fact.** `governorate - city - area` holds three facts, so it cannot be filtered or charted by governorate until it is split.
- **The error is a message about one value.** `unknown` is not a number; the type change says so in one cell. **Replace Errors** with `null` keeps Jerash's row without inventing a floor area. **Remove Errors** would drop the shop.
- The most common error: **Remove Errors** instead of **Replace Errors**: 11 rows, and Jerash is gone from the store list.

## The same in SQL (BigQuery)

Upload `stores_raw.csv` as `nakheel_stores.stores_raw` (solution 01 lists the uploads). Check its **Schema** tab: BigQuery may rename `governorate - city - area`; use the name you see.

| Power Query | SQL |
|---|---|
| Reference of `stores_raw` | a view that reads `stores_raw`; the table does not change |
| Split Column by ` - `, each occurrence | `SPLIT(col, ' - ')[OFFSET(0)]`, `[OFFSET(1)]`, `[OFFSET(2)]` |
| Split `size` at the left-most space | `SPLIT(size, ' ')[OFFSET(0)]` |
| Change type → Error in one cell | `CAST` stops the query; `SAFE_CAST` gives `NULL` |
| Keep Errors | `WHERE SAFE_CAST(...) IS NULL` |
| Replace Errors with `null` | `SAFE_CAST(...)` keeps the row with `NULL` |

```sql
-- Keep Errors: the one size that will not become a number
SELECT store_code, size
FROM nakheel_stores.stores_raw
WHERE SAFE_CAST(SPLIT(size, ' ')[OFFSET(0)] AS INT64) IS NULL;   -- NK-JRS-01, unknown

-- stores after this activity
CREATE OR REPLACE VIEW nakheel_stores.stores AS
SELECT store_code,
       store_name,
       SPLIT(`governorate - city - area`, ' - ')[OFFSET(0)] AS gov_code,
       SPLIT(`governorate - city - area`, ' - ')[OFFSET(1)] AS governorate,
       SPLIT(`governorate - city - area`, ' - ')[OFFSET(2)] AS area,
       `lat / long`,
       SAFE_CAST(SPLIT(size, ' ')[OFFSET(0)] AS INT64) AS size_m2,
       opened
FROM nakheel_stores.stores_raw;

-- 12 rows, 9 governorates, 2,880 m² over 11 known sizes
SELECT COUNT(*) AS shops, COUNT(DISTINCT governorate) AS governorates,
       SUM(size_m2) AS floor_area, COUNT(size_m2) AS known_sizes
FROM nakheel_stores.stores;
```
