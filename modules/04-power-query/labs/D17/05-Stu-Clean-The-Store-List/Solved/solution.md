# Solution · Activity 05: finish the store list

The [activity instructions](../README.md) carry the screens and the questions. This page gives the answers, why each step is there, and the same work in SQL.

## The answers

| Question | Answer |
|---|---|
| 1 | `latitude` and `longitude`, Decimal Number, no errors; Abdali 31.9632 / 35.9106 |
| 2 | `short_name` on all 12 rows: Abdali, Sweifieh, Tabarbour, University Street, Irbid City Centre, New Zarqa, Aqaba, Karak, Salt, Madaba, Mafraq, Jerash |
| 3 | Jerash opens **15 September 2026**, after the sales data ends |
| 4 | Amman 420 + 380 + 260 = **1,060 m²**; all shops **2,880 m²** over the 11 with a known size |

| store_code | short_name | governorate | latitude | longitude | size_m2 | opened |
|---|---|---|---:|---:|---:|---|
| NK-AMM-01 | Abdali | Amman | 31.9632 | 35.9106 | 420 | 2019-03-14 |
| NK-IRB-01 | University Street | Irbid | 32.539 | 35.856 | 310 | 2020-02-10 |
| nk-irb-02 | Irbid City Centre | Irbid | 32.5556 | 35.85 | 240 | 2023-09-01 |
| NK-JRS-01 | Jerash | Jerash | 32.2808 | 35.8993 | null | 2026-09-15 |

Floor area by governorate: Amman 1,060 · Irbid 550 · Aqaba 350 · Zarqa 290 · Karak 180 · Balqa 160 · Madaba 150 · Mafraq 140 · Jerash unknown.

## Why each step is there

- **The delimiter is space, slash, space.** Typed as `/` alone, it leaves a space at the end of `latitude` and the start of `longitude`.
- **The rule for `short_name` is "everything after the first word".** Two examples, one of them with several words (`University Street`), are what teach Column From Examples that rule; one example of a one-word name could teach "the last word", which breaks `Irbid City Centre`.
- **Locale decides how `31.9632` is read.** On a computer set to a decimal comma it becomes 319632 or an error; **Change Type → Using Locale → English (United States)** fixes it.
- **Say what a total leaves out.** 2,880 m² is eleven shops; Jerash's size is unknown, not zero.

## The same in SQL (BigQuery)

This view replaces activity 04's. It reads the uploaded `stores_raw` (solution 01); check the **Schema** tab for the names BigQuery gave `governorate - city - area` and `lat / long`.

| Power Query | SQL |
|---|---|
| Split `lat / long` by ` / ` | `SPLIT(col, ' / ')[OFFSET(0)]` and `[OFFSET(1)]` |
| Decimal Number (Using Locale) | `CAST(... AS FLOAT64)`; BigQuery always reads a decimal point |
| Column From Examples → `Text.AfterDelimiter([store_name], " ")` | `SUBSTR(store_name, STRPOS(store_name, ' ') + 1)` |

```sql
CREATE OR REPLACE VIEW nakheel_stores.stores AS
SELECT store_code,
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

-- Question 4: floor area by governorate (Amman 1,060), and the whole (2,880)
SELECT governorate, SUM(size_m2) AS floor_area
FROM nakheel_stores.stores
GROUP BY governorate
ORDER BY floor_area DESC;

SELECT SUM(size_m2) AS floor_area, COUNT(size_m2) AS shops_with_a_size
FROM nakheel_stores.stores;
```
