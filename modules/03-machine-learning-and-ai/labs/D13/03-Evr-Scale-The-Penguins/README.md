# Grams against millimetres: the penguins, with and without scaling

In this activity, you will cluster 342 penguins twice from the same four measurements, once with scaling switched off and once with it on, and compare each set of groups with the species the penguins really are.

**Data:** `bigquery-public-data.ml_datasets.penguins` (a public table, nothing to upload) · **Starter:** `Unsolved/scale_the_penguins.sql`

## The story

Researchers at Palmer Station, Antarctica, measured penguins of three species: bill (culmen) length and depth in millimetres, flipper length in millimetres, and body mass in grams. Suppose the species column were lost and we asked k-means for three groups. Would they be the three species?

This time there *is* an answer to compare with, which almost never happens with clustering. We use it only to check the groups; the model never sees `species`.

## What you will learn

- Why a column measured in big numbers takes over the distance.
- What `standardize_features` does, and why its default is `TRUE`.
- That clusters are groups the model found, not the right answer, even when they come close.

## Before you start

Your `ml` dataset must be in the US location, because the public table is there (it is, if you created it on D11). Two penguins have no measurements; every block keeps `WHERE body_mass_g IS NOT NULL`, so 342 penguins remain.

## Steps

1. **How spread out is each column? (block 1).** The standard deviation says how far a typical penguin sits from the average. Bill length: about 5.5 mm. Bill depth: 2.0 mm. Flipper: 14.1 mm. Body mass: about **802 g**. A difference of 800 in mass and a difference of 5 in bill length are both "one typical step", but squared inside a distance, the 800 wins by a factor of more than 20,000.

2. **Three groups, no scaling (block 2).** `standardize_features = FALSE`: the four columns go into the distance as they are.

3. **Compare with species (block 3).** One row per group and species, with the lightest and heaviest penguin in each group.

    The groups are bands of body mass. Each group's lightest penguin is heavier than the previous group's heaviest, and two of the three groups mix species. Your sizes depend on the starting centres; one common result is 165 · 107 · 70, another 170 · 111 · 61. About 7 in 10 penguins sit in a group where their own species is the most common one.

4. **The same, scaled (block 4).** `standardize_features = TRUE`: BigQuery turns each column into "standard deviations from the average" before measuring. Now 800 g and 5 mm each count as about one step.

5. **Compare again (block 5).** All 123 Gentoo penguins share one group with nobody else. Most Adelie penguins form a second group, most Chinstraps the third, with a few Adelie penguins with long bills among the Chinstraps. About 9 in 10 penguins now sit in a group where their species is the most common one (0.92 to 0.96, depending on the run).

6. **Think, and answer in Slack:** the scaled groups are close to the species, but not identical. Is the model wrong?

## Check yourself

| Block | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | standard deviations about 5.5, 2.0, 14.1 and 802.0 |
| 3 | 7 or 8 | groups are bands of mass; e.g. lightest 2,700–3,975 g, middle 4,000–4,925 g, heaviest 4,950–6,300 g (all Gentoo) |
| 5 | 5 or 6 | one group holds all 123 Gentoo and nothing else |

Computed outside BigQuery with the same settings before the class ran them; BigQuery's random starts can give a different but similar split.

## Hint

For step 6: k-means groups penguins that measure alike. A long-billed Adelie measures more like a Chinstrap. Species is a fact about the birds; the groups are a summary of the measurements.

## Bonus

Add `flipper_length_mm` alone as the only feature, scaled, with three groups. Which species can it tell apart, and which can it not?

## References

Palmer penguins (Gorman, Williams and Fraser, 2014, *PLoS ONE* 9(3): e90081), as BigQuery's public table `bigquery-public-data.ml_datasets.penguins`; [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/), [CC0](https://creativecommons.org/publicdomain/zero/1.0/). A fixed copy for reference is in [`shared/datasets/ml_classics`](../../../../../shared/datasets/ml_classics/README.md). BigQuery ML: [CREATE MODEL for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans) (`STANDARDIZE_FEATURES`), Google Cloud.
