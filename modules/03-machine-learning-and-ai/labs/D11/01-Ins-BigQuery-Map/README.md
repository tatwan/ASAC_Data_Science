# BigQuery beyond the queries

In this activity, you will recap what BigQuery does besides running your SQL, which of those parts the free sandbox gives you, and why we train machine-learning models inside BigQuery. The hands-on part is three D10 labs you try at home.

**Data:** a public Google sample file and `bigquery-public-data.google_trends.top_terms` (in D10's labs) · **Files:** D10's activities, linked below

## The story

A company's data does not all sit in neat uploaded tables, and every query costs something. Knowing where the data lives and how a query can read less is what keeps a warehouse fast and cheap. It also explains today's choice: the data is already in BigQuery, so we train the model there instead of moving the data somewhere else.

This part was planned for the end of D10 and was not reached. In class it is a recap only. Nothing in it is checked, and D12 does not need it.

## What you will learn

- Where a warehouse keeps its data, and why a query that reads less costs less.
- Which parts of BigQuery the free sandbox gives you.
- Why we train today's model inside BigQuery instead of moving the data out.

## Before you start

Nothing to create for this page: it is reading only. Each D10 lab below says what it needs before you start it.

## Try these at home

| D10 lab | What you do | Time |
|---|---|---|
| [09 · Query a file where it lives](../../../../02-sql/labs/D10/09-Evr-External-Table/README.md) | Create an external table on Google's public file of the 50 US states and query it like any table. Check yourself: "Which states start with W?" returns 4 rows | about 15 minutes |
| [10 · What the sandbox shows](../../../../02-sql/labs/D10/10-Ins-Sandbox-Tour/README.md) | The execution graph, your query history, `INFORMATION_SCHEMA`, and what needs billing | about 15 minutes |
| [14 · Read less: partitions and clusters](../../../../02-sql/labs/D10/14-Ins-Partitions/README.md) | The three kinds of partition, the sandbox's 60-day catch, and two estimates read on a real partitioned table | about 20 minutes |

## Where a warehouse's data lives

A cloud warehouse has two separate parts. **Storage** holds tables and files; it is cheap and always there. **Compute** starts when you run a query. BigQuery's on-demand price is by the bytes a query reads, so the bytes estimate in the top right of the editor tells you, before you run, how much the query will read and so roughly what it would cost. It is an upper bound, not an invoice: the bytes billed can be lower.

A **native table** holds its rows in BigQuery's storage: what you made when you uploaded Nakheel. An **external table** stores only a file's address, format and columns; the rows stay in the file and every query reads them there. Snowflake over Amazon S3, Databricks and Microsoft Fabric over lake files work the same way.

## Read less: partitions and clusters

A **partition** is one part of a table, split by the values of one column. A query that filters on that column reads only the parts it needs. A **cluster** keeps rows sorted inside each part, so a filter on the cluster columns skips blocks.

| | Partition | Cluster |
|---|---|---|
| What it does | splits the table into parts by one column | sorts rows inside each part by up to four columns |
| A filter on it | skips whole parts | skips blocks inside a part |
| Shown in the estimate before you run | yes | no: the saving shows in the bytes billed after |
| When | large tables; Google advises against parts smaller than about 10 GB | smaller tables, or as well as a partition |

## The BigQuery map

What BigQuery offers, and what the free sandbox gives you. Recognition only: you do not need to use every row.

| Area | In BigQuery | In the sandbox |
|---|---|---|
| Storage and compute | Native tables; SQL queries | Yes: 10 GiB of storage in all, 1 TiB of queries a month; tables, views and partitions expire after 60 days |
| Loading and reading in place | Uploads; external tables; public datasets | Uploads and public data, yes; your own Cloud Storage bucket needs billing |
| Saving work | Views; `CREATE TABLE … AS SELECT` | Yes |
| Changing rows | `INSERT`, `UPDATE`, `DELETE`; streaming; scheduled queries | No |
| Reading less | Partitions and clusters | Yes, with the 60-day partition catch |
| Machine learning | Built-in models (linear and logistic regression, k-means, time series); trees and ensembles, neural networks, AutoML; matrix factorisation; Gemini models called from SQL | Built-in models: what we use this week. Trees: checked before D14. Matrix factorisation and Gemini models: no (they need a reservation or billing) |
| AI help in the editor | Gemini: write and explain SQL, data canvas, data insights | Not used in this course |
| Python | Notebooks, BigQuery DataFrames | Not used in this course |
| Governance and more | Roles, lineage, quality scans, geography functions, BI Engine, Graph | Roles and geography functions, yes; the rest need billing |

**BigQuery ML** builds and uses models with SQL, inside the warehouse, where the data already is. You write `CREATE MODEL` with a `SELECT`, and BigQuery trains the model on the rows that `SELECT` returns. Then `ML.EVALUATE` scores it and `ML.PREDICT` uses it, also in SQL.

## Why train the model inside BigQuery

With Python on a laptop, you would export the table, download it, train the model on your own computer's processor and memory, keep the model file on the laptop, and upload the predictions back so reports can read them. Every step moves a copy of customer data. With BigQuery ML the data stays where it is: `CREATE MODEL` runs on BigQuery's engine, the model is saved in your dataset beside the tables, and a prediction is one query away, with the same permissions as the tables. (Python can also run inside BigQuery notebooks without a download; that needs billing.)

Until now you have used SQL to understand what happened. From today you use SQL to learn from history and estimate what may happen next.

## References

Google Cloud documentation: [BigQuery sandbox](https://docs.cloud.google.com/bigquery/docs/sandbox) (page updated 15 October 2026), [BigQuery overview](https://docs.cloud.google.com/bigquery/docs/introduction) (16 October 2026), [Introduction to partitioned tables](https://cloud.google.com/bigquery/docs/partitioned-tables), [Estimate and control costs](https://docs.cloud.google.com/bigquery/docs/best-practices-costs), [BigQuery pricing](https://cloud.google.com/bigquery/pricing) (read 17 October 2026). 
