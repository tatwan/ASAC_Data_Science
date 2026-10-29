# Lab 09 · Recommending products to Nakheel's customers (optional)

In this self-guided lab, you will turn Nakheel's completed orders into one row per customer and product, train a matrix factorization recommender on them, list the five products one customer has not bought that the model rates highest, and save the same list for every customer as a view.

**When:** after class, optional, at your own pace. Not submitted. · **Data:** `nakheel.orders`, `nakheel.order_items`, `nakheel.products`, `nakheel.customers` (D04 activity 03) → `ml.customer_product_units`, `ml.nakheel_recommender`, `ml.v_customer_recommendations` · **SQL:** `Unsolved/matrix_factorization_nakheel.sql` to run step by step, `Solved/matrix_factorization_nakheel.sql`

> **Read this first: this model may not train in your project.** Google's page for this model type says: "Matrix factorization models are only available to customers with reservations." A reservation is capacity a company buys in advance (the BigQuery Enterprise or Enterprise Plus edition); a sandbox has none. D14's tree models, which Google's pricing page lists as external models, did train in a sandbox, slowly, so it is worth trying. If step 2's `CREATE MODEL` fails with a message about reservations, your project cannot train it: read steps 2 to 5 without running them, and use the descriptions of the output under **What you should see**. Steps 1 and 6 work in any project.

## The story

Nakheel sells 60 products. A customer who has bought chino trousers and ankle socks gets the same home page as everyone else. The marketing team asks a question D11 to D15 could not answer: for each customer, which products should we show them next?

Nobody at Nakheel rates products from 1 to 5. What the shop has is purchases: who bought what, and how many. That kind of data is called *implicit feedback*: buying something says a customer likes it, more units say it more strongly, and not buying says little, because most customers have simply never looked at most products. Matrix factorization learns from this table of customers against products and fills in the empty cells.

## What you will learn

- To build the input a recommender needs: one row per customer and product, with a number that measures interest.
- What `MODEL_TYPE = 'MATRIX_FACTORIZATION'` with `FEEDBACK_TYPE = 'IMPLICIT'` does, and what `USER_COL`, `ITEM_COL` and `RATING_COL` name.
- To read `ML.RECOMMEND`'s output, and to keep only products a customer has not bought.
- To save the top five per customer as a view for a report.

## Before you start

You need the four `nakheel` tables you uploaded on D04. Check: `SELECT COUNT(*) FROM nakheel.order_items;` returns 7,516 and `SELECT COUNT(*) FROM nakheel.orders;` returns 3,000. If they are missing, upload the four CSV files from [`shared/datasets/nakheel`](../../../../../shared/datasets/nakheel/README.md) into a dataset named `nakheel`, as that README shows. You also need the `ml` dataset (activity 01 creates it).

Work like the other labs: read the step, run its SQL, compare with **What you should see**, and answer **Think** in one line. The counts in steps 1 and 6 are exact. The model's confidence values have not been computed anywhere outside BigQuery, so this lab gives none: the steps say what shape the output has and what to check.

## Checkpoints

- **C1:** `ml.customer_product_units`, with 4,630 rows for 452 customers and 56 products (step 1).
- **C2:** the model trained, and the five products customer C-1002 has not bought that it rates highest, with their names (steps 2 to 4). If your project cannot train the model, C2 is one sentence on what the reservation message said.
- **C3:** the view `ml.v_customer_recommendations` and its row count (step 5).

## Step 1 · One row per customer and product (C1)

```sql
SELECT status, COUNT(*) AS orders_placed
FROM nakheel.orders
GROUP BY status
ORDER BY orders_placed DESC;

CREATE OR REPLACE TABLE ml.customer_product_units AS
SELECT o.customer_id, i.product_id, SUM(i.qty) AS units
FROM nakheel.order_items AS i
JOIN nakheel.orders AS o ON o.order_id = i.order_id
WHERE o.status = 'completed'
GROUP BY o.customer_id, i.product_id;

SELECT COUNT(*) AS pairs,
       COUNT(DISTINCT customer_id) AS customer_count,
       COUNT(DISTINCT product_id) AS product_count,
       SUM(units) AS total_units,
       MAX(units) AS most_units
FROM ml.customer_product_units;
```

Only completed orders count: a cancelled order is not a purchase, and a pending one may still be cancelled. Each order line has a quantity, so `SUM(i.qty)` adds up every unit a customer bought of a product across all their orders. That total is the *rating* the model learns from.

**What you should see:** first 3 rows: completed 2,771, cancelled 212, pending 17. Then the table `customer_product_units` under `ml`. Then one row: 4,630 pairs, 452 customers, 56 products, 18,108 units, and a most of 130 units (one wholesale customer, one product).

452 customers and 56 products make 25,312 possible pairs, and 4,630 of them, about 18 in 100, have a purchase. The model's job is the other 82.

Two things in the data to notice:

- 4 of the 60 products (`P-009`, `P-025`, `P-046`, `P-058`) appear in no completed order. The model never sees them, so it cannot recommend them.
- One customer, `C-0999`, has a completed order but no row in `nakheel.customers`, an orphan of the kind D06 taught you to look for. The model does not need the customers table, so `C-0999` is trained like everyone else; step 5's names are empty for them.

**Think:** a wholesale customer buys 40 units of one product in one order. A retail customer buys 1. Should those two rows count the same? Step 2 says what the model does with them.

## Step 2 · Train the recommender

```sql
CREATE OR REPLACE MODEL ml.nakheel_recommender
OPTIONS (model_type = 'MATRIX_FACTORIZATION',
         feedback_type = 'IMPLICIT',
         user_col = 'customer_id',
         item_col = 'product_id',
         rating_col = 'units') AS
SELECT customer_id, product_id, units
FROM ml.customer_product_units;
```

The options, from Google's page:

| Option | Here | What it does |
|---|---|---|
| `MODEL_TYPE` | `'MATRIX_FACTORIZATION'` | the recommender |
| `FEEDBACK_TYPE` | `'IMPLICIT'` | for ratings "artificially constructed based on the user's interaction with the item, for example, by looking at their clicks, pageviews, and purchases". The default is `'EXPLICIT'`, for ratings people give, such as 1 to 5 stars |
| `USER_COL` | `'customer_id'` | the column that names the user (default `user`) |
| `ITEM_COL` | `'product_id'` | the column that names the item (default `item`) |
| `RATING_COL` | `'units'` | the column with the rating (default `rating`); a number |
| `NUM_FACTORS` | not set | how many numbers describe each customer and each product, 2 to 200; the default is log2 of the number of training rows, here about 12 |
| `WALS_ALPHA` | not set | for implicit models only, how much more weight a larger rating gets; default 40.0 |
| `L2_REG` | not set | a penalty that keeps the factors small; default 1.0 |
| `MAX_ITERATIONS` | not set | default 20 |

The input must have exactly three columns: the user, the item and the rating. `DATA_SPLIT_METHOD` defaults to `NO_SPLIT` for this model type: every row trains.

How it works: the model gives every customer and every product a short list of numbers, its *factors* (about 12 here). A customer's interest in a product is scored by combining the customer's factors with the product's. Training adjusts all the factors until the products each customer did buy score high. Customers who bought similar things end up with similar factors, so a product bought by customers like you scores high for you too, even if you never bought it. With `IMPLICIT`, Google's page says the model trains "using the Weighted-Alternating Least Squares algorithm": the rating sets how much weight each purchase gets, which answers step 1's question about 40 units against 1.

**What you should see:** if your project can train it, the model `nakheel_recommender` under `ml` when training finishes. If not, an error that mentions reservations. Google's pricing section on the same page explains: "To create a matrix factorization model you must create a reservation that uses the BigQuery Enterprise or Enterprise Plus edition". That needs a billed project; read on without running steps 2 to 5.

## Step 3 · Every product, scored for one customer

```sql
SELECT *
FROM ML.RECOMMEND(MODEL ml.nakheel_recommender)
WHERE customer_id = 'C-1002'
ORDER BY predicted_units_confidence DESC;
```

`ML.RECOMMEND` with only the model scores pairs from training. Google's page: "If no input data is specified, ML.RECOMMEND outputs the ratings for every user and item combination seen during training." Its output for an implicit model has three columns:

| Column | Read it as |
|---|---|
| `customer_id` | the user column, under the name you gave in `USER_COL` |
| `product_id` | the item column, under the name you gave in `ITEM_COL` |
| `predicted_units_confidence` | `predicted_` + the rating column's name + `_confidence`: "a FLOAT64 value that contains the relative confidence for each user-item pair" |

The confidence is relative: it ranks products for a customer. It is not a number of units and not a probability, so compare it within one customer, not across customers.

Customer C-1002 is Khaled Obeidat, a wholesale account, who bought 6 products in completed orders: Kids windbreaker, Hooded sweatshirt and Cotton T-shirt (3 units each), Chino trousers (9), Ankle socks and Kids football boots (5 each).

**What you should see:** one row per product the model knows, 56 in all, highest confidence first. Expect most of C-1002's own 6 products near the top: the model was trained to score them high.

## Step 4 · The top five C-1002 has not bought (C2)

```sql
SELECT r.product_id, p.product_name, p.category,
       ROUND(r.predicted_units_confidence, 3) AS confidence
FROM ML.RECOMMEND(MODEL ml.nakheel_recommender) AS r
JOIN nakheel.products AS p ON p.product_id = r.product_id
LEFT JOIN ml.customer_product_units AS b
  ON b.customer_id = r.customer_id AND b.product_id = r.product_id
WHERE r.customer_id = 'C-1002'
  AND b.product_id IS NULL
ORDER BY confidence DESC
LIMIT 5;
```

A recommendation of something the customer already buys is no news, so the `LEFT JOIN` looks up each pair in what C-1002 bought, and `b.product_id IS NULL` keeps only pairs with no purchase (an anti-join: keep the rows that have no match). The `JOIN` to `nakheel.products` adds names a marketing team can read.

**What you should see:** 5 rows, none of them one of C-1002's 6 products, each with a name, a category and a confidence, highest first. Look at the categories: are they close to what C-1002 already buys (outerwear, tops, bottoms, accessories, sportswear), or not?

**C2:** the five rows, and one sentence: would you show these five on Khaled's home page?

## Step 5 · Every customer's top five, as a view (C3)

```sql
CREATE OR REPLACE VIEW ml.v_customer_recommendations AS
SELECT r.customer_id, c.customer_name,
       ROW_NUMBER() OVER (PARTITION BY r.customer_id
                          ORDER BY r.predicted_units_confidence DESC) AS recommendation_rank,
       r.product_id, p.product_name, p.category,
       ROUND(r.predicted_units_confidence, 3) AS confidence
FROM ML.RECOMMEND(MODEL ml.nakheel_recommender) AS r
JOIN nakheel.products AS p ON p.product_id = r.product_id
LEFT JOIN nakheel.customers AS c ON c.customer_id = r.customer_id
LEFT JOIN ml.customer_product_units AS b
  ON b.customer_id = r.customer_id AND b.product_id = r.product_id
WHERE b.product_id IS NULL
QUALIFY recommendation_rank <= 5;

SELECT COUNT(*) AS recommendations,
       COUNT(DISTINCT customer_id) AS customer_count
FROM ml.v_customer_recommendations;
```

The same filter as step 4 for every customer, numbered within each customer by `ROW_NUMBER()` and cut at five with `QUALIFY` (D10). `LEFT JOIN nakheel.customers` adds the name and keeps `C-0999`, who has none.

Google's page warns: "ML.RECOMMEND can generate large outputs. Consider saving the output to a table for analysis." Here the output is small (one row per customer and product), but a view runs it again on every read, and Google's pages do not say whether a view may call `ML.RECOMMEND`. If the view gives an error, or reads are slow, run the same `SELECT` with `CREATE OR REPLACE TABLE ml.customer_recommendations AS` instead.

**What you should see:** the view `v_customer_recommendations` under `ml`, then 2,240 recommendations for 450 customers. Not 452 × 5 = 2,260: two customers (`C-1267` and `C-1335`) bought all 56 products and have nothing left to recommend, and four more have fewer than five products left.

**C3:** the count, and the reason it is not 2,260.

## Step 6 · What a recommender cannot check (read only)

Three facts from Google's pages that set this model apart from the others in this course:

- `ML.PREDICT` does not take matrix factorization models; `ML.RECOMMEND` is the prediction function.
- On Google's list of functions per model type, model monitoring is "N/A" for matrix factorization, so lab 07's skew check does not apply. `ML.VALIDATE_DATA_DRIFT` needs no model, so you could still compare this month's `ml.customer_product_units` with last month's.
- The model cannot recommend a product nobody has bought yet, or anything to a customer who has not bought anything: there are no factors for them. A new product needs another way to reach its first customers.

## What you saw

| Question | Your answer |
|---|---|
| Did `CREATE MODEL` train in your project? | |
| C-1002's top recommendation not yet bought | |
| Do the five match what C-1002 already buys? | |
| Rows in `ml.v_customer_recommendations` | |

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 3, then 1 | completed **2,771** · **4,630** pairs · **452** customers · **56** products · **18,108** units · most **130** |
| 3 | 56 | one row per product the model knows |
| 4 | 5 | none of C-1002's 6 products |
| 5 | 1 | **2,240** recommendations · **450** customers |

Steps 3 to 5 depend on the model; the counts there assume `ML.RECOMMEND` scores every customer with every product, as Google's sentence in step 3 says.

## Hint

If step 4 returns C-1002's own products, the `LEFT JOIN` is matching on one column only: it needs both `customer_id` and `product_id`. If it returns no rows, check that `ml.customer_product_units` has C-1002: `SELECT * FROM ml.customer_product_units WHERE customer_id = 'C-1002';` returns 6 rows.

## Bonus

- Count units only from the last 12 months of orders (`o.order_date >= '2025-09-01'`), retrain, and run step 4 again. Does C-1002's list change?
- Replace `SUM(i.qty)` with `COUNT(DISTINCT o.order_id)`, the number of orders in which a customer bought a product. A wholesale customer's 40 units then count once. Which rating would you trust for retail customers?

## References

Nakheel Retail, course-owned synthetic data; see [the dataset README](../../../../../shared/datasets/nakheel/README.md). BigQuery ML: [CREATE MODEL for matrix factorization](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-matrix-factorization) (every option, its default, and the reservation note), [ML.RECOMMEND](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-recommend), [Matrix factorization with implicit feedback, tutorial](https://docs.cloud.google.com/bigquery/docs/bigqueryml-mf-implicit-tutorial), [the functions for each model type](https://docs.cloud.google.com/bigquery/docs/e2e-journey) (monitoring "N/A"), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), [BigQuery editions](https://docs.cloud.google.com/bigquery/docs/editions-intro), [BigQuery pricing](https://cloud.google.com/bigquery/pricing#bqml), Google Cloud. Pages read 27 October 2026.
