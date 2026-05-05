---
name: requirements
description: "Generate a requirements artifact from the active wiki. Produces quality attributes & constraints for Strategic items; functional requirements with acceptance criteria for Product items."
---

# Skill: Requirements List

You were invoked by the orchestrator because the user wants to generate a requirements list for the active work item. Your job is to extract and structure every requirement present in the wiki — not to invent requirements from your training knowledge.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, and `WORK_ITEM_TYPE` — use those values for all file operations and document metadata.

Follow every step in order.

---

## Step 1 — Verify content sources

Attempt to read `{OUTPUT_PATH}index.md` (the local wiki index for this work item) and check whether `{CONTEXT_PATH}` is non-empty.

Determine the content situation using the table below:

| `{OUTPUT_PATH}index.md` | `{CONTEXT_PATH}` | Action |
|--------------------------|------------------|--------|
| exists and has entries   | any              | Set `LOCAL_WIKI = true`. Note the total number of pages listed (sources, concepts, entities). |
| missing or no entries    | has content      | Set `LOCAL_WIKI = false`. Warn the user: "No sources ingested for this work item — proceeding with upstream context only." |
| missing or no entries    | empty or absent  | Stop. Tell the user no sources have been ingested and there is no upstream context. Suggest running `/ingest` first. |

---

## Step 2 — Determine the requirements mode

Check `{WORK_ITEM_TYPE}` (from the orchestrator context):

| Work Item Type | Mode |
|---|---|
| Theme, Initiative | **Constraints mode** — extract quality attributes, architectural constraints, and compliance obligations |
| Epic, Feature | **Functional mode** — extract functional requirements with acceptance criteria |

Proceed in the corresponding mode for all subsequent steps.

---

## Step 3 — Read all content sources

**If `LOCAL_WIKI = true`**, read in this order:

1. `docs/wiki/overview.md` — global synthesis (read directly)
2. All `sources/` pages listed in `{OUTPUT_PATH}index.md` — follow each link to load from `docs/wiki/`
3. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
4. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the local wiki list (or as the sole source if `LOCAL_WIKI = false`). These are upstream artifacts from the parent work item:
- In NFR mode: upstream `requirements.md` from a grandparent Strategic item defines pre-existing constraints — do not contradict them, reference them.
- In Functional mode: upstream `requirements.md` (NFR), `brief.md`, and `feature-list.md` set the frame — functional requirements must stay within those boundaries.
- Note each upstream source when carrying a fact forward.

**In Constraints mode**, extract:
- Performance, scalability, reliability, availability targets
- Security and privacy requirements
- Compliance and regulatory obligations
- Interoperability and integration constraints
- Architectural principles or guardrails explicitly stated

**In Functional mode**, extract:
- Capabilities the system must provide
- Rules and validations described in sources
- Explicit user interactions or flows described
- Data requirements (fields, formats, volumes)
- Integration points with other systems
- Out-of-scope statements (exclusions are requirements too)

Track the source wiki page for every requirement you find. Never create a requirement not backed by a wiki page or upstream artifact.

---

## Step 4 — Confirm scope with the user

Before writing, list what you found:

```
Based on the wiki ({N} pages), I found:

• {N} requirements to document
• {N} requirements backed by multiple sources
• {N} areas with no coverage (gaps)

Categories detected: [list]

Is there anything you want excluded, rephrased, or split differently?
```

Wait for a response. If the user says "go ahead", proceed.

---

## Step 5 — Write the requirements artifact

Create `{OUTPUT_PATH}artifacts/requirements.md`.

Use `template.md` in this same skill directory.

- Use **Constraints Mode Template** when `{WORK_ITEM_TYPE}` is `Theme` or `Initiative`.
- Use **Functional Mode Template** when `{WORK_ITEM_TYPE}` is `Epic` or `Feature`.

Fill all placeholders and preserve the section order.

Optional quality check: run `scripts/validate.sh {OUTPUT_PATH}artifacts/requirements.md`.

Reference output format example: `examples/sample.md`.

---
## Step 6 — Update navigation files

**`{OUTPUT_PATH}artifacts/index.md`** — create if it does not exist, then add or update the requirements entry:

```markdown
- [[requirements]] — Quality Attributes & Constraints (generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | Requirements ({mode})

Generated: artifacts/requirements.md
Mode: {Constraints | Functional}
Requirements documented: N
Gaps flagged: N
Sources read: N pages
```

---

## Step 7 — Close the loop

```
Done. Requirements artifact generated at {OUTPUT_PATH}artifacts/requirements.md.

Mode: {Constraints | Functional}
Requirements documented: N
Gaps flagged: N (sections without wiki coverage)
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Never create a requirement not backed by a wiki page.** Use `> [!gap]` for areas the wiki does not cover.
- **Never write to wiki pages in `docs/wiki/`.** This skill is read-only on the wiki.
- **Never skip Step 4.** The user must confirm scope before you write a long structured table.
- **Priority values are Must / Should / Could / Won't only.** Do not use numeric scales unless the wiki explicitly states them.
- **Each requirement gets its own row.** Do not bundle multiple requirements into one row.
- **Source citation format:** use `[[sources/slug]]`, `[[concepts/slug]]`, or `[[entities/slug]]` for local wiki pages. For files read from `{CONTEXT_PATH}`, substitute the actual runtime value and write the full repo-relative path: `[[docs/strategic/initiatives/20260504-foo/output/artifacts/brief.md]]`. Never use short names (`[[brief.md]]`) or computed relative paths (`[[../../...]]`) for cross-work-item references — they resolve to the wrong location.
