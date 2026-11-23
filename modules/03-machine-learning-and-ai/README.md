# Machine learning and AI literacy

[Course home](../../README.md) · [Schedule](../../course/STUDENT_SCHEDULE.md)

**18–29 October 2026, and generative AI on 26 November**

Understand how models learn and are evaluated, build them in BigQuery ML, hand their outputs to Power BI, and use generative AI with verification and privacy controls.

## Sessions

| Date | Topic | Slides | Labs |
|---|---|---|---|
| Sun 18 Oct | Machine learning 1: what learning means; regression | [D11](slides_pdf/D11-BigQuery_ML_Predicting_A_Number.pdf) | [D11](labs/D11/) |
| Mon 19 Oct | Machine learning 2: regression in BigQuery ML; classification | [D11](slides_pdf/D11-BigQuery_ML_Predicting_A_Number.pdf), [D12](slides_pdf/D12-Classification_Judging_The_Prediction.pdf) | [D11](labs/D11/), [D12](labs/D12/) |
| Wed 21 Oct | Machine learning 3: classification; clustering · **Assignment 1 due before 4:00 PM** | [D12](slides_pdf/D12-Classification_Judging_The_Prediction.pdf), [D13](slides_pdf/D13-Clustering_Groups_Without_A_Label.pdf) | [D12](labs/D12/), [D13](labs/D13/) |
| Sun 25 Oct | Machine learning 4: clustering; improving models with trees | [D13](slides_pdf/D13-Clustering_Groups_Without_A_Label.pdf), [D14](slides_pdf/D14-Improving_Models_Trees_And_Features.pdf) | [D13](labs/D13/), [D14](labs/D14/) |
| Mon 26 Oct | Machine learning 5: forests, boosting and better features. Forecasting (D15 slides 1–49) is optional self-study | [D14](slides_pdf/D14-Improving_Models_Trees_And_Features.pdf), [D15](slides_pdf/D15-Forecasting_Explaining_Serving.pdf) | [D14](labs/D14/), [D15](labs/D15/) |
| Thu 29 Oct | Machine learning 6: explaining models and MLOps; then Power BI and a first report · **Assignment 2 issued** | [D15](slides_pdf/D15-Forecasting_Explaining_Serving.pdf), [D16](../04-power-query/slides_pdf/D16-MLOps_Four_Models_PowerBI.pdf) | [D15](labs/D15/), [D16](labs/D16/) |
| Thu 26 Nov | PL-300 quiz (45 minutes), then generative AI for analysts. Last session · **Assignment 3 due before 4:00 PM** | [D24](slides_pdf/D24-Generative_AI_For_Analysts.pdf) | [D24](labs/D24/README.md) |

## Datasets

Each algorithm is learned first on small, well-known datasets, so the attention goes to what the model and each option do. Nakheel comes back in the optional self-study labs, where the data needs joining and cleaning first. The CSV files, upload steps and checks are in [shared/datasets/ml_classics](../../shared/datasets/ml_classics/README.md).

| Dataset | BigQuery table | Used on | Public page |
|---|---|---|---|
| Salary and years of experience (30 hires) | `ml.salary_data` | D11 activity 02, lab 06 | [Kaggle: Salary data, simple linear regression](https://www.kaggle.com/datasets/karthickveerakumar/salary-data-simple-linear-regression) |
| Medical Cost Personal Datasets | `ml.insurance` | D11 activities 03 and 04, lab 06; D14 activities 01–06, labs 08–10; D15 activities 07–08, labs 11–12 | [Kaggle: Medical Cost Personal Datasets](https://www.kaggle.com/datasets/mirichoi0218/insurance); from Brett Lantz, *Machine Learning with R* (Packt, 2013) |
| Auto MPG | `ml.cars` | D11 labs 05–07 | [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/9/auto+mpg) (Quinlan, 1993) |
| Telco Customer Churn (IBM sample data) | `ml.telco` | D12 activities 01 and 02, lab 03; D14 lab 07 | [IBM on GitHub](https://github.com/IBM/telco-customer-churn-on-icp4d) · [Kaggle: Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) |
| IBM HR Analytics Employee Attrition & Performance (ten columns) | `ml.employees` | D12 lab 04 | [Kaggle: IBM HR Analytics Employee Attrition & Performance](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset) |
| Palmer penguins | `bigquery-public-data.ml_datasets.penguins` (public, nothing to upload) | D12 lab 05, D13 activity 03 | [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/) (Horst, Hill and Gorman, 2020; data from Gorman, Williams and Fraser, 2014) · [Google's tutorial that uses the table](https://docs.cloud.google.com/bigquery/docs/linear-regression-tutorial) |
| Mall Customer Segmentation Data (200 card members) | `ml.mall` | D13 activities 01, 02 and 04, labs 05–06 | [Kaggle: Mall Customer Segmentation Data](https://www.kaggle.com/datasets/vjchoudhary7/customer-segmentation-tutorial-in-python); made for teaching, from the *Machine Learning A–Z* course |
| Wholesale customers (440 clients of a Portuguese food distributor) | `ml.wholesale` | D13 labs 07–08 | [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/292/wholesale+customers) (Cardoso, 2013) |
| Air Passengers (monthly airline passengers, 1949–1960, thousands) | `ml.air_passengers` | D15 activities 01–06, labs 09–10 | [R datasets: AirPassengers](https://rweb.stat.umn.edu/R/library/datasets/html/AirPassengers.html) (Box, Jenkins and Reinsel, series G) |
| Diamonds (53,940 diamonds and their prices) | `ml.diamonds` | D16 activity 02, labs 06–07 | [ggplot2 `diamonds`](https://github.com/tidyverse/ggplot2) · [shared/datasets/ml_recap](../../shared/datasets/ml_recap/README.md) |
| Titanic passengers (1,309) | `ml.titanic` | D16 activity 03, lab 07 | [Vanderbilt Biostatistics: titanic](https://hbiostat.org/data/repo/titanic) (Harrell and Dawson) |
| Pokémon base stats (1,215 Pokémon and forms) | `ml.pokemon` | D16 activity 04 | [Kaggle: Pokémon with stats](https://www.kaggle.com/datasets/abcsds/pokemon) · [lgreski/pokemonData](https://github.com/lgreski/pokemonData) |
| US births per day, 2000–2014 | `ml.us_births` | D16 activity 05, lab 08 | [FiveThirtyEight: births](https://github.com/fivethirtyeight/data/tree/master/births) |
| Nakheel Retail (course data) | `nakheel.*` | D11 lab 08, D12 lab 06, D13 lab 09, D14 lab 11, D15 labs 13–14, D16 lab 09 (optional) | [shared/datasets/nakheel](../../shared/datasets/nakheel/README.md) |

## Materials

| Folder | What is in it | Open |
|---|---|---|
| [slides_pdf/](slides_pdf/) | The slides for each session, as PDF | D11, D12, D13, D14, D15, D16 |
| [labs/](labs/) | Activities and labs, with starter files and solutions | [D11](labs/D11/), [D12](labs/D12/), [D13](labs/D13/), [D14](labs/D14/), [D15](labs/D15/), [D16](labs/D16/) |
| [assignments/](assignments/) | Assignment brief and rubric | [Assignment 2: hotel bookings](assignments/A02-ML-Hotel-Bookings/README.md) |
| [datasets/](datasets/) | Datasets | D11 to D15 use the [classic ML datasets](../../shared/datasets/ml_classics/README.md), D16 the [recap datasets](../../shared/datasets/ml_recap/README.md); see [Datasets](#datasets) |
| [resources/](resources/) | Guides and reference links | [BigQuery ML reference links](resources/bigquery-ml-reference-links.md) · [BigQuery ML functions in Module 3](resources/bigquery-ml-functions.md) |

Each session's lab is done after class to practise that day's ideas. Labs are not submitted or graded.

Assignment 2 covers the machine-learning sessions: issued Thursday 29 October, due before 4:00 PM on Thursday 5 November. The AI usage charter is completed in class on 26 November.
