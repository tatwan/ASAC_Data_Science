# What kinds of Pokémon are there? Clustering, start to finish

In this activity, you will group 1,215 Pokémon by their six battle stats with k-means, read what each group has in common, give the groups names, and save every Pokémon's group as a view.

**In class:** following along · **Data:** `ml.pokemon` (uploaded in "Before you start") → `ml.pokemon_groups`, `ml.v_pokemon_groups` · **Starter:** `Unsolved/pokemon_groups.sql`

## The story

Every Pokémon has six base stats: HP, Attack, Defense, Special Attack, Special Defense and Speed. Players talk about "tanks", "sweepers" and "glass cannons" without anyone having written those categories into the game. Can a model find kinds of Pokémon from the numbers alone? There is no label here, as with D13's mall customers: the model groups Pokémon that have similar stats, and we decide what the groups mean.

## What you will learn

- The same five steps with no label: `KMEANS` takes only the features.
- To read a group by its averages, and to name it from the data.
- That the group numbers (`centroid_id`) are labels BigQuery picks at random, so the view keeps the numbers and the names come later.

## Before you start: upload `pokemon.csv`

Each of today's four activities starts by uploading its own file into your `ml` dataset. The four files are in the course GitHub repository, in the folder [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md).

1. **Download the file.** Open [`pokemon.csv`](../../../../../shared/datasets/ml_recap/pokemon.csv) on GitHub and click **Download raw file** (the downward arrow, top right). Do not open it in Excel and save it again.
2. **Upload it.** Next to `ml`, **⋮** → **Create table**. **Create table from:** Upload; choose `pokemon.csv`; **File format:** CSV. **Table:** `pokemon`. **Schema:** tick **Auto detect**. **Create table**. The steps are the same as in [Upload a CSV to BigQuery](../../../../02-sql/resources/upload-a-csv-to-bigquery.md).

**Check:** `SELECT COUNT(*) FROM ml.pokemon;` returns 1,215.

## Step 1 · Look: one row is one Pokémon, or one form of it

```sql
SELECT COUNT(*) AS rows_in_table,
       COUNT(DISTINCT pokedex_no) AS different_pokemon,
       ROUND(AVG(hp)) AS hp, ROUND(AVG(attack)) AS attack,
       ROUND(AVG(defense)) AS defense, ROUND(AVG(speed)) AS speed
FROM ml.pokemon;
```

**What you should see:** 1,215 rows for 1,025 different Pokémon (Mega and regional forms have their own rows), and averages of about 71 HP, 81 Attack, 75 Defense and 70 Speed. The six stats are on the same scale, from single digits to about 250.

## Step 2 · Create the model

```sql
CREATE OR REPLACE MODEL ml.pokemon_groups
OPTIONS (model_type = 'KMEANS',
         num_clusters = 4) AS
SELECT hp, attack, defense, sp_attack, sp_defense, speed
FROM ml.pokemon;
```

No `input_label_cols`: there is nothing to predict. `num_clusters = 4` asks for four groups. BigQuery scales each column before measuring distance (`standardize_features` is TRUE by default; D13).

## Step 3 · Evaluate

```sql
SELECT ROUND(davies_bouldin_index, 2) AS davies_bouldin,
       ROUND(mean_squared_distance, 2) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.pokemon_groups);
```

**What you should see:** a Davies–Bouldin index of about 1.6. Lower means tighter, better separated groups. On its own the number says little; it helps when you compare different numbers of groups (the bonus does). As on D13, a score does not tell you whether the groups are useful: reading them does.

## Step 4 · Predict, and read the groups

```sql
SELECT centroid_id,
       COUNT(*) AS pokemon_in_group,
       ROUND(AVG(hp)) AS hp, ROUND(AVG(attack)) AS attack,
       ROUND(AVG(defense)) AS defense, ROUND(AVG(sp_attack)) AS sp_attack,
       ROUND(AVG(sp_defense)) AS sp_defense, ROUND(AVG(speed)) AS speed,
       ROUND(AVG(total)) AS total
FROM ML.PREDICT(MODEL ml.pokemon_groups, TABLE ml.pokemon)
GROUP BY centroid_id
ORDER BY total;
```

`ML.PREDICT` on a k-means model adds `centroid_id`, the group each Pokémon is closest to.

**What you should see:** four groups. Your `centroid_id` numbers will differ; read the averages.

| Group (by total) | Pokémon | What stands out | A name |
|---|---:|---|---|
| lowest total, about 300 | about 396 | every stat about 50 | first-stage Pokémon |
| total about 478 | about 332 | Speed about 96, Attack about 92 | fast attackers |
| total about 483 | about 263 | Defense about 105, Speed about 50 | tanks |
| highest total, about 597 | about 224 | Special Attack about 118, every stat high | powerhouses |

Then find some famous ones:

```sql
SELECT name, total, centroid_id
FROM ML.PREDICT(MODEL ml.pokemon_groups, TABLE ml.pokemon)
WHERE name IN ('Pikachu', 'Magikarp', 'Gengar', 'Snorlax', 'Charizard', 'Mewtwo')
  AND form IS NULL
ORDER BY total;
```

**What you should see:** Magikarp and Pikachu with the first-stage group, Gengar with the fast attackers, Snorlax with the tanks, Charizard and Mewtwo with the powerhouses.

## Step 5 · Save the groups as a view

```sql
CREATE OR REPLACE VIEW ml.v_pokemon_groups AS
SELECT pokemon_id, name, form, type1, type2, generation,
       hp, attack, defense, sp_attack, sp_defense, speed, total,
       centroid_id
FROM ML.PREDICT(MODEL ml.pokemon_groups, TABLE ml.pokemon);

SELECT COUNT(*) AS pokemon_grouped,
       COUNT(DISTINCT centroid_id) AS groups_found
FROM ml.v_pokemon_groups;
```

**What you should see:** 1,215 Pokémon in 4 groups. The view keeps `centroid_id`, not the names: retrain the model and the numbers can swap, so names belong where you can check them against the averages (in a report, or a small lookup table you write after reading step 4).

## Check yourself

| Step | Rows returned | One value to check |
|---|---:|---|
| 1 | 1 | 1,215 rows · 1,025 different Pokémon |
| 3 | 1 | Davies–Bouldin about 1.6 |
| 4 | 4 and 6 | group sizes about 396 · 332 · 263 · 224; Snorlax with the tanks |
| 5 | 1 | 1,215 · 4 |

The group sizes and averages come from k-means with the same settings outside BigQuery; BigQuery's random starts can move a few dozen Pokémon between groups.

## If something goes wrong

- **`Invalid value: num_clusters`:** check the spelling; the option is `num_clusters`.
- **The groups are all bands of HP:** `standardize_features` was switched off. Leave it out.
- **Step 4's second query returns more than six rows:** the `form IS NULL` line is missing, so the special forms come back too (Mega Charizard, Mega Mewtwo, Mega Gengar, Partner Pikachu and others).

## Hint

To name a group, compare its averages with the whole table's from step 1: which stat is furthest above or below?

## Bonus

Train `ml.pokemon_groups_6` with `num_clusters = 6` and compare its Davies–Bouldin index (about 1.5). Which of the four groups split, and do the new groups have a story? Then count the legendary-looking powerhouses by `generation`.

## References

Pokémon base stats through Generation 9, from [`lgreski/pokemonData`](https://github.com/lgreski/pokemonData), extending Alberto Barradas's Kaggle dataset [Pokémon with stats](https://www.kaggle.com/datasets/abcsds/pokemon) (CC0 1.0); course copy in [`shared/datasets/ml_recap`](../../../../../shared/datasets/ml_recap/README.md), taken 27 October 2026. Pokémon names are trademarks of Nintendo, Creatures and Game Freak. BigQuery ML: [CREATE MODEL for k-means](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans), [ML.EVALUATE](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-evaluate), [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict), Google Cloud.
