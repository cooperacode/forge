---
name: ingest
description: "Add new sources to the wiki, creating and updating pages as needed. Always update the index and log."
---

# Skill: Ingest

You were invoked by the orchestrator because the user wants to add a new source to the wiki. Follow every step in order. Do not skip steps. Do not proceed to the next step without completing the current one.

The orchestrator passed `INPUT_PATH` and `OUTPUT_PATH` at the top of this prompt — use those values for all file operations.

---

## Step 1 — Read the source

Locate the file the user indicated in `{INPUT_PATH}`. Read it in full before doing anything else.

- If the file is a PDF or image, extract all readable text first.
- If the file has images with relevant content (charts, diagrams, screenshots), note them explicitly — you will reference them in the summary page.
- If the file does not exist in `{INPUT_PATH}`, tell the user and stop. Do not ingest from outside `{INPUT_PATH}`.

---

## Step 2 — Discuss before writing

Before touching any wiki file, surface the key takeaways to the user. Be concise: 3–5 bullet points max. Then ask:

- Is there anything here you want emphasized or ignored?
- Does this contradict or reinforce anything already in the wiki?
- Are there entities or concepts here that already have pages?

Wait for the user's response. Adjust your understanding before proceeding. If the user says "go ahead" with no changes, proceed with your own judgment.

This step exists because the human curates, the LLM executes. Do not skip it even if the source seems straightforward.

---

## Step 3 — Create the source summary page

Create `{OUTPUT_PATH}sources/<slug>.md` where `<slug>` is a lowercase hyphenated version of the source title.

Use this exact frontmatter:

```yaml
---
title: "Full title of the source"
slug: source-slug
type: source
date_ingested: YYYY-MM-DD
original_file: {INPUT_PATH}filename.ext
authors: []
tags: []
related_concepts: []
related_entities: []
---
```

Page structure:

```markdown
## Summary

2–4 paragraphs. What is this source about? What is its main argument or contribution?
Write as if explaining to someone who will never read the original.

## Key claims

- Claim 1 — be specific, include data or quotes where relevant.
- Claim 2
- ...

## Connections to existing wiki

What does this source confirm, challenge, or add nuance to?
Reference existing pages using [[wikilinks]].
If it contradicts an existing page, flag it explicitly:

> [!contradiction] This source disputes [[concepts/existing-page]] on X.

## Open questions

What does this source leave unanswered? What would be worth investigating next?

## Notable quotes

> "Direct quote if relevant." (p. N or timestamp)
```

---

## Step 4 — Identify pages to update

Before writing anything, scan `{OUTPUT_PATH}index.md` and list every page that this source touches. Think across three categories:

**Entities** — people, organizations, products, datasets, models named in the source. Check if a page already exists. If yes, update it. If no, create it.

**Concepts** — themes, techniques, theories, arguments the source engages with. Same rule: update if exists, create if not.

**Overview** — `{OUTPUT_PATH}overview.md` always gets updated when a new source is ingested.

Write this list out before proceeding:

```
Pages to update:
- entities/author-name (exists)
- concepts/self-attention (exists)
- concepts/cross-attention (new)
- overview (always)
```

Ask the user if this list looks right. Adjust if needed.

---

## Step 5 — Update or create each page

Work through the list from Step 4 one page at a time.

### Updating an existing page

Read the current page fully. Then:

- Add new information in the appropriate section.
- Do not delete existing content unless it is factually wrong — use `> [!outdated]` instead.
- If the source contradicts something on the page, add a `> [!contradiction]` callout with a link to the source page.
- Add `[[sources/slug]]` to the page's `related_sources` frontmatter field.
- Add a `## From [[sources/slug]]` subsection if the source adds substantial new content.

### Creating a new entity page

Frontmatter:

```yaml
---
title: "Entity Name"
slug: entity-slug
type: entity
subtype: person | organization | model | dataset | product
tags: []
related_sources: [sources/slug]
related_concepts: []
---
```

Write a factual summary of who or what this entity is, based only on what your sources say. Do not add external knowledge not present in the wiki.

### Creating a new concept page

Frontmatter:

```yaml
---
title: "Concept Name"
slug: concept-slug
type: concept
tags: []
related_sources: [sources/slug]
related_entities: []
related_concepts: []
---
```

Page structure:

```markdown
## Definition

What is this concept? One clear paragraph.

## How it works

Mechanism, process, or explanation.

## Evidence and claims

What do ingested sources say about this? Cite with [[wikilinks]].

## Connections

Links to related concepts and entities.

## Open questions
```

### Updating overview

`{OUTPUT_PATH}overview.md` is the synthesis layer. After every ingest:

- Add a one-paragraph summary of what this source contributes to the overall picture.
- Update the "Current state of knowledge" section if the source meaningfully changes the thesis.
- Add any new contradictions or unresolved tensions to the "Open tensions" section.

---

## Step 6 — Update navigation files

After all pages are written, update the two navigation files. These are owned by the orchestrator but you write the entries during ingest.

**`{OUTPUT_PATH}index.md`** — add new pages in the correct category. For updated pages, do not add a duplicate entry.

**`{OUTPUT_PATH}log.md`** — append one entry at the top of the log (most recent first):

```markdown
## [YYYY-MM-DD] ingest | Title of source

Pages touched: sources/slug, entities/x, concepts/y, overview (N total)
New pages created: concepts/cross-attention
Contradictions flagged: 1 (see sources/slug)
```

---

## Step 7 — Close the loop

Tell the user what was done in plain language. No need to list every file — summarize:

```
Done. Ingested "Attention Is All You Need" (2017).

Created: sources/attention-is-all-you-need, concepts/cross-attention
Updated: concepts/self-attention, concepts/transformer, entities/vaswani-ashish, overview
Flagged: 1 contradiction with concepts/positional-encoding

Anything you want me to revisit before we continue?
```

---

## Language

Write all wiki pages and messages to the user in `{LANGUAGE}`. If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. If `LANGUAGE` is not set, default to English.

## Rules

- Never ingest a file that is not in `{INPUT_PATH}`. If the user pastes content directly into chat, ask them to save it to `{INPUT_PATH}` first, then ingest from there. This keeps the source layer clean.
- Never overwrite existing wiki content without reading it first.
- Never answer questions during ingest. If the user asks something mid-flow, note it and say you will answer after the ingest is complete.
- If a step produces more than ~20 file changes, pause and ask the user if they want to continue or scope down.
- Prefer updating existing pages over creating new ones. Fragmentation is the enemy of a useful wiki.
