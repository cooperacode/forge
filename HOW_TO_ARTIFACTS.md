# How To: Artifacts

This guide explains how to generate software engineering artifacts from your wiki. It assumes you have already created a work item (`/workitem`) and ingested at least one source document (`/ingest`).

---

## What is an artifact?

An artifact is a structured document generated from the knowledge in your wiki — briefs, requirement lists, architecture decision records, diagrams, and user stories. Artifacts do not come from Claude's training knowledge. Every claim in an artifact traces back to a wiki page, which in turn traces back to a source document you ingested.

```
Source document  →  wiki page  →  artifact
     (input/)         (output/)      (output/artifacts/)
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
| Product | `feature-list` | Prioritized feature list with dependencies |
| Product | `adr` | Feature-scoped architecture decision records |
| Product | `der` | Entity-relationship diagram |
| Product | `diagram` | C4 Level 3, process flow, or data flow |
| Tactical | `user-story` | User story with Gherkin scenarios and Definition of Done |
| Tactical | `diagram` | Sequence or state diagram |

---

## Recommended generation order

Artifacts build on each other. This is the order that produces the best results:

```
brief → requirements → feature-list → adr → der → diagram → user-story → diagram (seq/state)
```

`feature-list` is a **hard dependency** for `user-story` — the story maps to a feature in the list. All other dependencies are soft: if a prior artifact exists, Claude reads it to produce a more precise result; if it does not, Claude continues with what is available.

---

## How each artifact works

Every artifact follows the same three-phase pattern:

1. **Claude reads the wiki** — all sources, concepts, entities, and any upstream context from a parent work item.
2. **Claude confirms scope with you** — surfaces what it found and asks if anything should change before writing.
3. **Claude writes the file** — to `output/artifacts/`, then updates `index.md` and `log.md`.

You always review before Claude writes. Never skip this confirmation step.

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

> If the parent Strategic work item has a `requirements.md` in its `context/` folder, Claude reads it and ensures no functional requirement violates an established constraint.

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

> `feature-list` is required before generating `user-story` at Tactical level.

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

### `user-story` — User Story

**When to use:** at User Story or Task level, after a `feature-list` exists in the parent work item's `context/` folder. Produces a complete story with Gherkin acceptance scenarios.

**What Claude asks before writing:**
```
Based on the wiki (6 pages) and the upstream feature list, here is the story I plan to write:

Persona: New user (first-time signup)
Behavior: Complete email verification after registration
Feature mapping: F-002 — Email verification [MVP]

Scenarios identified:
1. Happy path — user clicks the verification link within 24 hours
2. Expired link — user clicks after 24 hours
3. Already verified — user clicks the link a second time

Does this look right? Anything to add or change?
```

**What gets created:**
```
output/artifacts/user-story.md
```

Sections: Story statement (As a / I want / So that) · Acceptance Criteria table · Gherkin scenarios (Given / When / Then) · Definition of Done · Dependencies · Open Questions.

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

When a Product work item is linked to a Strategic parent, the parent's artifacts are automatically copied into the child's `context/` folder before any skill runs.

```
Strategic initiative/output/artifacts/
  brief.md          →  copied to  →  Product epic/context/brief.md
  requirements.md   →  copied to  →  Product epic/context/requirements.md
  adr/              →  copied to  →  Product epic/context/adr/
```

Claude reads `context/` after the local wiki. Upstream artifacts act as guardrails:
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

All artifacts land in the same location:

```
output/
  artifacts/
    brief.md
    requirements.md
    feature-list.md
    der.md
    user-story.md
    adr/
      index.md
      001-decision-title.md
    diagrams/
      c4-context.md
      process-flow.md
      sequence-login.md
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
Not recommended. The feature list is a hard dependency — it provides the scope frame that makes the story precise. Without it, Claude will warn you and ask if you want to proceed anyway.

---

See [HOW_TO.md](HOW_TO.md) for the full end-to-end sequence from setup to first artifact.
