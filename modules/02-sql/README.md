# SQL

[Course home](../../README.md) · [Schedule](../../course/STUDENT_SCHEDULE.md)

**27 September – 12 October 2026**

Query, combine and check data with SQL in BigQuery, then save the views that Power BI reads later in the course.

## Sessions

| Date | Topic | Slides | Labs |
|---|---|---|---|
| Sun 27 Sep | SQL foundations and the relational model | [D03](slides_pdf/D03-Databases_SQL_First_Queries.pdf) | [D03](labs/D03/) |
| Mon 28 Sep | SQL continued; aggregation begins | [D04](slides_pdf/D04-Aggregation_Grain_Measures.pdf) | [D04](labs/D04/) |
| Tue 29 Sep | Aggregation, functions and CASE | [D04](slides_pdf/D04-Aggregation_Grain_Measures.pdf) | [D04](labs/D04/) |
| Sun 4 Oct | Joins: combining tables | [D06](slides_pdf/D06-Joins_Combining_Tables.pdf) | [D06](labs/D06/) |
| Mon 5 Oct | Joins with GROUP BY and CASE | [D07](slides_pdf/D07-Joins_GroupBy_Case.pdf) | [D07](labs/D07/) |
| Wed 7 Oct | Subqueries, CTEs and views | [D08](slides_pdf/D08-Subqueries_CTEs_Views.pdf) | [D08](labs/D08/) |
| Thu 8 Oct | *Optional: SQL review (4:00–6:00 PM)* | – | – |
| Sun 11 Oct | Subqueries, CTEs and views, continued | [D09](slides_pdf/D09-Subqueries_CTEs_Views_Continued.pdf) | [D09](labs/D09/) |
| Mon 12 Oct | Window functions and cloud warehouses · **Assignment 1 issued** | [D10](slides_pdf/D10-Window_Functions_Cloud_Warehouse.pdf) | [D10](labs/D10/) |
| Tue 20 Oct | *Optional: help with SQL and Assignment 1 (4:00–6:00 PM)* | – | – |

## Materials

| Folder | What is in it |
|---|---|
| [slides_pdf/](slides_pdf/) | The slides for each session, as PDF |
| [labs/](labs/) | One folder per session (`labs/D06/`, `labs/D07/` …), with one folder per activity in the order they run. Each activity has a `README.md` with the steps and a Check yourself table, and usually an `Unsolved/` starter file to type into. The `Solved/` files are released after each session. |
| [resources/](resources/) | [Upload a CSV to BigQuery](resources/upload-a-csv-to-bigquery.md), the step-by-step guide used from D03 |
| [assignments/](assignments/) | [Assignment 1: Jordan on the world stage, in SQL](assignments/A01-SQL-Football/README.md), issued on D10 |

## Data

- [Nakheel Retail](../../shared/datasets/nakheel/README.md): the retail data used from D04 onwards, and later in Power BI.
- [The D01 tables](../01-data-foundations/datasets/w01_retail/README.md): the small tables from the first day, uploaded as `D03`.
- [Life expectancy](../../shared/datasets/owid_life_expectancy/README.md): D03's lab.
- [Pagila](../../shared/datasets/pagila/README.md): a film rental database, used on D07.
- [International football results](../../shared/datasets/intl_football/README.md): every men's international since 1872; Assignment 1, loaded on D10.

## Labs and assignments

Each session's lab is done after class to practise that day's ideas. It is not submitted or graded, and its solution is released afterwards. Keep your `.sql` files from each session: they are your reference for Assignment 1 (SQL), issued on D10 (Monday 12 October) and due before 4:00 PM on D13 (Wednesday 21 October). It uses a new dataset, international football results, which you upload yourself. The brief is in [assignments/](assignments/).
