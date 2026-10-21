# Lab 08 · The odd ones out: anomalies from a k-means model

In this self-guided lab, you will use the wholesaler's log model from lab 07 to flag the clients who are least like any group, with `ML.DETECT_ANOMALIES`.

**When:** after lab 07, at your own pace. Not submitted. · **Data:** `ml.wholesale_logs` and `ml.wholesale_log_model` from lab 07 · **SQL:** `Solved/odd_ones_out.sql`

## The story

The wholesaler's finance team checks unusual accounts by hand each quarter: a client whose spending looks like no one else's may be a typing error, a new kind of business, or a client about to leave. They can check about ten. The question: *which clients are least like any group?*

## The one idea

Every client joins its nearest centre. A client who is far even from its nearest centre does not fit any group well: that is an **anomaly**. You decide how many to flag.

## How to work through this lab

You need the view `ml.wholesale_logs` and the model `ml.wholesale_log_model` from [lab 07](../07-Lab-Logs-And-Cosine/README.md), step 3. Run each query, compare with **What you should see**, and answer **Think** in one line.

Google's page says `ML.DETECT_ANOMALIES` queries are billable. If your sandbox refuses it, read the expected results and go on to step 3.

## Step 1 · Flag the most unusual 2%

```sql
SELECT client_id, channel, fresh, milk, grocery, frozen, detergents_paper, delicatessen,
       ROUND(normalized_distance, 2) AS normalized_distance
FROM ML.DETECT_ANOMALIES(MODEL ml.wholesale_log_model,
       STRUCT(0.02 AS contamination),
       (SELECT * FROM ml.wholesale_logs))
WHERE is_anomaly
ORDER BY normalized_distance DESC;
```

- `contamination = 0.02`: flag about 2% of the clients, the ones furthest from their nearest centre.
- `normalized_distance`: the distance to the nearest centre, divided by how spread out that group is. A loose group tolerates more distance than a tight one.
- `is_anomaly` is TRUE for the flagged clients, so `WHERE is_anomaly` keeps only them.

**What you should see:** about 9 clients (2% of 440). Look at their rows: several spend almost nothing on one product where others spend thousands. Outside BigQuery the list almost always included clients **76** (grocery 3, detergents 3), **155** (under 650 on everything), **184** (delicatessen 47,943, the largest in the file), **339** (fresh 3) and **143** (delicatessen 3). Your list can differ at the edges.

## Step 2 · Change the contamination

Change `0.02` to `0.05` and run it again.

**What you should see:** about 22 clients. The setting does not find "the real anomalies"; it decides how many you want to look at.

**Think:** finance can check about ten accounts a quarter. Which contamination would you set?

## Step 3 · Anomaly, or a group of its own?

Think back to step 2 of lab 07, the model without logs: there, the biggest spenders formed tiny groups of their own, so they sat close to their own centre and would not look odd at all.

**Think:** why does finding anomalies need a model whose groups describe most clients well?

## What you saw

| Question | Your answer |
|---|---|
| How many clients did 0.02 flag? 0.05? | |
| Name one flagged client and what makes it unusual | |

## References

Wholesale customers (Cardoso, 2013), UCI Machine Learning Repository, [doi:10.24432/C5030X](https://doi.org/10.24432/C5030X), [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). BigQuery ML: [ML.DETECT_ANOMALIES](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-detect-anomalies) (k-means output: `is_anomaly`, `normalized_distance`), Google Cloud.
