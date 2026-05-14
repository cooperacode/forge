---
name: adr
description: "Generate Architecture Decision Records (ADR) from the active wiki. Produces foundational ADRs for Strategic items; feature-scoped ADRs for Product items. Follows the MADR format."
---

# Skill: ADR (Architecture Decision Record)

You were invoked by the orchestrator because the user wants to generate Architecture Decision Records from the active wiki. Your job is to detect architectural decisions — explicit or implicit — in the wiki and record them in MADR format.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, and `WORK_ITEM_TYPE` — use those values for all file operations and metadata.

Follow every step in order.

## Buddy mode

By default this skill runs non-interactively — it writes the artifact without pausing for confirmation.

If `BUDDY_MODE = true` was passed by the orchestrator, pause at confirmation steps and wait for user input before writing.

> ⚠️ **Language lock:** Write the entire artifact — content, headings, table values, and all messages — in `{LANGUAGE}`. Source documents may be in a different language; never mirror them. This constraint is active from the first character to the last, throughout every step.

---

## Step 1 — Verify content sources

Attempt to read `{OUTPUT_PATH}index.md` and check whether `{CONTEXT_PATH}` is non-empty.

Determine the content situation using the table below:

| `{OUTPUT_PATH}index.md` | `{CONTEXT_PATH}` | Action |
|-------------------------|------------------|--------|
| exists and has content  | any              | Set `LOCAL_WIKI = true`. Note the total number of pages indexed (sources, concepts, entities). |
| missing or empty        | has content      | Set `LOCAL_WIKI = false`. Warn the user: "Local wiki is empty — proceeding with upstream context only." |
| missing or empty        | empty or absent  | Stop. Tell the user the work item has no wiki content and no upstream context. Suggest running `/ingest` first. |

---

## Step 2 — Determine ADR scope

Check `{WORK_ITEM_TYPE}`:

| Work Item Type | ADR scope |
|---|---|
| Theme, Initiative | **Foundational** — architectural style, technology platform, cross-cutting principles |
| Epic, Feature | **Feature-scoped** — library selection, API design choices, data model decisions, integration patterns |

This scope determines what counts as a decision worth recording. Apply it in Step 3.

---

## Step 3 — Detect decisions in the wiki

**If `LOCAL_WIKI = true`**, read in this order:

1. `{OUTPUT_PATH}overview.md`
2. All `sources/` pages
3. All `concepts/` pages
4. All `entities/` pages

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the list above. These are upstream ADRs and artifacts from the parent work item:
- Upstream `adr/` files define already-accepted decisions — do not create a new ADR that contradicts an accepted upstream one without flagging the conflict explicitly.
- If a decision in the local wiki is already captured in an upstream ADR, do not duplicate it — reference it instead: "See upstream ADR-NNN."
- Upstream `brief.md` and `requirements.md` provide architectural context for classifying new decisions.

**What counts as a decision:**
- An explicit choice made between named alternatives ("we chose X over Y because...")
- A technology, framework, library, or platform selected
- An architectural pattern adopted (event-driven, CQRS, REST vs GraphQL, etc.)
- A boundary or interface agreed upon between systems or teams
- A constraint that rules out a category of solutions

**What does NOT count:**
- Requirements (what the system must do)
- Open questions without a resolution
- Preferences stated without rationale

For each decision found, note:
- The decision itself (what was chosen)
- The alternatives mentioned (what was considered but rejected)
- The rationale (why the choice was made)
- The source wiki page

---

## Step 4 — Confirm the decision list with the user

Before writing, surface what you found:

```
I detected {N} architectural decisions in the wiki:

1. {Decision title} — [{Strategic | Feature-scoped}]
   Chosen: {option}
   Alternatives: {options}
   Source: [[sources/slug]]

2. ...

Are these correct? Any decisions I missed or that should be excluded?
```

**Default mode:** Proceed immediately with your judgment. Do not wait for a response.

**Buddy mode:** Wait for a response. Adjust based on user feedback. If the user says "go ahead", proceed.

---

## Step 5 — Lock the output language

Before writing any file, resolve and declare the language that will be used throughout:

1. Read `{LANGUAGE}` from the parameters passed by the orchestrator.
2. Map to the expected locale:
   - `pt-BR` → Brazilian Portuguese
   - `en` → English
   - anything else → English (and warn the user)
3. If `{LANGUAGE}` is not set or is empty, default to `en` and warn: "LANGUAGE was not set — defaulting to English."
4. State the resolved language explicitly before proceeding:

```
Output language locked: {resolved language} ({LANGUAGE})
All artifact content, headings, and messages will be written in this language.
```

**Do not begin writing any file until this step is complete.** This prevents language drift across multiple generated files.

---

## Step 6 — Write one ADR file per decision

Create a numbered ADR file for each confirmed decision at:
`{OUTPUT_PATH}artifacts/adr/NNN-{slug-of-decision-title}.md`

Number sequentially starting at `001`. If ADR files already exist in that folder, continue from the highest existing number.

Use the template from `locales/{LANGUAGE}/template.md` if it exists (e.g., `locales/pt-BR/template.md` when `{LANGUAGE}` is `pt-BR`); otherwise fall back to `template.md`. Fill all placeholders, preserve section order, and do not add, remove, or change the count or hierarchy level of headings.

Validation runs automatically via hook after each Write or Edit. If a validation error appears in context, fix the artifact before proceeding. Do not write the ADR index, update navigation files, or report success before all errors are resolved.

---

## Step 7 — Write the ADR index

Create or update `{OUTPUT_PATH}artifacts/adr/index.md`:

```markdown
---
title: "ADR Index — {WORK_ITEM_TITLE}"
type: artifact
subtype: adr-index
generated: YYYY-MM-DD
---

# Architecture Decision Records: {WORK_ITEM_TITLE}

| # | Title | Status | Date |
|---|-------|--------|------|
| ADR-001 | [[artifacts/adr/001-slug\|Decision title]] | accepted | YYYY-MM-DD |
| ADR-002 | ... | ... | ... |
```

---

## Step 8 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update the `## Artifacts` section:

```markdown
## Artifacts

- [[artifacts/adr/index]] — Architecture Decision Records ({N} ADRs, generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | Architecture Decision Records

Generated: artifacts/adr/ ({N} ADR files + index)
Scope: {Foundational | Feature-scoped}
Decisions recorded: N
Gaps flagged: N (decisions without documented alternatives)
Sources read: N pages
```

**`docs/forge.yaml`** — register the artifact in the work item entry:

1. Find the entry whose `path` matches `{WORK_ITEM_PATH}`.
2. If it has no `artifacts` field, add one as an empty list.
3. If `adr` is not already in the `artifacts` list, append it.

Use the Edit tool. Example — before:
```yaml
  - title: my-work-item
    hierarchyLevel: Strategic
    path: docs/strategic/initiatives/20260504-my-work-item/
```
After:
```yaml
  - title: my-work-item
    hierarchyLevel: Strategic
    path: docs/strategic/initiatives/20260504-my-work-item/
    artifacts:
      - adr
```

If `artifacts` already exists, append `adr` to the list. Never duplicate an entry already present.

---

## Step 9 — Close the loop

```
Done. {N} ADR(s) generated at {OUTPUT_PATH}artifacts/adr/.

ADRs created:
- ADR-001: {title}
- ADR-002: {title}
...

Gaps flagged: N (decisions without documented alternatives in the wiki)
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Never record a decision not present in the wiki.** If the wiki implies a choice but does not state it, do not create an ADR — flag it as a gap instead.
- **Never merge two distinct decisions into one ADR.** One decision = one file.
- **Status is always `accepted` on generation** unless the wiki explicitly marks something as proposed or superseded.
- **Never write to source/concept/entity pages.** ADR generation is read-only on the wiki.
- **Never skip Step 4.** Decisions misidentified here produce misleading ADRs.
- **Never skip Step 5.** Language must be locked before any file is written — never assume or infer the language mid-generation.
- **Alternatives section uses `> [!gap]`** when none were documented — never invent alternatives from training knowledge.
- **Source citation format:** use `[[sources/slug]]`, `[[concepts/slug]]`, or `[[entities/slug]]` for local wiki pages. For files read from `{CONTEXT_PATH}`, substitute the actual runtime value and write the full repo-relative path: `[[docs/strategic/initiatives/20260504-foo/output/artifacts/brief.md]]`. Never use short names (`[[brief.md]]`) or computed relative paths (`[[../../...]]`) for cross-work-item references — they resolve to the wrong location.
