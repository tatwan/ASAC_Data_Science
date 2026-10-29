# What the sandbox shows, and what needs billing

In this activity, you will look at four things the free BigQuery sandbox gives you beyond running queries, and learn which features of a cloud warehouse need a billing account.

**When:** after class, about 15 minutes. In class you saw only the "needs billing" table below · **Data:** `nakheel` (D04 activity 03) and `bi` (D08 activities 07 and 08) · **File:** `Solved/sandbox_tour.sql`

## Instructions

1. **How BigQuery ran your query.** Run any query from today, for example 2.2's share of category. Under the results, open **Execution details** and then **Execution graph**. Each box is a stage: reading the tables, joining, aggregating, the window. The graph shows how much time and how many rows each stage took. When a query is slow, this is where you look first.

2. **What you ran before.** At the bottom of the console, open **Personal history** (in some console versions it is **Job history**). Every query you ran is there, with its text, the bytes it processed and how long it took. Click one to open it again.

3. **The data about your data.** Every dataset has a hidden set of views, `INFORMATION_SCHEMA`, that describe its tables:

    ```sql
    SELECT table_name, table_type, creation_time
    FROM nakheel.INFORMATION_SCHEMA.TABLES
    ORDER BY table_name;
    ```

    You should see the four Nakheel tables, each a `BASE TABLE`. Change `nakheel` to `bi`: your views show as `VIEW`. And the columns of one table:

    ```sql
    SELECT column_name, data_type
    FROM nakheel.INFORMATION_SCHEMA.COLUMNS
    WHERE table_name = 'orders'
    ORDER BY ordinal_position;
    ```

    You should see 9 rows, `order_id` first. This is how you check a schema without clicking through the explorer, and how tools such as Power BI find out what is in a dataset.

4. **Other people's data.** In the explorer, **+ Add** → **Star a project by name** → `bigquery-public-data`. Hundreds of public datasets appear, from weather to football. Queries against them count against your 1 TiB a month, so check the bytes estimate before you run one.

## What needs a billing account

The sandbox is free and needs no card. These parts of a cloud warehouse are not in it:

| Feature | What it does | Why not in the sandbox |
|---|---|---|
| Cloud Storage buckets | your own files for external tables and loads | creating a bucket needs billing |
| Data lineage | draws which tables and views each table was built from | a paid Dataplex feature, no free tier |
| Data profiling and data quality scans | profiles every column; checks rules such as "no NULL IDs" | paid Dataplex processing, no free tier |
| Scheduled queries | run a query every morning | needs the Data Transfer Service, not in the sandbox |
| `INSERT`, `UPDATE`, `DELETE` | change rows in place | the sandbox does not run DML |
| BigQuery Graph | query connected data as a graph | GQL needs an Enterprise or Enterprise Plus reservation |

What does work in the sandbox: `CREATE TABLE`, `CREATE TABLE ... AS SELECT` and `CREATE VIEW`, which you have used since D08. Who can see a dataset is set by roles on the project, the dataset or the table; Power BI's row-level security (D23) is the report's version of the same idea.

You can do most of a data analyst's daily work without them. In a company account, ask what is switched on before you plan around one.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 3 | 4 | customers, order_items, orders, products |
| 3, columns | 9 | order_id first |

## References

Google Cloud documentation, checked 9 October 2026: [BigQuery sandbox](https://cloud.google.com/bigquery/docs/sandbox) (limits and unsupported features), [Cloud Storage FAQ](https://cloud.google.com/storage/docs/faq) (billing to create buckets), [Dataplex pricing](https://cloud.google.com/dataplex/pricing) (no free tier for lineage, profiling and quality scans), [Introduction to BigQuery Graph](https://cloud.google.com/bigquery/docs/graph-overview) (Enterprise reservation for graph queries).
