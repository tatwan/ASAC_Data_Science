# Lab 06 · An access and refresh plan for the Nakheel report

Nakheel wants the channel report in use by next Monday. Before anyone publishes, the head of sales asks for a one-page plan: who gets the report and how, which rows each person sees, how it stays current, and how it is labelled. You write that plan. No Power BI is needed; a document or a sheet of paper will do. This is practice for Assignment 3 and is not handed in.

Use your D22 model: the Manager role from [Activity 05](../05-Evr-Dynamic-Role/README.md) and the report from [Activity 03](../03-Evr-Publish-Pin-Alert/README.md).

**The people**

| Person | What they do with the report |
|---|---|
| Huda, head of sales | Reads every channel |
| Rana and Omar, store managers | Read store sales only |
| Lina and Sami, online managers | Read online sales only |
| Yazan, data analyst | Builds his own reports on the same model |
| You, the BI developer | Edits the model and the report |

**The facts:** the company has Pro licences and no capacity. The report reads the four CSVs from your laptop today. The managers want the numbers updated every morning.

| Step | Decision | Where it was taught |
|---|---|---|
| 1 | A workspace role for each person | Part 1, the four roles |
| 2 | How each person receives the report, and which security role they are in | Parts 1 and 2 |
| 3 | The refresh: schedule, credentials, gateway | Part 3 |
| 4 | A label and an endorsement | Part 3 |

## 1. Give each person a workspace role

**Why this step.** The workspace role decides what a person can change. It also decides whether row-level security applies: Admin, Member and Contributor can edit the model, so RLS does not restrict them.

Write a table with each person and one role: Admin, Member, Contributor or Viewer. Give each person the lowest role that does their job. Some people may need no workspace role at all if they receive the report another way (step 2).

**Check.** Only you have a role above Viewer. If any manager is a Contributor, they would see all 316,023.50 instead of their own channel; change it.

## 2. Choose how each person receives the report and their security role

**Why this step.** Sharing, an app and Build permission reach different audiences. Once the model has a role, a reader who is in no role sees no rows at all, so every reader needs one.

For each person, write the route (share, app or Build) and the security role. The Manager role only knows the four managers. Decide how Huda sees every channel: add a role named `All` on `sales_lines` with the rule `TRUE()`, or put her in both static roles from Activity 04. Decide what Yazan sees: Build does not lift RLS.

**Check.** Every reader is in a role: the four managers in Manager, Huda in a role that keeps all rows (316,023.50), and Yazan in a role you chose on purpose. The managers and Huda get the app; Yazan gets Build.

## 3. Plan the refresh

**Why this step.** The published model is a copy. Without a refresh, the managers read the numbers from the day you published. Where the files live decides whether the Service can reach them.

Write the schedule (time and days), where the credentials are stored, and whether a gateway is needed. Then write the change that removes the gateway.

**Check.** With the CSVs on your laptop, a gateway is needed (personal mode is enough for one developer). With the files moved to OneDrive or SharePoint, no gateway is needed. One morning refresh is within Pro's limit of 8 a day.

## 4. Label and endorse the model

**Why this step.** A label tells everyone how sensitive the content is, and exports carry it. Endorsement tells other analysts which model to build on.

Choose a sensitivity label for the semantic model and say why (it holds customer names and cities). Say whether you will promote the model or ask for certification, and who does each.

**Check.** Your plan says that the label does not stop anyone opening the report: the workspace roles and the security roles from steps 1 and 2 do that. You can promote the model yourself; certification needs a reviewer named by the admin.

**What you have.** A plan another developer could follow: roles, routes, security, refresh and labels, each with its reason. In the D23 lab the source is BigQuery, a cloud source, so step 3 needs no gateway.

[Microsoft: workspace roles](https://learn.microsoft.com/en-us/power-bi/collaborate-share/service-roles-new-workspaces) · [Microsoft: when a gateway is needed](https://learn.microsoft.com/en-us/power-bi/guidance/powerbi-implementation-planning-data-gateways)
