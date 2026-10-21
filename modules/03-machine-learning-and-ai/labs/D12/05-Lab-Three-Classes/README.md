# Lab 05 · Three classes: which penguin is it?

In this self-guided lab, you will train a logistic regression that chooses between three answers instead of two, read its three probabilities, and read a three-by-three confusion matrix. The data is one of BigQuery's public tables, so there is nothing to upload.

**When:** after class, at your own pace. Not submitted. · **Data:** `bigquery-public-data.ml_datasets.penguins` · **SQL:** `Solved/three_classes.sql`

## The one idea

Nothing in the `CREATE MODEL` statement changes. When the label has three values, BigQuery trains a **multiclass** model: it gives one probability per class and picks the highest. There is no threshold to move.

## How to work through this lab

Run each query, compare with **What you should see**, and answer **Think** in one line. Your `ml` dataset must be in the US location (it is, if you created it on D11), because the public table is there.

## The data

344 penguins from three islands near Palmer Station, Antarctica. One row is one penguin. The label is `species`: Adelie, Chinstrap or Gentoo. Features: `island`, `culmen_length_mm` and `culmen_depth_mm` (the bill), `flipper_length_mm`, `body_mass_g`, `sex`.

## Step 1 · Look first

```sql
SELECT species, COUNT(*) AS penguin_count,
       ROUND(AVG(flipper_length_mm), 1) AS avg_flipper,
       ROUND(AVG(body_mass_g)) AS avg_mass
FROM `bigquery-public-data.ml_datasets.penguins`
GROUP BY species;
```

**What you should see:** three species of different sizes. Gentoo is the heaviest, with the longest flippers.

**Think:** which single measurement would you use to tell a Gentoo from the other two?

## Step 2 · Train

```sql
CREATE OR REPLACE MODEL ml.penguin_species
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['species'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT island, culmen_length_mm, culmen_depth_mm, flipper_length_mm,
       body_mass_g, sex, species
FROM `bigquery-public-data.ml_datasets.penguins`;
```

The same statement as on D12, with a three-valued label. A few penguins have missing measurements; BigQuery fills a missing number with the column's average when it trains.

## Step 3 · Score it

```sql
SELECT ROUND(accuracy, 3) AS accuracy, ROUND(precision, 3) AS precision,
       ROUND(recall, 3) AS recall
FROM ML.EVALUATE(MODEL ml.penguin_species);
```

**What you should see:** very high scores, accuracy close to 1. With three classes, BigQuery works out precision and recall for each species and gives their average.

**Think:** a near-perfect score is a reason to look closer. Is the model seeing something it should not, or are penguin species simply easy to tell apart by size and bill?

## Step 4 · A three-by-three matrix

```sql
SELECT *
FROM ML.CONFUSION_MATRIX(MODEL ml.penguin_species);
```

**What you should see:** three rows (what the penguin really was) and three count columns (what the model said). Almost every count sits on the diagonal, where the real species and the predicted species are the same. BigQuery turns each species name into a column name, so the names may look a little odd.

## Step 5 · Three probabilities per penguin

```sql
SELECT species, predicted_species, predicted_species_probs
FROM ML.PREDICT(MODEL ml.penguin_species,
       (SELECT * FROM `bigquery-public-data.ml_datasets.penguins` LIMIT 5));
```

**What you should see:** for each penguin, a small list of three labels and three probabilities that add up to 1. `predicted_species` is the label with the highest probability.

**Think:** on D12 we moved a threshold to turn one probability into Yes or No. Why is there nothing to move here?

## What you saw

| Question | Two classes (D12) | Three classes (this lab) |
|---|---|---|
| What does `ML.PREDICT` give? | | |
| How is the answer decided? | a threshold | |
| Shape of the confusion matrix | 2 × 2 | |

## References

Palmer penguins (Gorman, Williams and Fraser, 2014), as BigQuery's public table `bigquery-public-data.ml_datasets.penguins`. BigQuery ML: [CREATE MODEL for logistic regression](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), [ML.CONFUSION_MATRIX](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-confusion), Google Cloud.
