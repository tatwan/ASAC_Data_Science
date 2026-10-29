# Read less: partitions and clusters

In this activity, you will see how BigQuery reads less of a large table by splitting it into partitions and sorting it into clusters, and how the bytes estimate shows the saving before a query runs.

**Time:** 10 minutes · **Data:** `bigquery-public-data.google_trends.top_terms` (estimates only) and `nakheel.orders` (D04 activity 03) · **File:** `Solved/partitions.sql` (BigQuery only)

In class you watch on Tarek's screen. Step 9 is optional, for after class. Nothing here is checked.

## Instructions

1. **The bytes estimate is the bill.** BigQuery charges a query by the bytes it reads, and the sandbox gives you 1 TiB a month. Every column you name is read in full, which is why naming columns costs less than `SELECT *`. A warehouse has two more ways to read less: partitions and clusters.

2. **A partition** is one part of a table, split by the values of one column. A query that filters on that column reads only the parts it needs; the others are skipped. This is called **partition pruning**.

    Picture Nakheel's `orders` cut into 24 parts, one per month. A query for April 2026 would read one part, 144 of the 3,000 orders, and the bytes estimate would show the smaller number before you run.

3. **Three ways to partition** (Google's names):

    | Type | Split by | Example |
    |---|---|---|
    | Time-unit column | a `DATE`, `TIMESTAMP` or `DATETIME` column; by day, month or year | `order_date`, by month |
    | Ingestion time | the day the rows were loaded; BigQuery adds the column `_PARTITIONTIME` | daily loads from a shop's tills |
    | Integer range | a whole-number column, with a start, an end and an interval | customer numbers in blocks of 100 |

4. **The DDL.** Partitioning is set when the table is created:

    ```sql
    CREATE TABLE nakheel.orders_partitioned
    PARTITION BY DATE_TRUNC(order_date, MONTH)
    CLUSTER BY channel
    AS
    SELECT *
    FROM nakheel.orders;
    ```

    Do not run this one in the sandbox (step 8 says why).

5. **A cluster.** Inside each partition, the rows are kept sorted by up to four columns, here `channel`. A filter on a clustering column lets BigQuery skip blocks of rows it knows cannot match. Unlike a partition, the estimate before the run does not show this saving; the bytes billed after the run do.

6. **When to use them.** Google advises against partitions smaller than about 10 GB; below that, cluster instead. Nakheel is about half a megabyte, so at work nobody would partition it. Partitions matter for tables of years of events: web logs, sensor readings, sales lines.

7. **See it on a real table.** Google's public `google_trends.top_terms` is partitioned by `refresh_date`, one partition per day. Type these two queries one at a time and read the estimate in the top right of the editor. Do not run them.

    ```sql
    SELECT term, rank
    FROM `bigquery-public-data.google_trends.top_terms`
    WHERE refresh_date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY);
    ```

    ```sql
    SELECT term, rank
    FROM `bigquery-public-data.google_trends.top_terms`;
    ```

    The first estimate is a small part of the second: the filter on the partition column pruned every other day. Some large tables refuse a query without a filter on the partition column; that is the table's owner protecting everyone's bill.

    You have seen these settings before: the upload screen of **Create table** has a **Partition and cluster settings** section, which you left empty when you loaded Nakheel.

8. **The sandbox catch.** In the sandbox, tables, views and partitions expire after 60 days. For a table partitioned by date, each partition expires 60 days after its date. Nakheel's orders end on 31 August 2026, so a copy partitioned by `order_date` would lose almost every partition as soon as it was made. In the sandbox, partition by ingestion time or by an integer range, or only look.

9. **Optional, after class: an integer-range copy.** The Solved file builds `nakheel.orders_by_month` with `order_month` as a whole number (202409 to 202608) and `PARTITION BY RANGE_BUCKET(order_month, GENERATE_ARRAY(202409, 202609, 1))`, one partition per month number. The 60-day rule does not apply to integer ranges. Compare the estimate for `WHERE order_month = 202604` with the estimate for the whole table. Delete the table when you have finished. The last query in the Solved file counts the orders each month number would hold (`order_month` and `COUNT(*) AS orders`, sorted by `order_month`); it runs on `nakheel.orders`, no copy needed.

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 9, months | 24 | 202604 holds 144 of the 3,000 orders |

The bytes estimates depend on the day and the table, so they are not listed.

## References

Google Cloud documentation, read 10 October 2026: [Introduction to partitioned tables](https://cloud.google.com/bigquery/docs/partitioned-tables) (the three types; about 10 GB per partition; estimates on partitioned tables), [Introduction to clustered tables](https://cloud.google.com/bigquery/docs/clustered-tables) (up to four columns), [BigQuery sandbox](https://cloud.google.com/bigquery/docs/sandbox) (60-day expiration). Google Cloud blog, "Top 25 Google Search terms, now in BigQuery" (the `top_terms` partition filter on `refresh_date`). Nakheel Retail, course-owned synthetic data generated 24 September 2026.
