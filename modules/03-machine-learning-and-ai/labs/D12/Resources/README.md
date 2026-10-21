# D12 resources

## The data

| File | Table | Used in |
|---|---|---|
| [`telco_churn.csv`](../../../../../shared/datasets/ml_classics/telco_churn.csv) | `ml.telco` | activities 01 and 02, lab 03 |
| [`employee_data.csv`](../../../../../shared/datasets/ml_classics/employee_data.csv) | `ml.employees` | lab 04 |
| `bigquery-public-data.ml_datasets.penguins` | public table, no upload | lab 05 |
| Nakheel `orders` and `customers` (D04), view `ml.customer_features` (D11 lab 08) | | lab 06 (optional) |

Sources and upload steps: [`shared/datasets/ml_classics/README.md`](../../../../../shared/datasets/ml_classics/README.md).

## The order of the after-class labs

Lab 03 reads the models from activities 01 and 02. Labs 04 and 05 stand alone. Lab 06 is optional self-study and needs D11's lab 08 view first.

## If something goes wrong

- **`Churn` and `Attrition` are BOOLEAN.** The files say Yes or No; **Auto detect** reads them as TRUE (left) or FALSE (stayed), and every query in D12 is written that way. If your table shows STRING, you uploaded without Auto detect: write `'Yes'`/`'No'` for `TRUE`/`FALSE`.
- **A threshold needs data to score.** `STRUCT(0.3 AS threshold)` works in `ML.PREDICT`, which always has input rows. `ML.EVALUATE` and `ML.CONFUSION_MATRIX` accept a threshold only when you also give them a table or query; without one they fail. To see the held-aside customers at several thresholds, read the rows of `ML.ROC_CURVE`, as in activity 02 block 6.
- **`Not found: Dataset bigquery-public-data:ml_datasets`** in lab 05: your `ml` dataset is not in the US location. Create it with `OPTIONS (location = 'US')`.
- **Your scores differ from a classmate's:** every `RANDOM` split holds aside different rows.
- **Precision is empty:** the model said Yes for nobody at that threshold; precision divides by zero flagged rows.
