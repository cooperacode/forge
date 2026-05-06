# How To: Artifacts

This guide explains how to generate software engineering artifacts from your wiki. It assumes you have already created a work item (`/workitem`) and ingested at least one source document (`/ingest`).

---

## What is an artifact?

An artifact is a structured document generated from the knowledge in your wiki — briefs, requirement lists, architecture decision records, diagrams, and user stories. Artifacts do not come from Claude's training knowledge. Every claim in an artifact traces back to a wiki page, which in turn traces back to a source document you ingested.

```
Source document  →  wiki page     →  artifact
     (input/)         (docs/wiki/)      (output/artifacts/)
```

You do not write artifacts by hand. You ingest sources, then run `/artifact` to generate them.

---

## Before you start

Two things must be true before generating any artifact:

1. **A work item is active.** Run `/workitem` to create or select one.
2. **The wiki has content.** Run `/ingest` on at least one source document first. If the wiki is empty, Claude will stop and remind you to ingest first.

---

## The command

```
/artifact
```

Omit the type to see a menu for the active hierarchy level. Pass a type to skip the menu:

```
/artifact brief
/artifact requirements
/artifact feature-list
/artifact feature-detail
/artifact adr
/artifact der
/artifact diagram
/artifact user-story
```

---

## Available artifacts by level

Each level has its own set of artifacts. You can only generate an artifact that matches the active work item's level.

| Level | Artifact | What it produces |
|---|---|---|
| Strategic | `brief` | Executive brief: goals, scope, stakeholders, risks, timeline |
| Strategic | `requirements` | Quality attributes, architectural constraints, compliance obligations |
| Strategic | `adr` | Foundational architecture decision records |
| Strategic | `diagram` | C4 Level 1 (System Context) or C4 Level 2 (Container) |
| Product | `requirements` | Functional requirements with acceptance criteria |
| Product | `feature-list` | Prioritized feature list with dependencies (generated at **Epic** level) |
| Product | `feature-detail` | Deep analysis of one feature: personas, rules, entities, and proposed story breakdown (generated at **Feature** level) |
| Product | `adr` | Feature-scoped architecture decision records |
| Product | `der` | Entity-relationship diagram |
| Product | `diagram` | C4 Level 3, process flow, or data flow |
| Tactical | `user-story` | User stories with Gherkin scenarios and Definition of Done, one file per story |
| Tactical | `diagram` | Sequence or state diagram |

---

## Recommended generation order

Artifacts build on each other. This is the order that produces the best results:

```
Strategic level (Initiative/Theme)
  brief → requirements → adr → diagram

Product level — Epic
  requirements → feature-list → adr → der → diagram

Product level — Feature  (child of Epic)
  feature-detail

Tactical level (User Story/Task)
  user-story → diagram (seq/state)
```

**All same-level dependencies are enforced.** If a prerequisite artifact hasn't been generated yet, Claude stops and tells you exactly what to generate first — it will not proceed.

**Cross-level dependencies:**
- `feature-list` must exist in the parent **Epic** before `feature-detail` can run on a **Feature** work item.
- `feature-list` (or `feature-detail` when the parent is a Feature) must exist before `user-story` can run. If a `feature-detail` also exists for the selected feature, Claude uses it as the primary source for richer, more precise stories.

---

## How each artifact works

Every artifact follows the same three-phase pattern:

1. **Claude reads the wiki** — all sources, concepts, entities from `docs/wiki/`, and any upstream context from a parent work item.
2. **Claude surfaces scope** — lists what it found before writing. In default mode it proceeds immediately; pass `-buddy` to `/artifact` to pause and confirm scope before writing.
3. **Claude writes the file** — to `output/artifacts/`, then updates `index.md` and `log.md`.

---

## Strategic artifacts

### `brief` — Strategic Brief

**When to use:** after ingesting sources for a Theme or Initiative. The brief is the first artifact you generate — it sets the frame for everything else.

**What Claude asks before writing:**
```
Based on the wiki (12 pages), here is what I plan to cover in the brief:

• Reduce time-to-first-value for new users by redesigning the onboarding flow
• Budget constraint: delivery within 3 months, fixed team of 4
• Key risk: no existing data on where users drop off

Is this the right framing? Anything you want emphasized, excluded, or reworded?
```

**What gets created:**
```
output/artifacts/brief.md
```

Sections: Executive Summary · Business Context · Goals & Objectives · Scope · Key Stakeholders · Success Metrics · Timeline & Milestones · Risks & Dependencies · Open Questions.

---

### `requirements` — Quality Attributes & Constraints

**When to use:** after `brief`. Extracts non-functional requirements (performance, security, privacy, reliability), architectural constraints, and compliance obligations. Does not contain functional requirements — those live at Product level.

**What Claude asks before writing:**
```
Based on the wiki (12 pages), I found:

• 14 quality attribute requirements
• 6 architectural constraints
• 3 compliance obligations
• 2 areas with no coverage (gaps)

Categories detected: Performance, Security, Privacy, Maintainability, Compliance

Is there anything you want excluded, rephrased, or split differently?
```

**What gets created:**
```
output/artifacts/requirements.md
```

Sections: Non-Functional Requirements · Architectural Constraints · Compliance & Regulatory Obligations · Exclusions · Open Questions.

---

### `adr` — Architecture Decision Records (Strategic)

**When to use:** when the wiki contains explicit technology or platform decisions — language choice, cloud provider, architectural style. Produces one file per decision.

**What Claude asks before writing:**
```
I detected 3 architectural decisions in the wiki:

1. Standardize infrastructure on AWS — [Foundational]
   Chosen: AWS
   Alternatives: Azure, GCP
   Source: [[sources/technology-team-mandates]]

2. ...

Are these correct? Any decisions I missed or that should be excluded?
```

**What gets created:**
```
output/artifacts/adr/
  index.md
  001-standardize-infrastructure-on-aws.md
  002-...
```

Each ADR follows MADR format: Status · Context · Decision · Alternatives Considered · Consequences.

---

### `diagram` — Architecture Diagram (Strategic)

**When to use:** to visualize the system's boundaries and context. Claude asks which type you want:

```
Which diagram do you want to generate?
  1. C4 Level 1 — System Context  (the system and its external actors/systems)
  2. C4 Level 2 — Container       (containers: apps, services, databases inside the system)
```

**What gets created:**
```
output/artifacts/diagrams/c4-context.md   (Level 1)
output/artifacts/diagrams/c4-container.md (Level 2)
```

Each file contains a Mermaid diagram block and a glossary of every node.

---

## Product artifacts

### `requirements` — Functional Requirements

**When to use:** at Epic or Feature level, after ingesting product specifications. Extracts what the system must do, with acceptance criteria for each requirement.

**What gets created:**
```
output/artifacts/requirements.md
```

Sections: Functional Requirements · Integration Requirements · Data Requirements · Exclusions · Gaps · Open Questions.

> If the parent Strategic work item has a `requirements.md` in its `output/artifacts/` folder, Claude reads it and ensures no functional requirement violates an established constraint. The wiki itself (`docs/wiki/`) is always shared — artifacts are per work item.

---

### `feature-list` — Feature List

**When to use:** after functional requirements. Produces a prioritized, dependency-mapped list of every feature described in the wiki.

**What Claude asks before writing:**
```
Based on the wiki (9 pages), I identified 8 features:

In scope:
1. User registration — collect name, email, password [MVP]
2. Email verification — send confirmation link on signup [MVP]
3. Social login — sign in with Google or GitHub [Post-MVP]
...

Explicitly out of scope:
- SSO integration — deferred to phase 2

Does this look right? Any features I missed or that should be regrouped?
```

**What gets created:**
```
output/artifacts/feature-list.md
```

Sections: Features table (ID, name, description, beneficiary, priority, dependencies) · Out of Scope · Dependency Map · Gaps · Open Questions.

> `feature-list` is generated at the **Epic** level. It is required before generating `feature-detail` (at Feature level) or `user-story` (at Tactical level).

---

### `feature-detail` — Feature Detail

**When to use:** at **Feature** level (child of an Epic), after the parent Epic has a `feature-list`. Produces a deep specification of one specific feature, including personas, business rules, entity interactions, and a proposed user story breakdown.

**Requires:** `feature-list.md` in the parent Epic's `output/artifacts/`.

**What Claude asks before writing:**
```
Analysis of F-002 — Email Verification:

Personas identified: New User, System (email service)
Behaviors found: 3
Business rules found: 2
Entities touched: User, VerificationToken

Proposed user story breakdown (3 stories):

US-001 · As a new user, I want to receive a verification email after signup, so that my account is confirmed.
US-002 · As a new user, I want to verify my email by clicking a link, so that I can access the platform.
US-003 · As a new user, I want to request a new verification email if mine expired, so that I can still complete registration.

Does this analysis look right? Any behaviors to add, remove, or merge?
```

**What gets created:**
```
output/artifacts/feature-detail/
  F-002-email-verification.md
```

Sections: Feature Statement · Goal · Personas · Functional Scope (in / out of scope) · Business Rules · Entity & Data Interactions · Feature-Level Acceptance Criteria · **Proposed User Story Breakdown** · Dependencies · Gaps · Open Questions.

> The proposed story breakdown is a **planning guide**, not a contract. Stories are generated later at the Tactical level with `/artifact user-story`. When they are, Claude reads `feature-detail` as its primary source.

---

### `adr` — Architecture Decision Records (Product)

**When to use:** for feature-scoped decisions: library selection, API design, data model choices, integration patterns. One file per decision, same MADR format as Strategic ADRs.

**What gets created:**
```
output/artifacts/adr/
  index.md
  001-use-jwt-for-session-tokens.md
  002-...
```

---

### `der` — Entity-Relationship Diagram

**When to use:** when the wiki has entity pages (created by `/ingest` when source documents describe domain objects). Produces a Mermaid ER diagram.

**What gets created:**
```
output/artifacts/der.md
```

Contains the ER diagram, a cardinality table, and a glossary of every entity and attribute.

---

### `diagram` — Architecture Diagram (Product)

**When to use:** to visualize the internal structure of a component, a business process, or data flow. Claude asks which type:

```
Which diagram do you want to generate?
  1. C4 Level 3 — Component  (components inside a specific container)
  2. Process Flow            (steps in a business or user process)
  3. Data Flow               (how data moves between system parts)
```

**What gets created:**
```
output/artifacts/diagrams/<type>.md
```

---

## Tactical artifacts

### `user-story` — User Stories

**When to use:** at User Story or Task level. Requires a `feature-list` in the parent Product work item. If a `feature-detail` also exists for the selected feature, Claude uses it as the primary source — producing richer, more precise stories with less wiki re-reading.

The behavior depends on who the **parent work item** is:

**Parent = Feature** (recommended path)
Claude reads `feature-detail` from the parent's artifacts directly — the feature scope is already known. No selection step needed.
```
Feature detail loaded: F-002 — Email Verification

I propose 3 user stories:

US-001 · As a new user, I want to receive a verification email after signup, so that my account is confirmed.
US-002 · As a new user, I want to verify my email by clicking a link, so that I can access the platform.
US-003 · As a new user, I want to request a new link if mine expired, so that I can still complete registration.

Does this breakdown look right? Any stories to add, remove, or merge?
```

**Parent = Epic** (direct, no Feature level)
Claude reads `feature-list` from the parent Epic and asks which feature to cover. No `feature-detail` is available in this path.
```
Feature list loaded. Which feature do you want to break into user stories?

| ID    | Feature              | Priority |
|-------|---------------------|----------|
| F-001 | User Registration   | MVP      |
| F-002 | Email Verification  | MVP      |

Note: for richer stories, create a Feature work item as a child of this Epic,
run /artifact feature-detail on it, then return here.

Reply with the feature ID (e.g. F-001).
```

**What gets created (one file per story):**
```
output/artifacts/user-stories/
  F-002-US-001-receber-email-de-verificacao.md
  F-002-US-002-verificar-email-por-link.md
  F-002-US-003-solicitar-novo-link-expirado.md
```

Each file contains: Story statement (As a / I want / So that) · Acceptance Criteria table · Gherkin scenarios (Given / When / Then) · Business Rules · Definition of Done · Dependencies · Open Questions.

---

### `diagram` — Sequence or State Diagram (Tactical)

**When to use:** to visualize interactions between actors over time (sequence) or the states of an entity or process (state machine). Claude asks which type:

```
Which diagram do you want to generate?
  1. Sequence  (interactions between actors/components over time)
  2. State     (states and transitions of an entity or process)
```

**What gets created:**
```
output/artifacts/diagrams/sequence-<slug>.md
output/artifacts/diagrams/state-<slug>.md
```

---

## How context flows between levels

When a work item has a parent, the artifact orchestrator resolves a `CONTEXT_PATH` pointing directly to the parent's `output/artifacts/` folder. Nothing is copied — skills read from the parent path on demand.

```
Parent work item
  output/artifacts/
    brief.md           ← read directly by child skills
    requirements.md    ← read directly by child skills
    adr/               ← read directly by child skills
```

The relevant artifacts depend on the parent's level:

| Parent level | What skills read from it |
|---|---|
| Strategic | `brief.md`, `requirements.md`, `adr/`, `diagrams/` |
| Product (Epic) | `requirements.md`, `feature-list.md`, `der.md`, `diagrams/` |

Upstream artifacts act as guardrails:
- `brief.md` sets the strategic goals — features that don't serve any goal are flagged as unaligned.
- `requirements.md` defines constraints — functional requirements that violate a constraint are flagged.
- `adr/` records accepted decisions — new ADRs that contradict an upstream one are flagged explicitly.

If the parent has no artifacts yet, Claude warns you before proceeding:

```
No artifacts found in parent work item.
Run /artifact on the parent first to generate upstream context.
```

---

## Where artifacts are saved

Artifacts are organized by type under `output/artifacts/`. The table below shows which work item level generates each artifact:

```
output/
  artifacts/
    brief.md                          ← Strategic
    requirements.md                   ← Strategic or Product
    feature-list.md                   ← Product (Epic)
    feature-detail/
      F-001-user-registration.md      ← Product (Feature, one file per feature)
      F-002-email-verification.md
    der.md                            ← Product
    adr/
      index.md
      001-decision-title.md
    diagrams/
      c4-context.md
      process-flow.md
      sequence-login.md
    user-stories/
      F-001-US-001-cadastrar-usuario.md    ← Tactical (one file per story)
      F-001-US-002-validar-email.md
      F-002-US-001-verificar-conta.md
```

`output/index.md` and `output/log.md` are updated automatically after each artifact is generated.

---

## Common questions

**Can I regenerate an artifact after adding more sources?**
Yes — run `/artifact [type]` again. Claude will re-read the wiki (including the new pages) and overwrite the existing file. Check `log.md` for a history of regenerations.

**What if a section has no wiki coverage?**
Claude uses a `> [!gap]` callout for any section it cannot fill from the wiki. It will never invent content from training knowledge. Gaps are signals to ingest more sources or consult stakeholders.

**Can I edit an artifact manually?**
Yes, but be careful: the next regeneration will overwrite your edits. If you have corrections, consider ingesting a new source document that captures that knowledge — then regenerate.

**An artifact says "upstream context not found". What does that mean?**
The parent work item hasn't had `/artifact` run yet. Switch to the parent with `/workitem`, generate its artifacts, then switch back and regenerate.

**Can I generate a `user-story` without a `feature-list`?**
No. The `feature-list` in the parent Product work item is a hard dependency — Claude will stop and tell you to generate it first.

**Can I generate a `user-story` without a `feature-detail`?**
Yes. `feature-detail` is optional but recommended. When it exists for the selected feature, Claude uses it as the primary source and produces richer stories with less re-reading of the wiki. Without it, Claude reads the wiki directly and suggests creating a `feature-detail` first.

**Can I generate a `feature-detail` without a `feature-list`?**
No. `feature-detail` reads the feature list from the parent Epic's `output/artifacts/` to know which features exist. Generate `feature-list` on the Epic first.

---

See [HOW_TO.md](HOW_TO.md) for the full end-to-end sequence from setup to first artifact.
