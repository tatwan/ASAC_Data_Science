# Machine learning and AI literacy

[Course home](../../README.md) · [Schedule](../../course/STUDENT_SCHEDULE.md)

**D11–D15 and D24 · Status: D11 to D15 ready (slides and labs; BigQuery numbers still being confirmed); D24 in production.**

Understand how models learn and are evaluated, build them in BigQuery ML, hand their outputs to Power BI, and use generative AI with verification and privacy controls.

## Sessions

| Session | Date | Focus |
|---|---|---|
| D11 | Sun 18 Oct | Machine learning 1: what learning means, and regression (begun) |
| D12 | Mon 19 Oct | Machine learning 2: regression and BigQuery ML (D11 continued), then classification begins |
| D13 | Wed 21 Oct | Machine learning 3: regression review, classification (D12 continued), then clustering begins |
| D14 | Sun 25 Oct | Machine learning 4: clustering (D13 continued), then improving models begins |
| D15 | Mon 26 Oct | Machine learning 5: forests, boosting and better features (D14 continued) · forecasting is optional self-study |
| D24 | Tue 10 Nov | Generative AI for analysts |

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
| Nakheel Retail (course data) | `nakheel.*` | D11 lab 08, D12 lab 06, D13 lab 09, D14 lab 11, D15 labs 13–14 (optional) | [shared/datasets/nakheel](../../shared/datasets/nakheel/README.md) |

## Materials

| Folder | Intended contents | Status |
|---|---|---|
| [slides_pdf/](slides_pdf/) | The slides for each session, as PDF | D11, D12, D13, D14, D15 |
| [labs/](labs/) | Guided/independent instructions, starter and restart files; released solutions | [D11](labs/D11/), [D12](labs/D12/), [D13](labs/D13/), [D14](labs/D14/), [D15](labs/D15/) |
| [assignments/](assignments/) | Relevant weekly sets, graded briefs, rubrics and submission instructions | Planned |
| [datasets/](datasets/) | Small domain-specific fixtures or links to the shared dataset | D11 to D15 use the [classic ML datasets](../../shared/datasets/ml_classics/README.md); see [Datasets](#datasets) |
| [resources/](resources/) | Setup instructions, cheat sheets and official reference links | [BigQuery ML reference links](resources/bigquery-ml-reference-links.md) · [BigQuery ML functions in Module 3](resources/bigquery-ml-functions.md) |

Keep D01–D26 in filenames, for example `D03-select-and-filter.md`; use `W02-...`, `A01-...` and `P01-...` for weekly sets, assignments and practicals. These are naming examples, not existing files.

Each session's lab is done after class to practise that day's ideas; it is not submitted or graded, and its solution is released afterwards. Assignments keep their published due dates. Editable slide sources are kept privately; only PDF slides are published.

Each lab will state prerequisites, input/version, numbered steps, three checkpoints, expected output, a self-check and a fallback. Shared datasets live once in [shared/datasets/](../../shared/datasets/README.md); link to them rather than copying them between modules.

Only released solutions belong here. Keep unreleased keys and instructor notes in the local ignored `instructor/` folder or the approved private teaching store. Graded submissions go to the institution’s private collection route, not issues or pull requests in this course repository.

Assignment 2 covers the machine-learning sessions (issued D16 after the machine-learning part, due before 4:00 PM D21, Thu 5 Nov). The AI usage charter is completed in class on D24.
