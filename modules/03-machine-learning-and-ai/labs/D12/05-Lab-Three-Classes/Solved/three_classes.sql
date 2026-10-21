-- D12 · Lab 05 · Three classes: which penguin is it? · Solved
-- The public table is in the US location; your ml dataset must be too.

-- Step 1 · Look first
SELECT species, COUNT(*) AS penguin_count,
       ROUND(AVG(flipper_length_mm), 1) AS avg_flipper,
       ROUND(AVG(body_mass_g)) AS avg_mass
FROM `bigquery-public-data.ml_datasets.penguins`
GROUP BY species;

-- Step 2 · Train: the same statement, a three-valued label
CREATE OR REPLACE MODEL ml.penguin_species
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['species'],
         data_split_method = 'RANDOM', data_split_eval_fraction = 0.2) AS
SELECT island, culmen_length_mm, culmen_depth_mm, flipper_length_mm,
       body_mass_g, sex, species
FROM `bigquery-public-data.ml_datasets.penguins`;

-- Step 3 · Score it
SELECT ROUND(accuracy, 3) AS accuracy, ROUND(precision, 3) AS precision,
       ROUND(recall, 3) AS recall
FROM ML.EVALUATE(MODEL ml.penguin_species);

-- Step 4 · A three-by-three matrix
SELECT *
FROM ML.CONFUSION_MATRIX(MODEL ml.penguin_species);

-- Step 5 · Three probabilities per penguin
SELECT species, predicted_species, predicted_species_probs
FROM ML.PREDICT(MODEL ml.penguin_species,
       (SELECT * FROM `bigquery-public-data.ml_datasets.penguins` LIMIT 5));
