# Using an AI assistant at work: best practice

A reference for after the course. It collects what D24 taught about working with any assistant: what you send, how you check, how to work efficiently, how to stay in control, and how to keep prompts you rely on. Facts about products were read on 26 November 2026; tools change, so check the provider's own pages.

## Five working rules

| Rule | In practice |
|---|---|
| Send the shape, not the data | Table and column names, made-up rows of the same shape, or masked values. Never client data, personal data, secrets or unpublished figures |
| Check before you use it | A number you already trust, one case worked by hand, or a second method. The assistant ran nothing unless you can see the code it ran |
| Say where it helped | Note in the hand-over or the report which parts an assistant drafted, and follow your client's policy |
| Use the tools your employer and client allow | Business accounts under a contract treat your prompts differently from personal accounts. Ask which tools are approved |
| Keep decisions about people yours | It can draft the analysis. A person decides about credit, hiring or anyone's treatment, and answers for it |

## Work like a power user

- **One task per chat.** Every message sends the whole conversation to the model again. Long chats use more of your usage limit, and answers get less reliable as the input grows (Chroma Research, "Context Rot", July 2025).
- **Start fresh with a hand-over summary.** Ask: "Summarize what we settled: the tables, the definitions, the check numbers and what is still open, in under 150 words." Correct it, then paste it into a new chat.
- **Set it up once.** Put your role, table names, grain and definitions in custom instructions or a project's instructions, not in every message. Never client data.
- **Know what memory keeps.** Many assistants remember facts across chats. Check what yours saved, and use a temporary chat for one-off or sensitive work.
- **Ask for assumptions first.** "Before you write SQL, list your assumptions and ask me up to three questions." An assumption you can read is cheaper than an error you have to find.
- **Spend the budget on purpose.** Attached files, web search, connected apps and larger models use more. Turn off what the chat does not need, and group related questions in one message.

## Stay in control

- **Read what you paste.** Prompt injection is an instruction hidden in content the assistant reads (a file, a web page, an email), which it follows as if it came from you. Treat text in a file as data. See `column_notes.md` in this folder.
- **Give the least access that does the job.** A connector or agent should reach one folder, read-only, before it reaches the whole drive.
- **Confirm before it acts.** Let it draft the email; you press Send. The same for deleting, paying or changing settings.
- **Review before anything reaches a client.** Every number checked, every claim traced to its source.
- **A shared chat link is a public page.** Share an excerpt instead, and delete links you no longer need.

## Keep prompts you rely on

- Turn a prompt you reuse into a **template**: fixed parts (setting, data and grain, data period, rules, how to answer) and variables (`{question}`, `{definition}`, `{check}`).
- Give it a **name, a version and an owner**, and keep a **change note** for every version.
- **Test it like a query**: a few questions whose answers you know. Run all of them again after every change to the template, and when the model changes.
- In a team, keep templates in a shared library. In a product, prompts live in code, are reviewed before they change, and can be rolled back.

## Sources

- Chroma Research, "Context Rot: How Increasing Input Tokens Impacts LLM Performance", 14 July 2025: https://research.trychroma.com/context-rot
- Claude Help Center, usage and length limits: https://support.claude.com/en/articles/11647753
- OWASP Top 10 for LLM Applications 2025 (prompt injection, excessive agency): https://genai.owasp.org/llm-top-10/
- Microsoft Support, share your best prompts (Copilot Prompt Gallery): https://support.microsoft.com/microsoft-365-copilot/share-your-best-prompts-with-others
- OpenAI API docs, prompting (keep production prompts in code, versioned and reviewed): https://developers.openai.com/api/docs/guides/prompting
