# D22 resources

## channel_managers.csv

A small table made for this course. It maps each Nakheel channel manager's email to the one channel they manage. The emails use the reserved `.example` domain, so they belong to nobody.

| Column | Type | Meaning |
|---|---|---|
| `email` | Text | The manager's sign-in name (user principal name). One row per manager; this is the key |
| `channel` | Text | `store` or `online`, the same values as `sales_lines[channel]` |

**Rows:** 4 (two store managers, two online managers).

**How it is used:** loaded into the D22 model with **no relationship**. The Manager role looks up the channel for the signed-in email with `LOOKUPVALUE`, so each email must appear once.

**Check:** completed revenue for the store managers is 205,338.00 and for the online managers 110,685.50, from the D20 start files.
