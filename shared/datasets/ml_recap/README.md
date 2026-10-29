# Four datasets for the machine-learning recap

Four small, well-known datasets, one for each kind of model in the D16 recap. One row is already one example, so the SQL stays short and the attention goes to the steps, which are the same every time: look at the table, create the model, evaluate it, predict, and save the predictions as a view.

| File | Table in BigQuery | One row is one … | Rows | Question | Model |
|---|---|---|---:|---|---|
| [`diamonds.csv`](diamonds.csv) | `ml.diamonds` | diamond | 53,940 | What is this diamond worth? | `LINEAR_REG` |
| [`titanic.csv`](titanic.csv) | `ml.titanic` | Titanic passenger | 1,309 | Who was likely to survive? | `LOGISTIC_REG` |
| [`pokemon.csv`](pokemon.csv) | `ml.pokemon` | Pokémon (or a special form of one) | 1,215 | What kinds of Pokémon are there? | `KMEANS` |
| [`us_births.csv`](us_births.csv) | `ml.us_births` | day | 5,479 | How many babies will be born each day next year? | `ARIMA_PLUS` |

## Get the tables into BigQuery

Each learner uploads the files into their own BigQuery Sandbox, one at the start of each activity (diamonds in activity 01, Titanic in 02, Pokémon in 03, births in 04).

1. **Download.** Click the file name in the table above, then **Download raw file** (the downward arrow, top right). Do not open it in Excel and save it again.
2. **Make sure `ml` exists** (made on D11): `CREATE SCHEMA IF NOT EXISTS ml OPTIONS (location = 'US');`
3. **Upload.** Next to `ml`, **⋮** → **Create table**. **Create table from:** Upload; choose the file; **File format:** CSV. **Table:** the name in the table above, without `ml.`. **Schema:** tick **Auto detect**. **Create table**. The steps are the same as in [Upload a CSV to BigQuery](../../../modules/02-sql/resources/upload-a-csv-to-bigquery.md).

None of the table names is also the name of one of its columns.

## Check the tables

| Table | `COUNT(*)` | Check |
|---|---:|---|
| `ml.diamonds` | 53,940 | `price` 326 to 18,823 dollars · `carat` 0.2 to 5.01 · `cut`, `color`, `clarity` are text |
| `ml.titanic` | 1,309 | `survived` is TRUE or FALSE (BOOLEAN), 500 TRUE · `age` empty (NULL) for 263 passengers · `pclass` 1, 2 or 3 |
| `ml.pokemon` | 1,215 | 1,025 different `pokedex_no` · six stat columns from `hp` to `speed`, whole numbers · `form` and `type2` often empty |
| `ml.us_births` | 5,479 | `birth_date` from 2000-01-01 to 2014-12-31 (DATE) · `births` 5,728 (25 December 2011) to 16,081 |

## Columns

**`diamonds`:** `diamond_id` (added for the course), `carat` (weight; one carat is 0.2 grams), `cut` (Fair, Good, Very Good, Premium, Ideal), `color` (D, the best, to J), `clarity` (I1, the worst, then SI2, SI1, VS2, VS1, VVS2, VVS1, IF, the best), `depth_pct` and `table_pct` (proportions of the cut stone, in per cent), `price` (US dollars), `length_mm`, `width_mm`, `height_mm`. Twenty diamonds have a size of 0 recorded in at least one of the three: a recording error, left in on purpose.

**`titanic`:** `passenger_id` (added), `pclass` (ticket class: 1, 2 or 3), `sex`, `age` (years; fractions for babies; empty when unknown), `sibsp` (brothers, sisters or a husband or wife aboard), `parch` (parents or children aboard), `survived` (TRUE or FALSE). Passengers only; the crew are not in the table.

**`pokemon`:** `pokemon_id` (added), `pokedex_no` (National Pokédex number), `name`, `form` (Mega, regional and other forms; empty for the standard form), `type1`, `type2` (empty for single-type Pokémon), `total` (the sum of the six stats), `hp`, `attack`, `defense`, `sp_attack`, `sp_defense`, `speed`, `generation` (1 to 9).

**`us_births`:** `birth_date`, `day_name` (Monday to Sunday), `births` (births registered in the United States on that day).

## Sources

| File | Original dataset | Licence |
|---|---|---|
| `diamonds.csv` | Prices and attributes of 53,940 round-cut diamonds, the `diamonds` data in the ggplot2 package for R ([`tidyverse/ggplot2`](https://github.com/tidyverse/ggplot2), `data-raw/diamonds.csv`). Columns renamed (`depth` → `depth_pct`, `table` → `table_pct`, `x`, `y`, `z` → `length_mm`, `width_mm`, `height_mm`); `diamond_id` added; values unchanged | The ggplot2 package is released under the [MIT licence](https://github.com/tidyverse/ggplot2/blob/main/LICENSE.md) |
| `titanic.csv` | Passengers of the RMS Titanic, compiled by Frank Harrell and Robert Dawson ([hbiostat.org](https://hbiostat.org/data/repo/titanic)), in the version `Titanicp` of the vcdExtra package for R, taken from the [Rdatasets](https://github.com/vincentarelbundock/Rdatasets) collection. `passenger_id` added; `pclass` written as 1, 2, 3; `survived` written as TRUE or FALSE | vcdExtra is released under GPL-2 or GPL-3 |
| `pokemon.csv` | Pokémon base stats through Generation 9 (1,025 Pokédex numbers with their forms), from [`lgreski/pokemonData`](https://github.com/lgreski/pokemonData), which extends Alberto Barradas's Kaggle dataset [Pokémon with stats](https://www.kaggle.com/datasets/abcsds/pokemon) with stats from pokemondb.net. Columns renamed in lower case (`Sp. Atk` → `sp_attack`); `pokemon_id` added | The original Kaggle data is [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). Pokémon names are trademarks of Nintendo, Creatures and Game Freak; this table is used for teaching only |
| `us_births.csv` | Daily US births 2000 to 2014 from the Social Security Administration, published by FiveThirtyEight for the story "Some People Are Too Superstitious To Have A Baby On Friday The 13th" ([`fivethirtyeight/data`](https://github.com/fivethirtyeight/data/tree/master/births), `US_births_2000-2014_SSA.csv`). The year, month and day columns are combined into `birth_date`; the weekday number is written as `day_name` | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) (FiveThirtyEight's data repository) |

Course copies taken 27 October 2026 from the GitHub repositories above.
