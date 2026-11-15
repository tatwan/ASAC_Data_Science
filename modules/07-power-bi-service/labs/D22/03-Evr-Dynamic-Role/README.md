# Activity 03 · A dynamic Manager role that reads who is signed in

Nakheel has four channel managers. With static roles, someone must add each manager to the right role, and a new channel needs a new role. You replace both roles with one role that looks up the signed-in person's email in a small table. Everything here works on a free account.

Start from your Activity 02 file. Download [channel_managers.csv](../Resources/channel_managers.csv) ([what it contains](../Resources/README.md)).

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

## 1. Load channel_managers

**Why this step.** The role needs to know which channel belongs to which email. Keeping that in a table means a new manager is a new row, not a new role.

Select **Home → Get data → Text/CSV**, choose `channel_managers.csv` and select **Load**. Open **Model view**. If Desktop drew a line between `channel_managers` and `sales_lines`, select it and delete it: the role will look the channel up itself.

**C1.** `channel_managers` has **4 rows** (Table view) and no relationship line in Model view.

## 2. Write the Manager role

**Why this step.** `USERPRINCIPALNAME()` returns the email of the person who opened the report. `LOOKUPVALUE` finds that email in `channel_managers` and returns its channel. The rule keeps the sales lines of that channel.

Select **Modeling → Manage roles**. Keep the Store and Online roles from Activity 02; the new role is separate. Select **New**, name it `Manager`, choose `sales_lines` and select **Switch to DAX editor**. Type:

```dax
[channel] = LOOKUPVALUE(
    channel_managers[channel],
    channel_managers[email], USERPRINCIPALNAME()
)
```

Still in the Manager role, choose the `channel_managers` table and type `[email] = USERPRINCIPALNAME()`. This second rule hides the other managers' rows, so nobody can read the list of emails. Select **Save**.

`LOOKUPVALUE` has three parts here. The first, `channel_managers[channel]`, is the column whose value you want back. The second, `channel_managers[email]`, is the column to search. The third, `USERPRINCIPALNAME()`, is the value to search for. The DAX editor is required: functions such as `USERPRINCIPALNAME()` cannot be picked in the default editor.

**C2.** Manage roles saves with no error and lists **Manager** with two tables: `sales_lines` and `channel_managers`.

## 3. Test as Lina, then as Rana

**Why this step.** In Desktop you are signed in as yourself, and you are not in the table. **Other user** lets you type a manager's email so `USERPRINCIPALNAME()` returns it. Desktop does not know who is in which role yet, so you also tick the role.

Select **Modeling → View as**. Tick **Other user** and type `lina.saleh@nakheel.example`. Tick **Manager**. Select **OK**. Then repeat with `rana.haddad@nakheel.example`.

**C3.** As Lina the card shows **110,685.50** (online). As Rana it shows **205,338.00** (store).

## 4. Test an email that is not in the table

**Why this step.** A security rule must fail safe. Someone who is not in the table should see nothing, not everything.

Open **View as**, tick **Other user** and **Manager**, and type `guest@nakheel.example`. Select **OK**, look at the card, then select **Stop viewing**.

**C4.** The card is **blank**. `LOOKUPVALUE` found no row, returned blank, and no sales line has a blank channel.

**What just happened.** One role now serves every manager. Adding a manager means adding a row to `channel_managers` and refreshing; nobody edits the roles. In the Service, every manager still has to be a member of the Manager role, and RLS applies only to people with the Viewer role (or who open the report through sharing or an app).

## Trial or Pro: add members in the Service

Publish to a workspace. In the workspace, open the semantic model's **More options (…) → Security**, select **Manager** and add people by email or a Microsoft Entra security group. Select **More options (…) → Test as role** next to the role to check it. Your own email is not in `channel_managers`, so as yourself the role shows a blank card; that is the expected result.

[Microsoft: row-level security in Power BI](https://learn.microsoft.com/en-us/fabric/security/service-admin-row-level-security) · [Microsoft: LOOKUPVALUE](https://learn.microsoft.com/en-us/dax/lookupvalue-function-dax)
