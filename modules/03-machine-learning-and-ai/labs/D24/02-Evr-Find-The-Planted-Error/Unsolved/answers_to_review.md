# Activity 02 · two answers to review

These answers were written for the course in the style of an AI assistant. Each one runs. Each one is wrong.

## Answer A · SQL

**The question:** "How many completed orders do we have?"

**The assistant's answer:**

> Here is a query that counts your orders:

```sql
SELECT COUNT(*) AS completed_orders
FROM nakheel.orders;
```

**It returned:** `3,000`

## Answer B · DAX

**The question:** "What share of completed revenue does each category bring?"

**The assistant's answer:**

> This measure divides each category's revenue by total revenue:

```dax
Share of Revenue =
DIVIDE([Completed Revenue], [Completed Revenue])
```

**In a table by category it shows:**

| category | Completed Revenue | Share of Revenue |
|---|---:|---:|
| Outerwear | 76,637.00 | 100.0% |
| Shoes | 62,373.50 | 100.0% |
| Bottoms | 50,535.00 | 100.0% |
| Accessories | 43,525.00 | 100.0% |
| Sportswear | 42,365.00 | 100.0% |
| Tops | 40,588.00 | 100.0% |
| **Total** | **316,023.50** | **100.0%** |
