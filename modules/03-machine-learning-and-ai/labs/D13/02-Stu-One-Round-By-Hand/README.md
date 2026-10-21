# One round of k-means, by hand

In this activity, you will do the two steps k-means repeats, assign and update, for six shoppers and two groups, starting from a poor choice of centres. You need a calculator (your phone is fine), not BigQuery.

**Data:** six shoppers from `ml.mall` (below) · **Worksheet:** `Unsolved/one_round.md`

## The story

The model sorted 200 shoppers in a second. Before trusting it, do what it did on six of them, slowly. The six were picked so that you can see the two groups by eye: three young shoppers with low incomes and high scores, three with incomes near 70 thousand and high scores. The question is whether two k-means steps find them, from a bad start.

## What you will learn

- What "nearest centre" means, as a number.
- How a centre moves when its group changes.
- Why the starting centres matter.

## Before you start

The six shoppers (income in thousands of dollars, spending score 1–100):

| Shopper | Income | Score |
|---:|---:|---:|
| 2 | 15 | 81 |
| 4 | 16 | 77 |
| 6 | 17 | 76 |
| 124 | 69 | 91 |
| 126 | 70 | 77 |
| 128 | 71 | 95 |

The distance between two shoppers is the straight line between their points:

distance = √( (income difference)² + (score difference)² )

For shoppers 3 (16, 6) and 124 (69, 91): √(53² + 85²) = √(2,809 + 7,225) = 100.2.

Both columns here run from about 15 to 95, so we can use them as they are. BigQuery scales them first; part 3 shows why that matters when the columns differ.

## Steps

1. **Start.** Two centres, placed badly on purpose: **A** on shopper 2 (15, 81) and **B** on shopper 6 (17, 76).

2. **Assign.** For each shopper, work out the distance to A and to B, and write down the nearer one. Five of the six answers are quick; take care with 124, 126 and 128.

3. **Update.** Move each centre to the average income and average score of the shoppers that joined it.

4. **Answer in Slack:** how many shoppers joined A, how many joined B, and where is B now?

## Check yourself

| After | Shoppers in A | Shoppers in B | Centre B |
|---|---:|---:|---|
| Assign, round 1 | 1 | 5 | still (17, 76) |
| Update, round 1 | 1 | 5 | (48.6, 83.2) |

If your B group has five shoppers, you did it right. It is a poor split, and one round is not the end.

## Hint

Shopper 124 is 54.9 from A and 54.1 from B: B is nearer by less than one point. Close calls like this are where starting centres matter.

## Bonus

Do round 2 from the new centres A (15, 81) and B (48.6, 83.2). Who moves? Where do the centres end up? Then a round 3: does anything change?

## References

Mall Customer Segmentation Data, [Kaggle](https://www.kaggle.com/datasets/vjchoudhary7/customer-segmentation-tutorial-in-python); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026.
