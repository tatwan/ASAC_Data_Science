# Activity 02 · A static store role, tested with View as

Nakheel has a store manager and an online manager. Each should open the same report and see only their own channel's sales. You write one security role for each channel and test both in Desktop before anything is published. Everything here works on a free account.

Start from the file in the [D22 entry page](../README.md). Completed Revenue on a card is 316,023.50.

| Step | What you need | Feature |
|---|---|---|
| 1 | A rule that keeps only store sales lines | Manage roles |
| 2 | The same rule for online | A second role |
| 3 | Proof that the store role works | View as |
| 4 | What a person in both roles sees | View as, two roles |

## 1. Create the Store role

**Why this step.** A role is a filter on one table. Power BI checks the rule on every row; rows where it is TRUE stay visible to members of the role, and the others disappear from every visual and measure.

Select **Modeling → Manage roles → New**. Name the role `Store`. Under **Select tables**, choose `sales_lines`. Under **Filter data**, choose the column `channel`, the condition **Equals** and the value `store`. Select **Save**.

**C1.** Select **Switch to DAX editor**. The rule reads `[channel] = "store"`. The default editor and the DAX editor show the same rule two ways.

## 2. Create the Online role

**Why this step.** A static role has its value typed in, so each channel needs its own role. Nakheel has two channels, so two roles.

In **Manage roles**, select **New** again. Name it `Online`, choose `sales_lines` and set `channel` **Equals** `online`. Select **Save**.

**C2.** The role list shows two roles, **Store** and **Online**, each with one rule on `sales_lines`.

## 3. Test the Store role with View as

**Why this step.** Desktop cannot add people to a role, but it can show the report as a role member would see it. Test every role before you publish.

Select **Modeling → View as**. Tick **Store** and select **OK**. A banner at the top says you are viewing as Store.

**C3.** The Completed Revenue card shows **205,338.00**. A channel slicer, if you have one, lists only store.

## 4. View as both roles

**Why this step.** One person can be in more than one role. Power BI then shows the rows that any of their roles allows, not only the rows all roles share.

Open **View as** again, tick **Store** and **Online**, and select **OK**. Then select **Stop viewing** in the banner.

**C4.** With both roles the card shows **316,023.50**, the full total. After **Stop viewing** it shows 316,023.50 again, as the author.

**What just happened.** The rule sits on `sales_lines`, the table every measure adds up. Store keeps 4,756 of the 7,516 sales lines, so every measure, card and chart shrinks to the store's rows. Products, customers and dates are not filtered: a product slicer still lists every product.

[Microsoft: row-level security in Power BI](https://learn.microsoft.com/en-us/fabric/security/service-admin-row-level-security)
