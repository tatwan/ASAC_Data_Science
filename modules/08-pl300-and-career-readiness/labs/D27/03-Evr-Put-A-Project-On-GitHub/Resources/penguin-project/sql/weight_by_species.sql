-- Average body mass of each penguin species, in grams.
-- One row in the table is one penguin. Two penguins have no body mass, and AVG skips them.
SELECT
  species,
  COUNT(body_mass_g) AS penguins_weighed,
  ROUND(AVG(body_mass_g)) AS average_mass_g
FROM `bigquery-public-data.ml_datasets.penguins`
GROUP BY species
ORDER BY average_mass_g DESC;
