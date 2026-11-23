# Activity 05 · A dynamic Manager role that reads who is signed in

Nakheel has four channel managers. With static roles, someone must add each manager to the right role, and a new channel needs a new role. You replace both roles with one role that looks up the signed-in person's email in a small table. Everything here works on a free account.

**Where:** Power BI Desktop, in the **same** `D22.pbix` as Activities 00–04. You add `channel_managers` to this model, next to `sales_lines`: a role can only read tables that are in its own model, so the list of managers has to live there. No new report, no new file.

Download [channel_managers.csv](../Resources/channel_managers.csv) ([what it contains](../Resources/README.md)) and save it next to your `D22.pbix`.

| email | channel |
|---|---|
| rana.haddad@nakheel.example | store |
| omar.khalil@nakheel.example | store |
| lina.saleh@nakheel.example | online |
| sami.nasser@nakheel.example | online |

| Step | What you need | Feature |
|---|---|---|
| 1 | Each manager's channel in the model | A table with no relationship |
| 2 | One rule that works for every manager | USERPRINCIPALNAME and LOOKUPVALUE |
| 3 | Proof that two managers see two channels | View as → Other user |
| 4 | What someone missing from the table sees | View as → Other user |
| 5 | The new role in the Service | Publish again |

## 1. Load channel_managers

**Why this step.** The role needs to know which channel belongs to which email. Keeping that in a table means a new manager is a new row, not a new role.

In the open `D22.pbix`, select **Home → Get data → Text/CSV**, choose `channel_managers.csv` and select **Load**. It becomes a second table in the Data pane, beside `sales_lines`. Open **Model view**. Both tables have a column called `channel`, so Desktop may draw a relationship line between them; if it did, select the line and delete it. The role will look the channel up itself, and a relationship here would be many-to-many.

**C1.** `channel_managers` has **4 rows** (Table view) and no relationship line in Model view.

## 2. Write the Manager role

**What the Manager role is.** In Activity 04 each role had its channel typed in: Store keeps `"store"`, Online keeps `"online"`. You would add every store manager to Store and every online manager to Online, by hand, and a third channel would need a third role. The **Manager** role replaces both with **one rule that works out the channel for whoever opens the report**. Every manager is a member of this one role; the table you just loaded decides which channel each of them sees.

**How the rule works out the channel.** Two DAX functions do it:

- `USERPRINCIPALNAME()` returns the email of the person who opened the report.
- `LOOKUPVALUE(column to return, column to search, value to find)` finds one row in a table and returns one of its values, like a lookup in Excel.

Follow Lina through it:

| Step | What Power BI does | Result for Lina |
|---|---|---|
| 1 | `USERPRINCIPALNAME()` | `lina.saleh@nakheel.example` |
| 2 | `LOOKUPVALUE(channel_managers[channel], channel_managers[email], …)` finds her row in `channel_managers` and returns its channel | `"online"` |
| 3 | The rule becomes `[channel] = "online"` and is checked on every row of `sales_lines` | the online lines stay; the store lines disappear |

For Rana, the same rule becomes `[channel] = "store"`. One rule, a different result for each person: that is what **dynamic** means.

**Write it.**

1. Select **Modeling → Manage roles**. Keep the Store and Online roles; the new role is added beside them.
2. Under **Roles**, select **+ New** and rename it `Manager`.
3. Under **Tables**, select `sales_lines`. Select **Switch to DAX editor** (top right): the drop-down editor cannot call functions such as `USERPRINCIPALNAME()`.
4. Type the rule:

   ```dax
   [channel] = LOOKUPVALUE(
       channel_managers[channel],
       channel_managers[email], USERPRINCIPALNAME()
   )
   ```

   Read it as: keep the sales line if its channel equals the channel on the signed-in person's row of `channel_managers`.

5. Under **Tables**, select `channel_managers` and type a second rule:

   ```dax
   [email] = USERPRINCIPALNAME()
   ```

   *Why:* without it, a manager could put `channel_managers` in a table visual and read every other manager's email. This rule keeps only their own row. It does not change which sales they see.

6. Select **Save**.

**C2.** **Manage security roles** saves with no error. **Manager** shows a filter icon on two tables, `sales_lines` and `channel_managers`.

| Role | Members (in the Service) | Its rule on `sales_lines` |
|---|---|---|
| Store | every store manager, added by hand | `[channel] = "store"` |
| Online | every online manager, added by hand | `[channel] = "online"` |
| Manager | all four managers | `[channel] =` the channel on their own row of `channel_managers` |

A new manager now needs one new row in `channel_managers`, not a change to any role.

## 3. Test as Lina, then as Rana

**Why this step.** In Desktop you are signed in as yourself, and you are not in the table. **Other user** lets you type a manager's email so `USERPRINCIPALNAME()` returns it. Desktop does not know who is in which role yet, so you also tick the role.

Select **Modeling → View as**. Tick **Other user** and type the email exactly as below, letters only, with no quote marks or spaces around it:

lina.saleh@nakheel.example

Tick **Manager**. Select **OK**. The banner should read *Now viewing as: Manager, lina.saleh@nakheel.example*. Then repeat with:

rana.haddad@nakheel.example

**If every visual is blank,** read the banner. If the email shows inside quote marks or backticks (for example `` `lina.saleh@nakheel.example` ``), the marks were typed as part of the email, so it matches no row in `channel_managers`. Open **View as** again and retype it without them. The same blank appears for a misspelled email: the lookup is exact.

The two ticks answer two different questions:

| Tick | The question it answers | Where this comes from in the Service |
|---|---|---|
| **Other user** + the email | *Who are you?* This is what `USERPRINCIPALNAME()` returns | the person who signs in |
| **Manager** | *Which roles are you in?* | the members you add to the role (Security page) |

Desktop has no members: roles get members only in the Service. So in Desktop you tick the role to say "treat this person as a member of Manager".

**C3.** As Lina the card shows **110,685.50** (online). As Rana it shows **205,338.00** (store).

**Planned dead end.** Tick **Other user** with Lina's email but leave **Manager** unticked. The card shows **316,023.50**: without a ticked role, Desktop applies no rule, so you still see the author's view. The Service is stricter: once a model has roles, a Viewer who is in none of them sees **no data**. That is why, in the Service, every manager must be added to the Manager role.

## 4. Test an email that is not in the table

**Why this step.** A security rule must fail safe. Someone who is not in the table should see nothing, not everything.

Open **View as**, tick **Other user** and **Manager**, and type guest@nakheel.example (no quote marks). Select **OK**, look at the card, then select **Stop viewing**.

**C4.** The card is **blank**. `LOOKUPVALUE` found no row, returned blank, and no sales line has a blank channel.

**What just happened.** One role now serves every manager. Adding a manager means adding a row to `channel_managers` and refreshing; nobody edits the roles. In the Service, every manager still has to be a member of the Manager role, and RLS applies only to people with the Viewer role (or who open the report through sharing or an app).

## 5. Publish again

Save the file and select **Home → Publish → My workspace → Replace**. **C5.** In the Service, the D22 semantic model's **… → Security** lists three roles: **Store**, **Online** and **Manager**.

## Trial or Pro: add members in the Service

Publish to a workspace. In the workspace, open the semantic model's **More options (…) → Security**, select **Manager** and add people by email or a Microsoft Entra security group. Select **More options (…) → Test as role** next to the role to check it. Your own email is not in `channel_managers`, so as yourself the role shows a blank card; that is the expected result.

[Microsoft: row-level security in Power BI](https://learn.microsoft.com/en-us/fabric/security/service-admin-row-level-security) · [Microsoft: LOOKUPVALUE](https://learn.microsoft.com/en-us/dax/lookupvalue-function-dax)
