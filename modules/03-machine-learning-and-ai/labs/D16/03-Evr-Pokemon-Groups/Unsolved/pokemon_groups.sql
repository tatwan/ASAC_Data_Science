-- D16 · What kinds of Pokémon are there? Clustering, start to finish · Starter
-- Run one statement at a time, in order. CREATE MODEL and the ML. functions run in BigQuery only.
-- The README explains each step: read it first, run the SQL, then compare with "What you should see".

-- Step 1 · Look: one row is one Pokémon, or one form of it
SELECT COUNT(*) AS rows_in_table,
       COUNT(DISTINCT pokedex_no) AS different_pokemon,
       ROUND(AVG(hp)) AS hp, ROUND(AVG(attack)) AS attack,
       ROUND(AVG(defense)) AS defense, ROUND(AVG(speed)) AS speed
FROM ml.pokemon;

-- Step 2 · Create the model
CREATE OR REPLACE MODEL ml.pokemon_groups
OPTIONS (model_type = 'KMEANS',
         num_clusters = 4) AS
SELECT hp, attack, defense, sp_attack, sp_defense, speed
FROM ml.pokemon;

-- Step 3 · Evaluate
SELECT ROUND(davies_bouldin_index, 2) AS davies_bouldin,
       ROUND(mean_squared_distance, 2) AS mean_squared_distance
FROM ML.EVALUATE(MODEL ml.pokemon_groups);

-- Step 4 · Predict, and read the groups
SELECT centroid_id,
       COUNT(*) AS pokemon_in_group,
       ROUND(AVG(hp)) AS hp, ROUND(AVG(attack)) AS attack,
       ROUND(AVG(defense)) AS defense, ROUND(AVG(sp_attack)) AS sp_attack,
       ROUND(AVG(sp_defense)) AS sp_defense, ROUND(AVG(speed)) AS speed,
       ROUND(AVG(total)) AS total
FROM ML.PREDICT(MODEL ml.pokemon_groups, TABLE ml.pokemon)
GROUP BY centroid_id
ORDER BY total;

SELECT name, total, centroid_id
FROM ML.PREDICT(MODEL ml.pokemon_groups, TABLE ml.pokemon)
WHERE name IN ('Pikachu', 'Magikarp', 'Gengar', 'Snorlax', 'Charizard', 'Mewtwo')
  AND form IS NULL
ORDER BY total;

-- Step 5 · Save the groups as a view
CREATE OR REPLACE VIEW ml.v_pokemon_groups AS
SELECT pokemon_id, name, form, type1, type2, generation,
       hp, attack, defense, sp_attack, sp_defense, speed, total,
       centroid_id
FROM ML.PREDICT(MODEL ml.pokemon_groups, TABLE ml.pokemon);

SELECT COUNT(*) AS pokemon_grouped,
       COUNT(DISTINCT centroid_id) AS groups_found
FROM ml.v_pokemon_groups;
