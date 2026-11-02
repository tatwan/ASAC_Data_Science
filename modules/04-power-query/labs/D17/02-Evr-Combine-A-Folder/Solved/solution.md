# Solution · Activity 02: twelve shop files at once

The [activity instructions](../README.md) carry the screens and the click path. This page gives the answers, why the route works, and the same work in SQL.

## The answers

| Step | Value |
|---|---|
| Files in the folder | 13 (12 `.csv` and `notes.txt`) |
| After the `Extension` filter | 12 |
| Rows after combining | 1,901; `Source.Name` has 12 distinct values |
| Rows per file | NK-AMM-01 251 · NK-AMM-02 181 · NK-AMM-03 298 · NK-AQB-01 139 · NK-IRB-01 236 · NK-IRB-02 345 · NK-KRK-01 127 · NK-MDB-01 41 · NK-MFQ-01 46 · NK-POP-01 19 · NK-SLT-01 40 · NK-ZRQ-01 178 |
| Completed Sum of `order_total` | **205,338.00**, the same as activity 01 |
| Bonus: rows without `NK-MFQ-01.csv` | 1,855 |

Every row matches a row of activity 01's `store_sales`: same `order_id`, same store.

## Why the route works

- **Look at the file list before combining.** Combine Files applies one file's steps to all of them, so every file must have the same columns; `notes.txt` does not, so the `Extension` filter keeps it out.
- **`Source.Name` turns the file name into data.** The shop files have no store column; the name is the only place the store code exists. Replacing `.csv` with nothing (whole-cell match off) leaves the code.
- **The query reads the folder at every refresh**, so a new month's or a new shop's file needs no new query (the bonus shows it).
- The most common error: combining before filtering, so the note breaks the combine or adds empty rows.

## The same in SQL (BigQuery)

BigQuery has no folder on your computer to read. Its folder is a Cloud Storage folder, read through an **external table**, and the pseudo-column `_FILE_NAME` plays the part of `Source.Name`. The wildcard `NK-*.csv` does the `Extension` filter's job. (Cloud Storage needs a project with billing, so this one is for reading, not for the sandbox.)

| Power Query | SQL |
|---|---|
| **Get data → Folder** | `CREATE EXTERNAL TABLE ... uris = ['gs://.../store_files/NK-*.csv']` |
| Filter `Extension` to `.csv` | the wildcard `NK-*.csv` matches no `notes.txt` |
| **Combine Files** | one table over every matching file |
| `Source.Name`, `.csv` removed | `REGEXP_EXTRACT(_FILE_NAME, r'(NK-[A-Z]+-\d+)\.csv$')` |

```sql
CREATE OR REPLACE EXTERNAL TABLE nakheel_stores.store_files
OPTIONS (format = 'CSV', uris = ['gs://YOUR_BUCKET/store_files/NK-*.csv'], skip_leading_rows = 1);

-- 1,901 rows, 12 stores; NK-AMM-01 has 251
SELECT REGEXP_EXTRACT(_FILE_NAME, r'(NK-[A-Z]+-\d+)\.csv$') AS store_code,
       COUNT(*) AS orders,
       SUM(IF(status = 'completed', order_total, 0)) AS completed_revenue
FROM nakheel_stores.store_files
GROUP BY store_code
ORDER BY store_code;
```

Without a folder, SQL would need one uploaded table per shop and twelve `SELECT`s joined by `UNION ALL`, each typing its own store code:

```sql
SELECT 'NK-AMM-01' AS store_code, * FROM nakheel_stores.nk_amm_01
UNION ALL
SELECT 'NK-AMM-02' AS store_code, * FROM nakheel_stores.nk_amm_02
-- … ten more, and one more for every new shop
```

That is the work **Combine Files** saves.
