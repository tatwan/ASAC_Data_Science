# Course datasets

These are the datasets you use in the labs and assignments. Each folder holds the CSV files and a README that gives the source, licence, row counts, what each column means and how to load the files into BigQuery. When a dataset has more than one table, its README also has a diagram of how the tables connect: which column links each pair and how many rows on one side match a row on the other. Read it before you write a join.

## Datasets in this folder

| Folder | What it is | Where you use it |
|---|---|---|
| [`nakheel/`](nakheel/README.md) | Nakheel Retail, a clothing and footwear retailer in Jordan: customers, products, orders and order lines over 24 months. Synthetic, written for this course | From D04 through SQL and Power BI, and in the graded assignments |
| [`nakheel_stores/`](nakheel_stores/README.md) | Nakheel Retail's store sales as files: two yearly exports, one file per shop, a hand-typed store list, website orders as JSON, a raw till export and monthly targets. Made from the Nakheel tables for this course | D17 (Power Query: append, a folder of files, merge) and its labs |
| [`owid_life_expectancy/`](owid_life_expectancy/README.md) | Life expectancy at birth for countries and regions, 1950–2023, from Our World in Data | D03 lab and D04 practice questions |
| [`pagila/`](pagila/README.md) | Films, film categories and the table that links them, from the Pagila sample database | D07 activity 08 and the D07 lab |
| [`intl_football/`](intl_football/README.md) | Every men's international football match since 1872, with goal scorers and penalty shootouts, to 30 September 2026 | Assignment 1 (SQL), loaded on D10 |
| [`hotel_bookings/`](hotel_bookings/README.md) | 119,390 bookings for a resort hotel and a city hotel in Portugal, 2015–2017, with cancellations and prices, from Antonio, Almeida and Nunes (2019) | Assignment 2 (machine learning), issued on D16 |
| [`ml_classics/`](ml_classics/README.md) | Eight small, well-known machine-learning datasets: salaries, medical insurance costs, car fuel economy (Auto MPG), telecom customer churn, employee attrition, mall shoppers, Palmer penguins and a wholesaler's clients | D11, D12 and D13, to learn regression, classification and clustering in BigQuery ML |

Three more datasets live elsewhere:

- **D01 retail tables.** Four small tables used on D01, kept in [module 01](../../modules/01-data-foundations/datasets/w01_retail/README.md). In Week 2 you load them into BigQuery as the dataset `D03`.
- **`bigquery-public-data.ml_datasets.penguins`.** The Palmer penguins (344 penguins, three species), hosted by Google. Used in D12 lab 05 and D13 activity 03, with nothing to download. Source: [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/), CC0. A fixed copy with the same columns is in [`ml_classics/penguins.csv`](ml_classics/penguins.csv), for reference.
- **`bigquery-public-data.thelook_ecommerce`.** A large online-store dataset that Google hosts. You query it where it is, with nothing to download, when a lesson needs a realistic number of rows. Google can update it, so your results may differ from a classmate's on another day. No graded answer depends on it.

## Why more than one dataset

Most of your work uses Nakheel Retail, including the graded assignments unless a brief says otherwise. Assignment 1 is the exception: it uses the international football results, so you apply the SQL to data you have not seen. Staying with one business lets you follow the same data from raw tables to a finished Power BI report.

Other datasets appear when an idea is easier to see somewhere else: life expectancy to practise filtering and sorting on real public data, and a film catalogue for a join through a linking table. Databases look different in health, media and every other sector, and working with more than one shape of data prepares you for that. You meet at most one new dataset in a session.

## Using the files

- Load each file into BigQuery with the dataset and table names given in that folder's README. The steps are in [Upload a CSV to BigQuery](../../modules/02-sql/resources/upload-a-csv-to-bigquery.md).
- Do not edit or clean a file before you upload it. The expected answers in the labs come from these exact files, and the Nakheel tables contain problems on purpose for you to find.
- These are fixed copies. They do not change when the original source is updated, so the expected answers stay the same for the whole course.

## Licences and attribution

| Dataset | Terms |
|---|---|
| Nakheel Retail, D01 retail tables | Written for this course. No real people or businesses are in them |
| Life expectancy | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) (Our World in Data) and [CC BY 3.0 IGO](https://creativecommons.org/licenses/by/3.0/igo/) (United Nations) |
| Pagila | The permission notice in [`pagila/LICENSE.txt`](pagila/LICENSE.txt) |
| Hotel bookings | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) (Antonio, Almeida and Nunes, *Data in Brief*, 2019) |
| International football results | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) (public domain), Mart Jürisoo |
| Classic ML datasets | Per file, in [`ml_classics/README.md`](ml_classics/README.md#sources): Auto MPG and Wholesale customers are [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), the penguins [CC0](https://creativecommons.org/publicdomain/zero/1.0/); the others link to their public pages |

If you reuse the life expectancy or Pagila data outside the course, for example in a portfolio project, copy the attribution from its README.

## Coming later

Later modules add versions of Nakheel built for their topic: messy files to clean in Power Query, ready-made tables for data modelling and DAX, and small training and test tables for machine learning. Each module's README links to them when they are released.
