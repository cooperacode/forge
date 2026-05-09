---
name: diagram
description: "Generate architecture and flow diagrams in Mermaid format from the active wiki. Strategic: C4 L1/L2. Product: C4 L3, process flow, data flow. Tactical: sequence, state."
---

# Skill: Diagram

You were invoked by the orchestrator because the user wants to generate a diagram from the active wiki. Your job is to extract structural or behavioral information from the wiki and produce a valid Mermaid diagram with a supporting glossary.

The orchestrator passed `OUTPUT_PATH`, `WORK_ITEM_TITLE`, `WORK_ITEM_TYPE`, and `WORK_ITEM_HIERARCHY_LEVEL` — use those values for all file operations and metadata.

Follow every step in order.

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

## Step 2 — Select diagram type

**If `{WORK_ITEM_HIERARCHY_LEVEL}` is `Strategic` — fast-path (no menu):**

Both C4 diagrams are always generated together at Strategic level. Do not ask the user to choose.

Set `DIAGRAM_SEQUENCE = [c4-context, c4-container]` and `DIAGRAM_TYPE = c4-context` (first pass).

Announce:
```
Strategic level detected. Generating both C4 diagrams in sequence:
  1. C4 Level 1 — System Context
  2. C4 Level 2 — Container
Starting with Level 1…
```

Then proceed to Step 3. After Step 8 completes for `c4-context`, advance to the next item in `DIAGRAM_SEQUENCE`, set `DIAGRAM_TYPE = c4-container`, announce `"C4 Level 1 done. Now generating C4 Level 2 — Container…"`, and return to Step 3. Skip Step 5 on the second pass (language is already locked). After Step 8 completes for `c4-container`, the skill is done — skip to the closing message in Step 8.

---

**If `{WORK_ITEM_HIERARCHY_LEVEL}` is `Product` — show menu and wait:**
```
Which diagram do you want to generate?
  1. C4 Level 3 — Component  (components inside a specific container)
  2. Process Flow            (steps in a business or user process)
  3. Data Flow               (how data moves between system parts)
```

**If `{WORK_ITEM_HIERARCHY_LEVEL}` is `Tactical` — show menu and wait:**
```
Which diagram do you want to generate?
  1. Sequence  (interactions between actors/components over time)
  2. State     (states and transitions of an entity or process)
```

For Product and Tactical: wait for the user's selection. Map it to the `DIAGRAM_TYPE` slug and output filename using the table below, then record both. Do not proceed until a type is chosen.

| Level    | Selection               | `DIAGRAM_TYPE` | Output file                          |
|----------|-------------------------|----------------|--------------------------------------|
| Product  | C4 Level 3 — Component  | `c4-component` | `artifacts/diagrams/c4-component.md` |
| Product  | Process Flow            | `process-flow` | `artifacts/diagrams/process-flow.md` |
| Product  | Data Flow               | `data-flow`    | `artifacts/diagrams/data-flow.md`    |
| Tactical | Sequence                | `sequence`     | `artifacts/diagrams/sequence.md`     |
| Tactical | State                   | `state`        | `artifacts/diagrams/state.md`        |

Strategic level uses fixed slugs: `c4-context` → `artifacts/diagrams/c4-context.md` and `c4-container` → `artifacts/diagrams/c4-container.md`.

> ⚠️ Never use a generic filename such as `diagram.md` or `diagrama.md`. The output filename is always the `DIAGRAM_TYPE` slug exactly.

---

## Step 3 — Read wiki pages for the selected type

**If `LOCAL_WIKI = true`**, read pages according to what each diagram type needs. If `LOCAL_WIKI = false`, skip the local pages column and read only from `{CONTEXT_PATH}`.

| Diagram type | Primary pages to read | Secondary |
|---|---|---|
| C4 L1 System Context | `overview.md`, all `entities/` | `sources/` for system boundaries |
| C4 L2 Container | `overview.md`, all `entities/`, all `concepts/` | `sources/` for tech stack mentions |
| C4 L3 Component | all `entities/`, all `concepts/` | `overview.md`, `sources/` |
| Process Flow | `overview.md`, all `sources/` | `concepts/` for rules |
| Data Flow | all `entities/`, all `concepts/` | `sources/` for integration points |
| Sequence | all `sources/`, all `concepts/` | `entities/` for actor names |
| State | `concepts/` pages about the entity's lifecycle | `sources/` for transition rules |

**If `{CONTEXT_PATH}` is non-empty**, read all files present in `{CONTEXT_PATH}` after completing the list above. These are upstream artifacts from the parent work item:
- Upstream `diagrams/` files (especially C4 L1/L2) define the system boundary and external actors — a C4 L3 or flow diagram must stay consistent with that boundary.
- Upstream `der.md` provides the canonical entity model — use those entity names verbatim in sequence and state diagrams.
- Upstream `feature-list.md` scopes which flows or components are relevant for this work item.

While reading, extract the elements specific to the chosen type:

**C4 diagrams — extract:**
- Systems, containers, or components named in the wiki
- External actors (users, external services, third parties)
- Relationships and data flows between elements
- Technology labels (language, framework, protocol) if stated
- Boundary groupings (which elements belong together)

**Process Flow — extract:**
- Steps or actions described in sequence
- Decision points (conditions that fork the flow)
- Actors or roles responsible for each step
- Start and end states

**Data Flow — extract:**
- Data elements or entities that move between parts
- Source and destination of each data movement
- Transformation steps if described
- External systems involved

**Sequence — extract:**
- Participants (actors, systems, components)
- Messages exchanged in chronological order
- Synchronous vs asynchronous interactions (if stated)
- Return values or responses
- Loops or conditional blocks described in sources

**State — extract:**
- States the entity can be in
- Events or conditions that trigger transitions
- Entry/exit actions for states (if described)
- Terminal and initial states

**Same-level ADR artifacts — always read if present:**

After reading wiki pages and upstream context, check `{OUTPUT_PATH}artifacts/adr/`. If any `.md` files exist there, read them all before proceeding to Step 4. ADRs record committed architectural decisions for this work item — use them to:
- Confirm which technologies, components, and integration patterns are already decided
- Align element names and boundaries with what the ADRs established
- Avoid showing options or unknowns that were already resolved by a decision record

Do not include technology labels or component boundaries that contradict a committed ADR.

---

## Step 4 — Confirm diagram elements with the user

Before writing, surface what you found:

```
For a {DIAGRAM_TYPE} diagram, I identified:

Elements ({N} total):
- {element name} — {type: system | container | actor | step | state | participant}
- ...

Relationships / transitions ({N}):
- {A} → {B} : "{label}"
- ...

{N} elements had insufficient wiki coverage (will be flagged as gaps).

Does this look right? Anything to add, rename, or remove?
```

Wait for a response. If the user says "go ahead", proceed.

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

## Step 6 — Write the diagram artifact

Create `{OUTPUT_PATH}artifacts/diagrams/{DIAGRAM_TYPE}.md` — the filename is the `DIAGRAM_TYPE` slug exactly (e.g., `c4-context.md`, `process-flow.md`, `sequence.md`).

**Read the template file before writing anything.** Use the Read tool to open `.manifast/skills/diagram/template.md`. Locate the section whose heading matches `{DIAGRAM_TYPE}` (e.g., `## c4-context`, `## process-flow`, `## sequence`). Copy that section's fenced code block verbatim as the output file scaffold — do not reconstruct it from memory or training data. Replace only the placeholders (`{WORK_ITEM_TITLE}`, `YYYY-MM-DD`, element stubs) with actual content.

**Copy the Mermaid diagram type keyword exactly as it appears in the template** — `flowchart TB`, `flowchart TD`, `flowchart LR`, `sequenceDiagram`, or `stateDiagram-v2`. Do not change it. Do not substitute `C4Context`, `C4Container`, or `C4Component` — those Mermaid types are forbidden regardless of diagram type.

Fill all placeholders, preserve the section order, and do not add, remove, or rename headings outside the template.

Run `scripts/validate.sh {OUTPUT_PATH}artifacts/diagrams/{DIAGRAM_TYPE}.md`. If validation fails, fix the artifact until it passes. Do not update navigation files or report success before validation passes.


---
## Step 7 — Update navigation files

**`{OUTPUT_PATH}index.md`** — add or update the `## Artifacts` section:

```markdown
## Artifacts

- [[artifacts/diagrams/{DIAGRAM_TYPE}]] — {Diagram type} (generated YYYY-MM-DD)
```

**`{OUTPUT_PATH}log.md`** — append one entry at the top:

```markdown
## [YYYY-MM-DD] artifact | Diagram ({diagram type})

Generated: artifacts/diagrams/{DIAGRAM_TYPE}.md
Elements: N
Relationships: N
Gaps flagged: N
Sources read: N pages
```

**`docs/manifast.yaml`** — register the artifact in the work item entry:

1. Find the entry whose `path` matches `{WORK_ITEM_PATH}`.
2. If it has no `artifacts` field, add one as an empty list.
3. If `diagram` is not already in the `artifacts` list, append it.

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
      - diagram
```

If `artifacts` already exists, append `diagram` to the list. Never duplicate an entry already present. For Strategic level, this step runs **once** after both diagrams are written (after the second pass).

---

## Step 8 — Close the loop

**For Strategic level (after both passes complete):**
```
Done. Both C4 diagrams generated:
  - C4 Level 1: {OUTPUT_PATH}artifacts/diagrams/c4-context.md  (N elements, N relationships)
  - C4 Level 2: {OUTPUT_PATH}artifacts/diagrams/c4-container.md  (N elements, N relationships)

Total gaps flagged: N
Total sources read: N pages

Anything you want me to revise?
```

**For Product and Tactical levels (single diagram):**
```
Done. {Diagram type} diagram generated at {OUTPUT_PATH}artifacts/diagrams/{slug}.md.

Elements: N
Relationships: N
Gaps flagged: N (elements without wiki coverage)
Sources read: N pages

Anything you want me to revise?
```

---

## Rules

- **Write all content in `{LANGUAGE}`.** If `LANGUAGE` is `pt-BR`, write in Brazilian Portuguese. If `LANGUAGE` is `en`, write in English. Apply this to artifact content, section headings, and all messages shown to the user. If `LANGUAGE` is not set, default to English.
- **Never invent elements not present in the wiki.** Use `> [!gap]` for anything the wiki does not cover.
- **`flowchart` is mandatory for all C4 diagrams.** Never use `C4Context`, `C4Container`, or `C4Component` Mermaid diagram types — they are forbidden. All c4-context, c4-container, and c4-component diagrams must open with `flowchart TB` exactly as in the template.
- **Follow the template verbatim for the Mermaid type keyword.** The opening keyword of every diagram block (`flowchart TB`, `flowchart TD`, `flowchart LR`, `sequenceDiagram`, `stateDiagram-v2`) is fixed by the template and must not be changed or substituted.
- **Mermaid syntax must be valid.** Test mentally before writing — prefer a simpler correct diagram over a complex broken one.
- **Never merge distinct elements** to make the diagram smaller. One system = one node; one container = one node.
- **Never modify source/concept/entity pages.** Diagram generation is read-only on the wiki.
- **Strategic level never shows a menu.** Both C4 L1 and C4 L2 are always generated in sequence automatically.
- **Never skip Step 2 for Product/Tactical.** The diagram type must be explicitly selected — do not guess.
- **Never skip Step 4.** Wrong elements produce a misleading diagram that will be harder to correct than to prevent.
- **Never skip Step 5.** Language must be locked before any file is written — lock it once per skill invocation (not once per pass).
- **Technology labels come only from the wiki.** If the wiki does not state the technology, use `"not stated"` in the diagram element description.
- **One artifact file per diagram type.** Strategic generates two files (`c4-context.md` and `c4-container.md`) in a single skill run.
- **Always read the template file at Step 6.** Use the Read tool on `.manifast/skills/diagram/template.md` — never reconstruct the template from memory. The scaffold must come from the file.
- **Output filename is the `DIAGRAM_TYPE` slug.** Never use generic names like `diagram.md`, `diagrama.md`, or any name not derived from the slug mapping table in Step 2.
- **ADR decisions are binding.** If ADR files exist at `{OUTPUT_PATH}artifacts/adr/`, the diagram must reflect those decisions. Technology choices or boundaries that contradict a committed ADR are forbidden.
