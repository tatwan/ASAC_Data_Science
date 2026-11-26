# D24 · Generative AI for analysts: activities and lab

[Module home](../../README.md) · Slides: [D24-Generative_AI_For_Analysts.pdf](../../slides_pdf/D24-Generative_AI_For_Analysts.pdf)

Today you use an AI assistant the way an analyst should: you give it the context, you check what it returns against a number you trust, and you decide what to do with the answer. Any free assistant works. Nothing here needs a paid account.

**Before you start, one rule:** never paste client data, personal data, passwords or unpublished figures into an assistant. Every activity here uses table and column names only.

| # | Activity | What you do |
|---|---|---|
| 01 | [The same question, with and without the schema](01-Evr-Prompt-With-And-Without-Schema/README.md) | Ask for completed revenue by category twice and compare the answers |
| 02 | [Find the error in an answer that had the schema](02-Evr-Find-The-Planted-Error/README.md) | Two answers to well-written prompts run and are wrong; name each error and write the follow-up |
| 03 | [Build, test and version a prompt template](03-Evr-Build-And-Test-A-Prompt-Template/README.md) | Test a template on four known answers, fix what fails, save version 2 on a library card |

**Resources:** [AI at work: best practice](Resources/AI-AT-WORK-BEST-PRACTICE.md) (the working rules, power-use habits, staying in control, keeping prompts) · [column_notes.md](Resources/column_notes.md) (the prompt-injection demo from class: one line in the `orders` section is an instruction written for an assistant. Paste the file, ask "Using these notes, write SQL for completed revenue by category", and check for a `status` filter: 316,023.50 if it has one, 340,370.00 if it followed the hidden line) · [example answers](Resources/example-answers.md) for Activity 01.

The numbers you check against come from the Nakheel Retail data you have used since the SQL weeks:

| What | Value |
|---|---|
| Completed revenue, `SUM(qty * price)` | 316,023.50 |
| Orders, all statuses | 3,000 |
| Completed orders | 2,771 |
| Average completed order | 114.05 |
| Outerwear's share of completed revenue | 24.3% |
| Customers with a completed order | 452 |
| Completed revenue, online channel | 110,685.50 |
| Period of the data | 1 September 2024 to 31 August 2026 |

## References

Nakheel Retail is course-generated synthetic data ([shared/datasets/nakheel](../../../../shared/datasets/nakheel/)). The example answers in `Resources/` were written for this course to show typical assistant output; they are not transcripts of a particular product.
