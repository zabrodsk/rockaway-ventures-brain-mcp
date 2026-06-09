---
name: rockaway-ventures-brain
description: Use the Rockaway Ventures brain to answer questions, look up companies, founders, people, deals, funds, meetings, or enrich CSV rows. Trigger when the user says Rockaway brain, Ventures brain, look this up in the brain, search what we know, or asks for Ventures brain context.
---

# Rockaway Ventures Brain

Use this when the user wants to ask the Rockaway Ventures brain a question.

## Keep It Simple For The User

Do not make the user say tool names. Do not explain MCP, QMD, tokens, headers, or setup unless they ask.

Good user prompts include:

- "Use the Rockaway brain to answer this..."
- "Use the Rockaway brain to look up this company."
- "Use the Rockaway brain to enrich this CSV."
- "What do we know about this founder?"

## Hidden Agent Instructions

Use only the `rockaway-ventures` MCP. Stay inside the Rockaway Ventures brain unless the user explicitly asks for cross-brain context.

Start every normal lookup with `memory_lookup`.

Use `get_page` only for the strongest matches when full detail is useful. Use `get_links` and `get_backlinks` only when relationship context matters.

Never write to the brain. Never print or store bearer tokens.

## Answer Style

Give a plain-language answer. Mention confidence when useful. Keep sources short: page titles or slugs are enough unless the user asks for a fuller source trail.

For CSVs, return simple columns:

```text
row, match, confidence, summary, next step, sources
```

If the request is vague, search first. Ask a follow-up only if the results are too broad or ambiguous.
