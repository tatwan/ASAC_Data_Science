# Connecting Power BI to Google BigQuery Sandbox

**Objective:** Connect Power BI to Google BigQuery Sandbox (Free Tier) to access datasets and tables for analysis and visualization.

These instructions apply to both **Power BI Desktop** and **Power BI Web (Power BI Service)**.

## Prerequisites

Before starting, ensure that you have:

- A Google account with access to BigQuery Sandbox.
- A Google Cloud project containing at least one dataset and table.
- Power BI Desktop installed or access to [Power BI Web](https://app.powerbi.com/).

## Step 1: Find Your Google Cloud Project ID

1. Open [Google BigQuery Studio](https://console.cloud.google.com/bigquery).
2. Select your Google Cloud project from the project selector at the top of the page.
3. Copy the **Project ID** (not the Project Name).

You will use this ID when configuring the connection in Power BI.

## Step 2: Connect to Google BigQuery

**Power BI Desktop**

1. Open Power BI Desktop.
2. On the **Home** tab, select **Get data > More**.
3. Search for **Google BigQuery**.
4. Select **Google BigQuery**, then click **Connect**.

**Power BI Web**

1. Open [Power BI Web](https://app.powerbi.com/).
2. Go to **My workspace**.
3. Select **New item > Semantic model** (or **Create > Get data**, depending on the interface).
4. Find and select **Google BigQuery** as your data source.

## Step 3: Configure the Connection

In the Google BigQuery connection window:

1. Under **Connectivity mode**, select **Import** if available. Otherwise, use **DirectQuery**.
2. Expand **Advanced options**.
3. Enter your Google Cloud Project ID in **Billing Project ID**.
4. If prompted to create a connection, use the following settings:
   - **Connection name:** GoogleBigQuery
   - **Data gateway:** (none)
   - **Authentication kind:** OAuth or Organizational account
5. Sign in with your **Google account** using OAuth (see Step 4).

> **Important:** The Billing Project ID specifies which Google Cloud project executes and accounts for queries. It does not restrict which projects appear in Power BI. You may still see other projects that your Google account can access.

## Step 4: Authenticate with Google

1. Select **Sign in**.
2. Choose the Google account associated with your BigQuery project.
3. Review and approve the requested permissions.
4. Return to Power BI and continue:
   - **Desktop:** Click **Connect**.
   - **Web:** Click **Next**.

> **Note:** You do not need a Google service account or JSON key when using OAuth authentication.

## Step 5: Select Your Dataset and Tables

Once connected, Power BI displays the **Navigator** window.

1. Expand your Google Cloud project.
2. Expand the dataset containing your tables.
3. Select the table or tables you want to use.
4. Review the data preview.
5. Continue according to your Power BI version:
   - **Desktop:** Select **Transform Data** to open Power Query, or **Load** to load the selected tables directly.
   - **Web:** Click **Next** to continue to Power Query.

## Step 6: Load the Data into Power BI

If you opened Power Query, you can now clean or transform your data before loading it.

When finished:

- **Power BI Desktop:** On the Home tab, select **Close & Apply**.
- **Power BI Web:** Select **Save** (or **Save & close**, depending on the interface), and apply the query changes when prompted.

Once your data is available in the semantic model, you can begin creating reports and visualizations.

## Important Notes

- **BigQuery Sandbox is free** within Google's Sandbox limits. A billing account or credit card is not required.
- **Import** copies data into Power BI. **DirectQuery** leaves data in BigQuery and sends queries when needed.
- DirectQuery interactions count toward your BigQuery query-processing allowance.
- If you cannot see a project or dataset, verify that your Google account has the necessary permissions.
- If you receive a permissions error when executing queries, verify the **Billing Project ID** and your BigQuery permissions.

**You have successfully connected Power BI to Google BigQuery Sandbox.**