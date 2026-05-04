---
name: requirements
description: "Generate a requirements artifact from the active wiki. Produces quality attributes & constraints for Strategic items; functional requirements with acceptance criteria for Product items."
---

# Skill: Requirements List

You were invoked by the orchestrator because the user wants to generate a requirements list for the active work item. Your job is to extract and structure every requirement present in the wiki — not to invent requirements from your training knowledge.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, and `WORK_ITEM_TYPE` — use those values for all file operations and document metadata.

Follow every step in order.

---

## Step 1 — Verify wiki has content

Read `{OUTPUT_PATH}index.md`.

- If the file does not exist or is empty, stop. Tell the user the wiki has no content yet and suggest running `/ingest` first.
- Note the total number of pages indexed (sources, concepts, entities).

---

## Step 2 — Determine the requirements mode

Check `{WORK_ITEM_TYPE}` (from the orchestrator context):

| Work Item Type | Mode |
|---|---|
| Theme, Initiative | **Constraints mode** — extract quality attributes, architectural constraints, and compliance obligations |
| Epic, Feature | **Functional mode** — extract functional requirements with acceptance criteria |

Proceed in the corresponding mode for all subsequent steps.

---

## Step 3 — Read all wiki pages

Read in this order:

1. `{OUTPUT_PATH}overview.md`
2. All `sources/` pages listed in `{OUTPUT_PATH}index.md`
3. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
4. All `entities/` pages listed in `{OUTPUT_PATH}index.md`

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the list above. These are upstream artifacts from the parent work item:
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

Track the source wiki page for every requirement you find. Never create a requirement not backed by a wiki page.

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

### Constraints mode (Strategic)

Create `{OUTPUT_PATH}artifacts/requirements.md`:

```markdown
---
title: "Quality Attributes & Constraints — {WORK_ITEM_TITLE}"
type: artifact
subtype: requirements
mode: constraints
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Strategic
generated: YYYY-MM-DD
sources_read: N
---

# Quality Attributes & Constraints: {WORK_ITEM_TITLE}

## Context

One paragraph: what initiative or theme this list serves, and why these requirements matter for decision-making.

---

## Non-Functional Requirements

| ID | Category | Requirement | Priority | Source |
|----|----------|------------|----------|--------|
| NFR-001 | Performance | ... | Must / Should / Could | [[sources/slug]] |
| NFR-002 | Security | ... | ... | [[sources/slug]] |

Categories to use: Performance · Scalability · Reliability · Security · Privacy · Compliance · Interoperability · Usability · Maintainability

---

## Architectural Constraints

Constraints that limit design choices — not requirements about capabilities, but boundaries on how solutions must be built.

| ID | Constraint | Rationale | Source |
|----|-----------|-----------|--------|
| AC-001 | ... | ... | [[concepts/slug]] |

---

## Compliance & Regulatory Obligations

| ID | Obligation | Regulatory Body / Standard | Source |
|----|-----------|--------------------------|--------|
| CO-001 | ... | ... | [[sources/slug]] |

If no compliance obligations were found in the wiki:
> [!gap] No compliance requirements were identified in the ingested sources. Validate with legal and security teams.

---

## Exclusions

Requirements explicitly ruled out in the wiki:

- ...

---

## Open Questions

- [ ] ...

---

## Sources

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
```

---

### Functional mode (Product)

Create `{OUTPUT_PATH}artifacts/requirements.md`:

```markdown
---
title: "Requirements List — {WORK_ITEM_TITLE}"
type: artifact
subtype: requirements
mode: functional
work_item_type: {WORK_ITEM_TYPE}
hierarchy_level: Product
generated: YYYY-MM-DD
sources_read: N
---

# Requirements List: {WORK_ITEM_TITLE}

## Context

One paragraph: what epic or feature this list serves, and how it connects to the broader initiative.

---

## Functional Requirements

| ID | Title | Description | Acceptance Criteria | Priority | Source |
|----|-------|------------|--------------------|----|--------|
| FR-001 | ... | ... | ... | Must / Should / Could | [[sources/slug]] |

Priority scale: **Must** (MVP blocker) · **Should** (important, not MVP blocker) · **Could** (desirable if time allows) · **Won't** (explicitly excluded)

---

## Integration Requirements

System-to-system interactions required:

| ID | Source System | Target System | Interaction | Source |
|----|--------------|--------------|-------------|--------|
| IR-001 | ... | ... | ... | [[sources/slug]] |

---

## Data Requirements

| ID | Data Element | Format | Volume / Frequency | Source |
|----|-------------|--------|--------------------|--------|
| DR-001 | ... | ... | ... | [[sources/slug]] |

---

## Exclusions

Capabilities explicitly out of scope:

- ...

---

## Gaps

Sections where the wiki provided insufficient information:

> [!gap] {Description of what is missing and what source type would fill it}

---

## Open Questions

- [ ] ...

---

## Sources

- [[overview]]
- [[sources/...]]
- [[concepts/...]]
```

---

## Step 6 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update an `## Artifacts` section:

```markdown
## Artifacts

- [[artifacts/requirements]] — Quality Attributes & Constraints (generated YYYY-MM-DD)
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
- **Never write to `{INPUT_PATH}` or to source/concept/entity pages.** This skill is read-only on the wiki.
- **Never skip Step 4.** The user must confirm scope before you write a long structured table.
- **Priority values are Must / Should / Could / Won't only.** Do not use numeric scales unless the wiki explicitly states them.
- **Each requirement gets its own row.** Do not bundle multiple requirements into one row.
