# Activity 03 · Train a model, score it, and read what it learned

You train a linear regression on the days of 2023, check it on days it has not seen, read its weights, and save its predictions as a view for Power BI. The sections below say why each part is needed before you start.

**Where you are:** 01 Explore → 02 Views → **03 Model** → 04 Connect → 05 Story. You bring `bikes.v_days` (Activity 02); you hand on `bikes.v_predictions`, which Activity 04 imports and Activity 05 draws.

### Why a model at all

Activity 01 found that hot days average 614.8 rides and other days 828.5. That gap mixes two things. Every hot day falls in summer, and summer is when Austin's students, more than half of the riders, are away. From averages alone you cannot tell how much of the gap is the heat and how much is the calendar. A model can compare a hot day with an ordinary day **in the same month and on the same weekday**, and give the heat its own number.

### Why linear regression

**Remember (D11 and D12).** The label decides the kind of model. Here the label, `trips`, is a number, so this is **regression**, the kind you trained in D11. D12's classifiers predicted a category (churn or not), which is not today's question.

Of the regression models you know, linear regression is the one whose answer you can read. It predicts rides as a starting value plus one **weight** for each feature value. For a text feature, every value gets its own weight (D11, Lab 06). The difference between the Hot weight and the Other weight is the number of rides a hot day costs, with the month and weekday unchanged. That weight is the answer to the question. Tree models (D14) can predict well too, but they give no single number per feature to read.

| Feature | Values | Why it is in the model |
|---|---|---|
| `day_type` | Hot, Rain, Other | the effect we want to measure |
| `month_name` | Jan … Dec | holds the season and the school calendar fixed |
| `weekday` | Mon … Sun | holds the weekly pattern fixed |

### What we hope to get

1. **Predictions better than a guess**, on days the model never saw. The guess is the median training day, 731 rides, which misses by 273.6 rides a day. If the model cannot beat that, its weights mean nothing.
2. **A weight for heat with the calendar held fixed.** If the heat weight came out near zero, the gap in Activity 01 was all calendar. If it came out near the raw gap of about 214 rides or larger, the heat matters on its own.
3. **A weight for each month**, to compare with the heat.

**Remember (D11 and D14).** The **MAE** is the average miss, in rides. **R²** is the share of the day-to-day variation the model explains: 0 is no better than the average, 1 is perfect. The test days are fixed in the view, as in D14, so every classmate scores the same 73 days.

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

**C3.** The model is off by about 171 rides a day on average, with an R² of about 0.53. Guessing 731 every day is off by about 274. The model removes more than a third of the error. It is far from perfect: football games, holidays and exam weeks are not among its features.

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
| Hot against Other | -110.2 and 114.3 | about **-225** rides |
| Rain against Other | 0.0 and 114.3 | about **-114** rides |
| October against December | 548.0 and -156.9 | about **+705** rides |

Your single weights may not match these: BigQuery can choose a different value to set at zero (here Rain and February are 0.0), and on 15 November the same model gave Hot -1,172.1 and Other -946.3. The differences stay the same, which is why you read differences.

With the month held fixed, a hot day still costs about 225 rides. The month matters three times as much: October, in the middle of the autumn semester, has about 705 more rides a day than December, when the students go home.

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

**C5.** On the 73 test days: about 54,961 actual rides and 57,372 predicted (checked 23 November 2026). Google updates the trips table, so a few dozen rides either way is normal.

**What just happened.** The quick answer, "hot days lose a quarter of the rides", mixed two causes. The model compares like with like and splits them: about 225 rides for the heat, and up to about 700 for the school calendar. Look at 21–25 August 2023: every day reached between 99 and 107 °F, and rides still went from 760 to 1,116 a day. The autumn semester had started.
