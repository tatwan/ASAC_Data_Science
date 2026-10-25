# Five people through a tree, by hand

In this activity, you will follow five insured people down a small decision tree, read the prediction at the leaf where each one lands, and compare the tree's misses with the line's.

**Time:** about 10 minutes · **Data:** none to run; the tree and the five people are below · **Worksheet:** `Unsolved/tree_by_hand.md`

## The story

The boosted-trees model beat the line by a wide margin, and a model made of trees is hard to read. One small tree is not. This one was grown on the 803 training people with three questions at most on any path. Before you trust a model made of many trees, you should be able to use one tree with a pencil.

## What you will learn

- How a tree turns a row into a prediction: one yes-or-no question at a time, from the top.
- That every prediction is the average charge of the training people who reached the same leaf.
- Why a tree can treat smokers and non-smokers differently, where a line cannot.

## Before you start

Nothing to set up. A phone calculator helps for step 3.

## The tree

Start at the top. Answer each question about the person; follow **yes** or **no** until you reach a leaf. The leaf gives the prediction (the average yearly charges of the training people who ended there) and how many training people that was.

```text
Is the person a non-smoker?
├── yes ─ Is age 44 or under?
│         ├── yes ── Is age 32 or under?
│         │          ├── yes ─▶ leaf 1:  4,341 dollars  (232 people)
│         │          └── no ──▶ leaf 2:  7,174 dollars  (138 people)
│         └── no ─── Is age 51 or under?
│                    ├── yes ─▶ leaf 3: 10,460 dollars  (104 people)
│                    └── no ──▶ leaf 4: 13,567 dollars  (158 people)
└── no ── Is BMI 30.1 or under?
          ├── yes ── Is age 40 or under?
          │          ├── yes ─▶ leaf 5: 18,605 dollars   (49 people)
          │          └── no ──▶ leaf 6: 25,766 dollars   (36 people)
          └── no ─── Is age 44 or under?
                     ├── yes ─▶ leaf 7: 38,545 dollars   (50 people)
                     └── no ──▶ leaf 8: 46,076 dollars   (36 people)
```

## Steps

1. **Find each person's leaf.** Five validation people, so the tree never saw them. Write the leaf number and the prediction in the worksheet. Columns the tree never asks about (sex, children, region) do not change the route.

    | Person | Age | Sex | BMI | Children | Smoker | Region | Actual charges |
    |---|---:|---|---:|---:|---|---|---:|
    | A | 25 | female | 24.3 | 3 | no | southwest | 4,392 |
    | B | 49 | female | 33.3 | 2 | no | northeast | 10,371 |
    | C | 60 | female | 36.0 | 0 | no | northeast | 13,229 |
    | D | 33 | male | 24.8 | 0 | yes | northeast | 17,905 |
    | E | 57 | female | 31.2 | 0 | yes | northwest | 43,579 |

2. **Work out each miss.** Miss = actual − predicted. A negative miss means the tree predicted too much.

3. **Average the misses, signs dropped**, and compare with D11's line on the same five people. The line predicted 3,214 · 12,679 · 15,263 · 28,402 · 36,067.

4. **Answer in one line each:**
    - How many different predictions can this tree ever give?
    - Which question does the tree ask smokers that it never asks non-smokers? What does that say about BMI?
    - Can this tree predict a charge below zero? Why or why not?

## Check yourself

| Person | Leaf |
|---|---:|
| A | 1 |
| C | 4 |
| E | 8 |

The tree's average miss on these five people is under 1,000 dollars; the line's is over 4,000. Five people are not a test: this is to see how a tree predicts, not to judge it.

## Hint

For person D: non-smoker? no → BMI 24.8 is 30.1 or under, yes → age 33 is 40 or under, yes.

## Bonus

The line gives smoking one fixed amount for everyone. In this tree, how much more does a smoker of 57 with a BMI over 30.1 pay than a smoker of 57 with a BMI of 30.1 or under? And for non-smokers, does BMI change the prediction at all?

## References

Tree grown on the 803 training people of `ml.insurance_groups` (activity 01), at most three questions deep; thresholds rounded to the nearest whole year and to 0.1 of BMI. Medical Cost Personal Datasets, course copy in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md).
