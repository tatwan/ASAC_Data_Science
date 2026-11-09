# D20 · Compare periods and calculate sales-line revenue

You will start a fresh Nakheel model, compare April 2026 with the year so far and last April, and check two ways to calculate revenue. [Read the D20 chapter](../../slides_pdf/D20-Time_Intelligence_SUMX_Report_Design.pdf).

## Download the start files

- [sales_lines.csv](Resources/start/sales_lines.csv) · 7,516 sales lines
- [customers.csv](Resources/start/customers.csv) · 500 customers
- [products.csv](Resources/start/products.csv) · 60 products
- [dates.csv](Resources/start/dates.csv) · 1,096 calendar days
- [Four measure definitions](Resources/start/d19_measures.txt) · paste each as a separate measure

The four files use the synthetic [Nakheel Retail dataset](../../../../shared/datasets/nakheel/README.md), with sales through 31 August 2026. Start a new Power BI file. Use these files even if you have a report from an earlier class. Save this day's model and report so that you can use them again for the later activities on this page.

| Practice | Check |
|---|---|
| [01 · Build the fresh model](01-Evr-Load-Start-Files-And-Measures/README.md) | Completed Revenue is 316,023.50 |
| [02 · Compare revenue over time](02-Evr-Time-Intelligence/README.md) | April YoY is +58.2% |
| [03 · Create a line-value column and use SUMX](03-Evr-SUMX-And-Quick-Measures/README.md) | Compression top stores 48.00 and order 100003 returns 47.00 |
| [04 · Build the first overview](../../../06-visualization-and-storytelling/labs/D20/04-Lab-Overview-Page/README.md) | The completed scope gives 2,771 orders |
| [05 · Optional distribution and relationship practice](../../../06-visualization-and-storytelling/labs/D20/05-Lab-Optional-Distribution-And-Relationship/README.md) | One band counts sales lines, one dot represents a product |

Desktop keeps the model and report in one PBIX. On the web, the semantic model and report are separate workspace items. Create relationships and measures in the semantic model, then open its report to build the visuals. Keep both item names so you can reopen the right pair. Editing and export depend on the account. If a control is missing, use the worked views in the chapter and repeat the same checks in Desktop when you have access. [Microsoft Service model editing](https://learn.microsoft.com/en-us/power-bi/transform-model/service-edit-data-models).
