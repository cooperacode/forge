---
name: der
description: "Generate a DER (Diagrama de Entidade-Relacionamento) artifact in Mermaid ER format from the active wiki. Extracts entities and relationships from wiki pages for Product-level work items."
---

# Skill: DER (Diagrama de Entidade-Relacionamento)

You were invoked by the orchestrator because the user wants to generate an Entity-Relationship diagram from the active wiki. Your job is to extract entities and their relationships from wiki pages and produce a Mermaid ER diagram with a supporting glossary.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, and `WORK_ITEM_TYPE` — use those values for all file operations and metadata.

This skill is for **Product-level work items only** (Epic, Feature). If `{WORK_ITEM_TYPE}` is Strategic or Tactical, tell the user this artifact is not applicable for that layer and stop.

Follow every step in order.

## Buddy mode

By default this skill runs non-interactively — it writes the artifact without pausing for confirmation.

If `BUDDY_MODE = true` was passed by the orchestrator, pause at confirmation steps and wait for user input before writing.

> ⚠️ **Language lock:** Write the entire artifact — content, headings, table values, and all messages — in `{LANGUAGE}`. Source documents may be in a different language; never mirror them. This constraint is active from the first character to the last, throughout every step.

---

## Step 1 — Verify content sources

Attempt to read `{OUTPUT_PATH}index.md` (the local wiki index for this work item) and check whether `{CONTEXT_PATH}` is non-empty.

Determine the content situation using the table below:

| `{OUTPUT_PATH}index.md` | `{CONTEXT_PATH}` | Action |
|--------------------------|------------------|--------|
| exists and has entries   | any              | Set `LOCAL_WIKI = true`. Note the total number of pages listed. |
| missing or no entries    | has content      | Set `LOCAL_WIKI = false`. Warn the user: "No sources ingested for this work item — proceeding with upstream context only." |
| missing or no entries    | empty or absent  | Stop. Tell the user no sources have been ingested and there is no upstream context. Suggest running `/ingest` first. |

**If `LOCAL_WIKI = true`**, also check whether the local index has any entries under `## Entities`. If the entities folder is empty, warn the user: "No entity pages found in the wiki — the DER may be sparse. Consider running `/ingest` on domain model documentation first." Then ask if they want to proceed anyway.

---

## Step 2 — Read entity and concept pages

**If `LOCAL_WIKI = true`**, read in this order (entities are primary; concepts and sources provide relationship context):

1. `docs/wiki/overview.md` — global synthesis (read directly)
2. All `entities/` pages listed in `{OUTPUT_PATH}index.md` — follow each link to load from `docs/wiki/`
3. All `concepts/` pages listed in `{OUTPUT_PATH}index.md`
4. All `sources/` pages listed in `{OUTPUT_PATH}index.md` (skim for data structure descriptions)

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the list above. These are upstream artifacts from the parent work item:
- Upstream `der.md` from a sibling or parent item may define entities already modeled — do not redefine them, extend them.
- Upstream `requirements.md` and `feature-list.md` may name entities not yet in the local wiki's `entities/` folder — include them in the diagram and flag their attributes as gaps.
- When an upstream entity conflicts with a local entity (same name, different attributes), flag the conflict with a `> [!contradiction]` note.

For each entity page, extract:
- **Entity name** (from `title` frontmatter)
- **Attributes** explicitly described in the page body (fields, properties, data elements)
- **Relationships** — any mention of how this entity connects to another:
  - `related_entities` frontmatter
  - Inline text: "an Order contains many Items", "a User belongs to one Organization"
  - Verbs that imply cardinality: has, contains, belongs to, references, owns, manages

For each relationship, determine cardinality:
- `||--||` one-to-one
- `||--o{` one-to-many
- `}o--o{` many-to-many

Mark relationships as **confirmed** (explicitly stated in wiki) or **inferred** (implied by context — requires validation).

---

## Step 3 — Confirm entities and relationships with the user

Before writing, surface what you found:

```
I found {N} entities and {N} relationships in the wiki:

Entities: {EntityA}, {EntityB}, {EntityC}, ...

Confirmed relationships:
- EntityA ||--o{ EntityB : "has many"    [source: [[entities/entity-a]]]
- EntityB }o--|| EntityC : "belongs to"  [source: [[entities/entity-b]]]

Inferred relationships (need validation):
- EntityA ||--o{ EntityD : "may contain" [inferred from [[sources/slug]]]

{N} entities had no attributes documented in the wiki.

Does this look right? Any entities or relationships I missed?
```

**Default mode:** Proceed immediately with your judgment. Do not wait for a response.

**Buddy mode:** Wait for a response. If the user says "go ahead", proceed.

---

## Step 4 — Lock the output language

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

## Step 5 — Write the DER artifact

Create `{OUTPUT_PATH}artifacts/der.md`.

Use the template from `template.md` in this same skill directory. Fill all placeholders, preserve the section order, and do not add, remove, or rename headings outside the template.

Validation runs automatically via hook after each Write or Edit. If a validation error appears in context, fix the artifact before proceeding. Do not update navigation files or report success before all errors are resolved.


Mermaid ER rules to follow:
- Entity names in `UPPER_SNAKE_CASE` in the diagram, natural language in the glossary
- Attribute type must be one of: `string`, `int`, `float`, `boolean`, `date`, `datetime`, `uuid`, `json`
- Use `"description"` (quoted string) as the third token for attribute comments
- Do not use Mermaid features not supported in the ER diagram type
- If an entity has no documented attributes, render it with an empty block `ENTITY_NAME { }`

---
## Step 6 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update the `## Artifacts` section with the DER entry:

```markdown
- [[der]] — DER ({N} entities, {N} relationships, generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | DER

Generated: artifacts/der.md
Entities: N
Relationships confirmed: N | Inferred: N
Gaps flagged: N
Sources read: N pages
```

**`docs/forge.yaml`** — register the artifact in the work item entry:

1. Find the entry whose `path` matches `{WORK_ITEM_PATH}`.
2. If it has no `artifacts` field, add one as an empty list.
3. If `der` is not already in the `artifacts` list, append it.

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
      - der
```

If `artifacts` already exists, append `der` to the list. Never duplicate an entry already present.

---

## Step 7 — Close the loop

```
Done. DER generated at {OUTPUT_PATH}artifacts/der.md.

Entities: N
Relationships confirmed: N
Relationships inferred: N (marked — require team validation)
Gaps flagged: N
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Never invent entities or attributes not present in the wiki.** Use `> [!gap]` for undocumented entities.
- **Clearly separate confirmed from inferred relationships.** Never present an inferred relationship as fact.
- **Never write to source/concept/entity pages.** DER generation is read-only on the wiki.
- **Never skip Step 3.** Wrong entities here produce a misleading diagram.
- **Never skip Step 4.** Language must be locked before any file is written — never assume or infer the language mid-generation.
- **This skill is Product-only.** If invoked for Strategic or Tactical, stop immediately.
- **Mermaid syntax must be valid.** Prefer simpler, correct diagrams over complex, broken ones. If an entity's relationships are unclear, render the entity without relationships and flag it as a gap.
- **Source citation format:** use `[[sources/slug]]`, `[[concepts/slug]]`, or `[[entities/slug]]` for local wiki pages. For files read from `{CONTEXT_PATH}`, substitute the actual runtime value and write the full repo-relative path: `[[docs/strategic/initiatives/20260504-foo/output/artifacts/brief.md]]`. Never use short names (`[[brief.md]]`) or computed relative paths (`[[../../...]]`) for cross-work-item references — they resolve to the wrong location.
