# Do we need all six features?

In this activity, you will train two smaller insurance models, score all three on the rows they did not learn from, and decide which one you would keep.

**Data:** `ml.insurance`, `ml.insurance_model` (activity 03) · **Starter:** `Unsolved/fewer_features.sql`

## The story

The insurer's pricing team likes the model but has a fair question: *do we really need six facts about each customer?* Fewer features mean fewer things to collect, fewer things to go wrong, and a model that is easier to explain. If a smaller model scores about the same, it is the better choice.

## What you will learn

- To compare models fairly: same data, same kind of split, same scores.
- That more features do not always mean a better model.
- That when two models score about the same, the simpler one wins.

## Before you start

You need `ml.insurance` and `ml.insurance_model` from activity 03. Check: **ml → Models** shows `insurance_model`.

## Steps

1. **Three features (block 1).** Train `ml.insurance_three` on `age`, `bmi` and `smoker` only, with the same split options as activity 03.

2. **One feature (block 2).** Train `ml.insurance_age` on `age` alone.

3. **Compare (block 3).** One query scores all three models on the rows each one held aside. Write the three R² values in the chat.

4. **Choose.** Which model would you give the pricing team? Lower MAE and higher R² are better; when two are within about 100 dollars of each other, keep the simpler one.

## Check yourself

| Model | Features | MAE | R² |
|---|---:|---:|---:|
| `insurance_model` | 6 | ≈ 4,200 | ≈ 0.75 |
| `insurance_three` | 3 | ≈ 4,200 | ≈ 0.75 |
| `insurance_age` | 1 | ≈ 9,100 | ≈ 0.08 |

Three features score about the same as six: `sex`, `children` and `region` add almost nothing. Age alone is barely better than guessing the average. Age matters, but on its own it cannot see the smokers, and smoking is the largest effect in the data.

Each model holds aside its own random 20%, so your numbers move a little. A difference of a few dozen dollars is noise.

## Bonus

Train `ml.insurance_smoker` on `smoker` alone. Its R² is about 0.62. One yes-or-no column explains more than age, BMI and children together. What would you tell the pricing team about where their risk comes from?

## References

Medical Cost Personal Datasets (Kaggle, `mirichoi0218/insurance`); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md).
