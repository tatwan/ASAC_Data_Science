# Activity 03 · Train a model, score it, and read what it learned

Hot days average 622.6 rides and other days 830.9. But hot days only happen in summer, when most students are away. A linear regression can compare days within the same month and weekday, and so separate the heat from the calendar. You train it, check it on days it has not seen, read its weights, and save its predictions as a view for Power BI.

| Step | What you need | BigQuery ML |
|---|---|---|
| 1 | A fair test: days the model never sees | The `split` column |
| 2 | The model | `CREATE MODEL … LINEAR_REG` |
| 3 | Is it better than a simple guess? | `ML.EVALUATE`, a median baseline |
| 4 | What does heat cost, with the month held fixed? | `ML.WEIGHTS` |
| 5 | Predictions Power BI can read | `ML.PREDICT` in a view |

## 1. Look at the split

**Why this step.** A model always looks good on the days it learned from. You judge it on days it did not see. The split is fixed in the view, so every model and every classmate is tested on the same 73 days (the fair comparison from D14).

```sql
SELECT split, COUNT(*) AS days FROM bikes.v_days GROUP BY split;
```

**C1.** train 291, test 73.

## 2. Train the model

**Why this step.** The label is `trips`. The features are the day type, the weekday and the month. With the month in the model, a hot day in July is compared with a July day that was not hot, not with a day in October.

```sql
CREATE OR REPLACE MODEL bikes.trips_model
OPTIONS (model_type = 'LINEAR_REG',
         input_label_cols = ['trips'],
         data_split_method = 'NO_SPLIT') AS
SELECT trips, day_type, weekday, month_name
FROM bikes.v_days
WHERE split = 'train';
```

`data_split_method = 'NO_SPLIT'` tells BigQuery to train on all the rows you give it; your `WHERE` has already left the test days out.

**C2.** The query finishes in a few seconds and `trips_model` appears in `bikes`. 291 rows and three text features train quickly.

## 3. Score it on the test days

**Why this step.** An error number means little alone. You compare it with a guess anyone could make without a model: the median day of the training days.

```sql
SELECT ROUND(mean_absolute_error, 1) AS model_mae,
       ROUND(r2_score, 2) AS r2
FROM ML.EVALUATE(MODEL bikes.trips_model,
                 (SELECT * FROM bikes.v_days WHERE split = 'test'));
```

```sql
WITH guess AS (
  SELECT APPROX_QUANTILES(trips, 2)[OFFSET(1)] AS median_trips
  FROM bikes.v_days WHERE split = 'train'
)
SELECT ANY_VALUE(median_trips) AS median_guess,
       ROUND(AVG(ABS(trips - median_trips)), 1) AS guess_mae
FROM bikes.v_days, guess
WHERE split = 'test';
```

**C3.** The model is off by 171.4 rides a day on average, with an R² of 0.52. Guessing 747 every day is off by 271.1. The model removes more than a third of the error. It is far from perfect: football games, holidays and exam weeks are not among its features.

## 4. Read the weights

**Why this step.** For a text feature, BigQuery gives each value its own weight. The difference between two weights is the difference in predicted rides between two days that are the same in every other feature.

```sql
SELECT w.processed_input AS feature, cw.category, ROUND(cw.weight, 1) AS weight
FROM ML.WEIGHTS(MODEL bikes.trips_model) AS w, UNNEST(w.category_weights) AS cw
ORDER BY feature, weight;
```

**C4.** Read the differences, not the single weights:

| Comparison | Weights | Difference |
|---|---|---:|
| Hot against Other | -1,172.1 and -946.3 | about **-226** rides |
| Rain against Other | -1,061.0 and -946.3 | about **-115** rides |
| October against December | 768.5 and 63.5 | about **+705** rides |

With the month held fixed, a hot day still costs about 226 rides. The month matters three times as much: October, in the middle of the autumn semester, has about 705 more rides a day than December, when the students go home.

## 5. Save the predictions as a view

**Why this step.** Power BI cannot run a model. A view that calls `ML.PREDICT` gives Power BI a table with the actual and predicted rides for every day.

```sql
CREATE OR REPLACE VIEW bikes.v_predictions AS
SELECT day, split, day_type, trips, ROUND(predicted_trips) AS predicted_trips
FROM ML.PREDICT(MODEL bikes.trips_model, (SELECT * FROM bikes.v_days));
```

```sql
SELECT SUM(trips) AS actual, SUM(predicted_trips) AS predicted
FROM bikes.v_predictions WHERE split = 'test';
```

**C5.** On the 73 test days: 55,188 actual rides, 57,632 predicted.

**What just happened.** The quick answer, "hot days lose a quarter of the rides", mixed two causes. The model compares like with like and splits them: about 226 rides for the heat, and up to about 700 for the school calendar. Look at 21–25 August 2023: every day reached between 99 and 107 °F, and rides still went from 760 to 1,116 a day. The autumn semester had started.
