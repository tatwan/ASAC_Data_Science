# D13 resources

## The data

| File | Table | Used in |
|---|---|---|
| [`mall_customers.csv`](../../../../../shared/datasets/ml_classics/mall_customers.csv) | `ml.mall` | activities 01, 02 and 04; labs 05 and 06 |
| `bigquery-public-data.ml_datasets.penguins` | public table, no upload | activity 03 |
| [`wholesale_customers.csv`](../../../../../shared/datasets/ml_classics/wholesale_customers.csv) | `ml.wholesale` | labs 07 and 08 |
| Nakheel `orders` and `customers` (D04), view `ml.customer_features` (D11 lab 08) | | lab 09 (optional) |

Sources, licences and upload steps: [`shared/datasets/ml_classics/README.md`](../../../../../shared/datasets/ml_classics/README.md).

## The order of the after-class labs

Labs 05 and 06 read the model `ml.mall_segments` from activity 01. Lab 08 needs lab 07's view and model. Lab 09 is optional self-study and needs D11's lab 08 view first.

## Every k-means option, and where you see it

Everything on Google's [CREATE MODEL page for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans) (checked 18 October 2026):

| Option | Default | What it does | Where |
|---|---|---|---|
| `MODEL_TYPE = 'KMEANS'` | required | clustering; no label, no data split | activity 01 |
| `NUM_CLUSTERS` | log10 of the row count | how many groups (2 to 100) | activities 01, 04; lab 05 |
| `KMEANS_INIT_METHOD` | `'RANDOM'` | starting centres: `RANDOM`, `KMEANS++` or `CUSTOM` | activity 01; lab 06 |
| `KMEANS_INIT_COL` | none | the BOOL column marking the starting rows when `CUSTOM` | lab 06 |
| `DISTANCE_TYPE` | `'EUCLIDEAN'` | straight-line distance, or `'COSINE'` to compare the mix | lab 07 (bonus) |
| `STANDARDIZE_FEATURES` | `TRUE` | put numeric columns on one scale before measuring | activity 03; labs 07, 09 |
| `MAX_ITERATIONS` | 20 | the most rounds of assign-and-update | lab 06 (bonus) |
| `EARLY_STOP` | `TRUE` | stop when a round improves the loss by less than `MIN_REL_PROGRESS` | default kept |
| `MIN_REL_PROGRESS` | 0.01 | the improvement a round needs to continue | default kept |
| `WARM_START` | `FALSE` | keep the centres and train again on new rows | not used in this course |
| `NUM_TRIALS` | none | turn on tuning: how many models to try (1 to 100) | named in lab 05, not used: 200 rows are too few to tune on |
| `MAX_PARALLEL_TRIALS` | 1 | trials at the same time (1 to 5) | not used |
| `HPARAM_TUNING_ALGORITHM` | `'VIZIER_DEFAULT'` | how to search: also `RANDOM_SEARCH`, `GRID_SEARCH` | not used |
| `HPARAM_TUNING_OBJECTIVES` | `'DAVIES_BOULDIN_INDEX'` | the score tuning minimises (the only one for k-means) | not used |
| `MODEL_REGISTRY`, `VERTEX_AI_MODEL_ID`, `VERTEX_AI_MODEL_VERSION_ALIASES`, `KMS_KEY_NAME` | none | registering the model in Vertex AI; encrypting it with your own key | not used in this course |

The functions: `ML.PREDICT` (`centroid_id`, `nearest_centroids_distance`; activities 01, 04, labs 07–09), `ML.CENTROIDS` (activity 01), `ML.EVALUATE` (Davies–Bouldin index, mean squared distance; activity 04, lab 05), `ML.TRAINING_INFO` (lab 06), `ML.DETECT_ANOMALIES` (lab 08).

## If CREATE MODEL fails in class

[`fallback/mall_segments.csv`](fallback/mall_segments.csv) holds a group number for each of the 200 shoppers, computed outside BigQuery with the same settings (sizes 22, 23, 81, 39, 35; numbered by average income). Upload it as `ml.mall_segments_fallback` and replace `ML.PREDICT(MODEL ml.mall_segments, (SELECT * FROM ml.mall))` with:

```sql
(SELECT m.*, f.centroid_id
 FROM ml.mall AS m
 JOIN ml.mall_segments_fallback AS f USING (customer_id))
```

The profile in activity 04, block 1, then runs as plain SQL. `ML.EVALUATE`, `ML.CENTROIDS` and the distances need the model.

## If something goes wrong

- **`Not found: Dataset bigquery-public-data:ml_datasets`** in activity 03: your `ml` dataset is not in the US location. Create it with `OPTIONS (location = 'US')`.
- **Your group sizes differ from a classmate's:** k-means starts from random centres. Compare sizes and profiles, not `centroid_id` numbers, and compare mean squared distance when two runs disagree.
- **`KMEANS_INIT_COL` error in lab 06:** the BOOL column must have exactly as many `TRUE` rows as `num_clusters`.
