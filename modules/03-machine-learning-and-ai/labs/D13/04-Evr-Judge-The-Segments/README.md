# Judging the segments: profiles, a score, k, and a second run

In this activity, you will describe each of the mall's five groups in the units marketing understands, read the one score BigQuery gives a clustering, try six groups instead of five, retrain to see whether the groups hold, and then, with a partner, name each group and give it one action.

**Data:** `ml.mall` and the model `ml.mall_segments` from activity 01 · **Starter:** `Unsolved/judge_the_segments.sql`

## The story

On D11 and D12 we judged a model against answers it had not seen: a test score. A clustering has no answers to check against. Marketing still needs to know whether these five groups are worth five campaigns. So we check what we can: whether each group is clearly different in plain units, whether the groups are tight and apart, whether another number of groups would serve better, and whether the groups come back when the model is trained again.

## What you will learn

- To profile clusters in original units by joining `ML.PREDICT` back to the table.
- To read the Davies–Bouldin index from `ML.EVALUATE`, and why it suggests k rather than chooses it.
- That random starts can change a clustering, and how to compare two runs.

## Before you start

You need `ml.mall` and `ml.mall_segments` from [activity 01](../01-Evr-First-Segments/README.md), blocks 3 and earlier. If they are missing, run activity 01's blocks 1 to 3 first.

## Steps

1. **A profile of each group (block 1).** `ML.PREDICT` keeps every column of the table you pass it, so `age` and `gender` come along even though the model never used them. Group by `centroid_id` and average the columns. Sorted by income, you should see five groups like these:

    | Shoppers | Avg income (k$) | Avg score | Avg age | Share women |
    |---:|---:|---:|---:|---:|
    | about 22 | 26 | 79 | 25 | 0.59 |
    | about 23 | 26 | 21 | 45 | 0.61 |
    | about 80 | 55 | 50 | 43 | 0.59 |
    | about 39 | 87 | 82 | 33 | 0.54 |
    | about 35 | 88 | 17 | 41 | 0.46 |

    This is the profile: size, the two columns the model used, and the columns it did not use. `ML.CENTROIDS` (activity 01, block 6) gives only the second and third columns. Age came out of the profile for free: the big spenders are younger.

2. **The score BigQuery gives (block 2).** `ML.EVALUATE` on a k-means model returns two numbers. **Davies–Bouldin index** compares how spread out each group is with how far it sits from its nearest neighbour group; lower means tighter, better-separated groups. **Mean squared distance** is the average squared distance from each shopper to their centre. Expect about **0.57** and **0.33**. Neither is a test score: they describe the shape of the groups, not whether marketing can use them.

3. **Six groups instead of five (block 3).** The same model with `num_clusters = 6`. Profile it. One of the two high-income groups splits: about 10 shoppers with incomes near 110 thousand get a group of their own. In some runs they are the big spenders, in others the low spenders. The Davies–Bouldin index is higher, about **0.63 to 0.67**. By that measure five is better; a business that wants a short list of its richest members might still choose six.

4. **Train again (block 4).** Block 4 trains the same five-group model again under a new name, `ml.mall_segments_2`. Then compare its mean squared distance with block 2's, and its group sizes with block 1's. Most runs give the same five groups (one shopper near the border can switch between the 80 and the 36). About one run in three ends in a worse split, with a group of about 100 and one of about 10, and a mean squared distance near **0.49** instead of 0.33. Lower is tighter: if two runs disagree, keep the one with the lower mean squared distance, and check that its profile still makes sense.

5. **With a partner: name the groups and give each one action.** Marketing can run one campaign per group. For each group: a short name a marketing manager would understand, and one action. Post your five lines in Slack.

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 1 | 5 | sizes about 22, 23, 80, 39, 35 sorted by income; the two low-income groups differ by score, not income |
| 2 | 1 | Davies–Bouldin ≈ 0.57 · mean squared distance ≈ 0.33 |
| 3 | 6 | a group of about 10 shoppers with incomes near 110 thousand |
| 4 | 1, then 5 | ≈ 0.33 and the same sizes for most runs; ≈ 0.49 when a run ends in the worse split |

Computed outside BigQuery with the same settings before the class ran them. Your group numbers (`centroid_id`) will differ from a classmate's: compare sizes and profiles.

## Hint

For step 5, name the group by what its members do, not by a number: "high income, low spending here" says what marketing needs to know.

## Bonus

Add `age` as a third feature (scaled) and train five groups. Profile them. Are they easier or harder to name than the two-feature groups?

## References

Mall Customer Segmentation Data, [Kaggle](https://www.kaggle.com/datasets/vjchoudhary7/customer-segmentation-tutorial-in-python); course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md), taken 18 October 2026. BigQuery ML: [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate) (k-means output: Davies–Bouldin index, mean squared distance), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), Google Cloud.
