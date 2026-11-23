# D24 · Generative AI for analysts: activities and lab

[Module home](../../README.md) · Slides: [D24-Generative_AI_For_Analysts.pdf](../../slides_pdf/D24-Generative_AI_For_Analysts.pdf)

Today you use an AI assistant the way an analyst should: you give it the context, you check what it returns against a number you trust, and you decide what to do with the answer. Any free assistant works. Nothing here needs a paid account.

**Before you start, one rule:** never paste client data, personal data, passwords or unpublished figures into an assistant. Every activity here uses table and column names only.

| # | Activity | What you do |
|---|---|---|
| 01 | [The same question, with and without the schema](01-Evr-Prompt-With-And-Without-Schema/README.md) | Ask for completed revenue by category twice and compare the answers |
| 02 | [Find the planted error](02-Evr-Find-The-Planted-Error/README.md) | Two generated answers run and are wrong; name each error and write the follow-up |
| 03 | [Green, amber, red](03-Par-Green-Amber-Red/README.md) | Sort ten client scenarios by risk |
| 04 | [Your AI usage charter](04-Evr-AI-Usage-Charter/README.md) | Write five commitments in your own words and hand them in |
| 05 | [Lab: your own prompt template](05-Lab-Your-Prompt-Template/README.md) | After class, not submitted |

The numbers you check against come from the Nakheel Retail data you have used since the SQL weeks:

| What | Value |
|---|---|
| Completed revenue, `SUM(qty * price)` | 316,023.50 |
| Orders, all statuses | 3,000 |
| Completed orders | 2,771 |
| Average completed order | 114.05 |
| Outerwear's share of completed revenue | 24.3% |

## References

Nakheel Retail is course-generated synthetic data ([shared/datasets/nakheel](../../../../shared/datasets/nakheel/)). The example answers in `Resources/` were written for this course to show typical assistant output; they are not transcripts of a particular product.
