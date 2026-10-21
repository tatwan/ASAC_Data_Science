# Your first model: a salary from years of experience

In this activity, you will upload 30 past hires, train a model that predicts salary from years of experience, read the two numbers it learned, and ask it about a new candidate.

**Data:** [`salary_data.csv`](../../../../../shared/datasets/ml_classics/salary_data.csv) → `ml.salary_data` · **Starter:** `Unsolved/first_model.sql`

## The story

A recruiting team keeps a record of 30 past hires: how many years of experience each person had, and the salary agreed. A new candidate has 5 years of experience. What salary should the team expect to offer?

Until now you have answered "what happened?" with SQL. This question is about a case that is not in the table yet. Nobody can look it up; it has to be estimated from the past hires. That is what a machine-learning model does: it learns from examples whose answer we already know, then estimates the answer for a new one.

## What you will learn

- To train a model in BigQuery with `CREATE MODEL`.
- That a trained model is a set of numbers, and to read them with `ML.WEIGHTS`.
- To ask the model about a new case with `ML.PREDICT`.

## Before you start

You need nothing from earlier days. Download [`salary_data.csv`](../../../../../shared/datasets/ml_classics/salary_data.csv).

## Steps

1. **A dataset for machine learning (block 1).** Run it. It creates the dataset `ml`, in the same location (US) as `nakheel`. Everything this week goes in it.

2. **Upload the file.** Next to `ml`, **⋮** → **Create table**. **Create table from:** Upload; choose `salary_data.csv`; **File format:** CSV. **Table:** `salary_data`. **Schema:** tick **Auto detect**. **Create table**. (The same steps as [Upload a CSV to BigQuery](../../../../02-sql/resources/upload-a-csv-to-bigquery.md).)

    Why `salary_data` and not `salary`? The file has a column called `salary`. In BigQuery, a table name can also stand for a whole row, so a table that shares its name with one of its columns invites confusion: `salary` could be read as the row instead of the column. Give each table a name that none of its columns uses.

3. **Look at the data (block 2).** Never train on a table you have not looked at. One row is one past hire. Experience runs from 1.1 to 10.5 years and salary from about 37,700 to 122,400 dollars. Salary rises with experience: you could almost draw the line yourself.

4. **Train the model (block 3).** Read it before you run it:

    - `CREATE OR REPLACE MODEL ml.salary_model` saves a model, named like a table, in the `ml` dataset.
    - `model_type = 'LINEAR_REG'` picks the method: linear regression, which predicts a **number** with a straight line.
    - `input_label_cols = ['salary']` names the **label**: the column the model learns to predict.
    - The `SELECT` is the training data. Every column in it that is not the label is a **feature**: here, only `years_experience`.

    It takes about a minute. When it finishes, **ml → Models** shows `salary_model`.

5. **Read the model (block 4).** `ML.WEIGHTS` shows the numbers the model learned. Two rows: `__INTERCEPT__` about 25,792 and `years_experience` about 9,450. Read it out loud: *start at about 25,800 dollars, and add about 9,450 for every year of experience.* That sentence is the whole model.

6. **Ask it about the new candidate (block 5).** `ML.PREDICT` takes the model and some rows, and adds a column named `predicted_` plus the label: `predicted_salary`. For 5 years: about 73,042. Check it by hand: 25,792 + 9,450 × 5 = 73,042.

7. **Later in class: how good is it? (block 6).** `ML.EVALUATE` scores the model. Keep the numbers for the class discussion: the mean absolute error (MAE) is about 4,644 dollars and R² about 0.957. We will see why those numbers flatter this model.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 2 | 30 | first row 1.1 years, 39,343 dollars |
| 4 | 2 | `__INTERCEPT__` ≈ 25,792 · `years_experience` ≈ 9,450 |
| 5 | 1 | `predicted_salary` ≈ 73,042 |
| 6 | 1 | MAE ≈ 4,644 · R² ≈ 0.957 |

## If something goes wrong

- **`Not found: Table ml.salary_data`:** the upload went to another dataset or another name. The table must be `salary_data` inside `ml`.
- **`Unrecognized name: salary`:** open the table's **Schema** tab and use the column names it shows.
- **The model takes longer than two minutes:** wait. The sandbox queues training jobs.

## References

Salary data: the 30-row years-of-experience teaching set widely shared on Kaggle; course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. BigQuery ML: [CREATE MODEL for linear regression](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm), Google Cloud.
