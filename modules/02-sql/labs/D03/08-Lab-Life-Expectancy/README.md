# Lab: Life expectancy

In this lab, you will load a real public dataset into your own project and use `SELECT`, `WHERE` and `ORDER BY` to answer three questions about how long people live, including one where the obvious query gives a misleading answer.

**Time:** 45 minutes, TA-led · **Data:** `Resources/life_expectancy.csv` → `owid.life_expectancy_data` (you upload it in C1, steps 1–3) · **Starter:** `Unsolved/life_expectancy.sql`

**Before you start:** you have a BigQuery project with the `D03` dataset from today. If your `D03` upload did not work, you can still do this lab: it uses a new dataset.

**What you hand in:** nothing. Save your `.sql` file with its comment blocks filled in. Assignment 1, issued on D09 (Sunday 11 October), asks you to choose queries from your saved `.sql` files.

## The data

Our World in Data publishes life expectancy for every country and region, year by year. The chart is here: [ourworldindata.org/grapher/life-expectancy](https://ourworldindata.org/grapher/life-expectancy). The course copy has one row per place per year from 1950 to 2023.

| Column | Meaning |
|---|---|
| `entity` | Country, territory, region or group, for example `Jordan` or `Africa` |
| `code` | Country code, for example `JOR`. Some rows have an `OWID_` code, and some have none |
| `year` | Calendar year |
| `life_expectancy` | How many years a baby born that year would live on average, at that year's death rates |

## How to write your answers

Open `Unsolved/life_expectancy.sql` in BigQuery (or copy it into a new query tab). Each question has a comment block. Fill in its three blank lines (One row is, Result check, Interpretation), not only the query:

```sql
-- ============================================================
-- Q2  How has life expectancy in Jordan changed since 1950?
-- One row is: Jordan in one year
-- Result check: 74 rows; 1950 is 40.8736
-- Interpretation: Jordan gained about 37 years of life expectancy in 73 years.
-- ============================================================
```

## C1 · Load the data and check what one row is

1. Save [`Resources/life_expectancy.csv`](Resources/life_expectancy.csv) to your laptop. On GitHub, open the file and use **Download raw file**. In a zip, the file is already inside the activity folder.
2. Create a dataset called `owid` in **Multi-region US**.
3. In Explorer, choose **Create table** from the `owid` dataset's **⋮** menu. Set **Create table from** to **Upload** and select `life_expectancy.csv`. Name the table `life_expectancy_data`, not `life_expectancy` ([why](#bigquery-note-a-table-and-a-column-with-the-same-name)), tick **Auto detect**, set **Header rows to skip** to `1` under Advanced options, then click **Create table**. These are the same controls you used in the [D03 dataset activity](../01-Evr-Create-Your-Dataset/README.md).
4. Open the Details tab. The table should have **19,314** rows.
5. Open the Schema tab. `year` should be `INTEGER` and `life_expectancy` `FLOAT`.
6. Write down what you think one row is. Then check it: ask for Jordan in 2023, showing `entity`, `code`, `year` and `life_expectancy`. If one row is one place in one year, you get exactly one row.

**Checkpoint C1:** the table has 19,314 rows, and your Jordan 2023 query returns one row.

## C2 · Answer two questions

7. **Q2.** "How has life expectancy in Jordan changed since 1950? Show me every year, oldest first."

    Translate: rows for `Jordan`, columns `year` and `life_expectancy`, sorted by `year`.

8. **Q3.** "Which ten places had the highest life expectancy in 2023?"

    Translate: rows for 2023, columns `entity`, `code` and `life_expectancy`, sorted by `life_expectancy`, largest first, the first ten.

**Checkpoint C2:** both queries run, and your results match the Check yourself table.

## C3 · Why are there 261 countries?

A colleague runs your 2023 query without `LIMIT` and writes back: "There are 193 UN member states. Why does 2023 have 261 rows?"

9. **C3a.** Show every row for 2023, with `entity`, `code` and `life_expectancy`. Confirm 261 rows. Scroll through them: which entities are not countries?
10. **C3b.** Show `entity` and `code` for the 2023 rows where `code` is empty. What kind of entity has no code?
11. **C3c.** Remove those rows, keeping the C3a columns. How many are left?
12. **C3d.** Search the result for `World`. It is still there. Show `entity` and `code` for the 2023 rows whose `code` starts with `OWID`. What are they?
13. **C3e.** Write one query that keeps countries and territories only, with `entity`, `code` and `life_expectancy`, highest life expectancy first. One of the `OWID_` rows is a country: keep it.
14. In your interpretation line, explain why your final count is still above 193.

**Checkpoint C3:** your final query returns 237 rows, and your interpretation explains the difference from 193.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| C1 | 1 | Jordan 2023: 77.8145 |
| Q2 | 74 | first row 1950, 40.8736; last row 2023, 77.8145 |
| Q3 | 10 | Monaco first (86.3724); Australia tenth (83.9228). Hong Kong is third: is it a country? C3 comes back to this |
| C3a | 261 | Africa appears, with code `OWID_AFR` |
| C3b | 15 | Americas has no code |
| C3c | 246 | World is still in the list |
| C3d | 10 | Kosovo has code `OWID_KOS` |
| C3e | 237 | Monaco is still first |

If a count differs, check the year first. For C3, check which regions your condition still includes.

## Hint

For step 12, `code LIKE 'OWID%'` finds codes that start with `OWID`. For step 13, `code NOT LIKE 'OWID%'` keeps the codes that do not start with `OWID`. You also need `AND` and `OR` in one `WHERE`, so use brackets.

## Stretch card

Not required, not checked. BigQuery's public dataset `bigquery-public-data.thelook_ecommerce.orders` is much larger than anything you uploaded. Type each query below, **do not run it**, and write down the bytes estimate shown above the results area ("This query will process …").

```sql
SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders`;
SELECT order_id, status FROM `bigquery-public-data.thelook_ecommerce.orders`;
SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders` LIMIT 10;
```

Which change made the estimate smaller: naming columns, or `LIMIT`? What does that tell you about how BigQuery stores a table?

## More practice

**Not checked and not submitted.** For anyone who wants more. The Solved file includes these, and nothing in D04 assumes you did them.

- P1 "Compare Jordan with its neighbours in 2023: Egypt, Iraq, Lebanon, Palestine, Saudi Arabia and Syria. Highest first." Show `entity` and `life_expectancy`.
- P2 "Which countries had a life expectancy below 60 in 2023?" Use your C3e filter for countries. Show `entity` and `life_expectancy`.
- P3 "Which ten countries had the lowest life expectancy in 1950?" Use your C3e filter for countries. Show `entity` and `life_expectancy`, sorted by `life_expectancy`, smallest first, the first ten.
- P4 "In which year did Japan first pass 80?" Show `year` and `life_expectancy`, sorted by `year`, oldest first, the first row only (`LIMIT 1`).
- P5 "Which places have a name starting with 'South'? Use 2023 only." Show `entity` and `code`.
- P6 "Between 2015 and 2023, in which years was Jordan below 76?" Show `year` and `life_expectancy`.

## Check yourself: more practice

| Question | Rows returned | One value to check |
|---|---:|---|
| P1 | 7 | Saudi Arabia first, 78.7321 |
| P2 | 6 | Nigeria lowest, 54.4623 |
| P3 | 10 | North Korea lowest, 14.2015 (the Korean War) |
| P4 | 1 | 1996 |
| P5 | 3 | South Africa, South Korea, South Sudan |
| P6 | 4 | lowest is 2021, 74.2042 |

## If something goes wrong

| Problem | Fix |
|---|---|
| The table has more or fewer than 19,314 rows | Use the original file in `Resources/`, delete the table and upload again. Do not open and save the file in Excel first |
| `Not found: Table` | Check the dataset is `owid` and the table `life_expectancy_data`, both lower case |
| `ORDER BY does not support expressions of type STRUCT<entity STRING, code STRING, year INT64, ...>`, or a `life_expectancy` column that shows a whole row in each cell | The table was named `life_expectancy`, the same as its column. Delete it and upload the file again as `life_expectancy_data` (step 3). See the BigQuery note below |
| `Operands of = cannot be literal NULL` | You wrote `code = NULL`. Use `code IS NULL`, as in 4.3 |
| Every query returns 0 rows | Check the spelling of the entity: `'Jordan'`, with a capital J, in single quotes |

## BigQuery note: a table and a column with the same name

The table is called `life_expectancy_data` and one of its columns is `life_expectancy`. The names differ on purpose.

When you write `FROM owid.life_expectancy_data`, BigQuery gives the table a short name of its own, the last part of the path: `life_expectancy_data`. Google's documentation calls this an implicit alias: "`FROM abc.def.ghi` implies `AS ghi`". That short name, used on its own, means the whole current row: "the range variable type is a dynamically defined struct that includes all of the columns in the table".

So if the table were also called `life_expectancy`, the word `life_expectancy` in a query could mean the table's row or the column. BigQuery takes the row. `ORDER BY life_expectancy` then fails with `ORDER BY does not support expressions of type STRUCT<entity STRING, code STRING, year INT64, ...>`, `WHERE life_expectancy < 60` fails with `No matching signature for operator <`, and, worst of all, `SELECT year, life_expectancy` runs and quietly puts a whole row in every cell. This happened in the first test of this lab.

Two habits prevent it: never give a table the same name as one of its columns, and when a result looks odd, read the column types in the results panel before you read the numbers. On D06 you will give every table a short name of your own with `AS`, which also removes the clash.

Source: GoogleSQL for BigQuery, [Query syntax: implicit aliases](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#implicit_aliases) and [range variables](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#range_variables).

## References

Life expectancy, Our World in Data, [ourworldindata.org/grapher/life-expectancy](https://ourworldindata.org/grapher/life-expectancy). Riley (2005); Zijdeman et al. (2015); HMD (2025); UN WPP (2024), with major processing by Our World in Data. CC BY 4.0. Course copy (1950–2023, from UN World Population Prospects 2024) taken 24 September 2026. Full attribution in [`Resources/README.md`](Resources/README.md).
