# Quick Start

This guide walks through one complete `forge` flow using a single case study, from Strategic planning to Tactical user stories.

By the end, you will have:

- created a Strategic Initiative
- ingested a knowledge base from sample files
- generated strategic artifacts
- created a Product Epic and Feature linked to that Initiative
- generated product artifacts
- created Tactical user stories from the Feature context

---

## The case

This quick start uses the sample case already included in the repository:

**Cultural Project Intake and Evaluation Platform**

The business goal is to replace a manual process based on email and spreadsheets with a platform that:

- publishes calls for proposals
- receives project submissions
- validates required documents
- supports evaluation and ranking
- publishes results with traceability

Sample source files:

- `assets/sample/cultural_event_call_for_proposals_example_en.txt`
- `assets/sample/conversation_transcript_client_analysts_en.txt`
- `assets/sample/business_analyst_idea_notes_en.txt`
- `assets/sample/client_email_budget_timeline_constraints_en.txt`
- `assets/sample/systems_analyst_technical_notes_en.txt`
- `assets/sample/technology_team_mandates_en.txt`

---

## Before you start

1. Open the repository with `forge` enabled.
2. If needed, set the generation language:

```text
/lang en
```

3. Keep the sample files above ready. When this guide says "drop files into `input/`", use those files.

> `forge` only ingests files from the work item's `input/` folder. Do not paste the source content into chat.

---

## 1. Strategic view

### 1.1 Initiative

Create the top-level work item:

```text
/focus
```

Choose:

- `Strategic`
- `Initiative`

Suggested values:

- **Title:** `Cultural platform MVP`
- **Description:** `Deliver the first operational version of a platform for cultural call publication, submission intake, evaluation, and result publication.`
- **Tags:** `culture, workflow, mvp`

This creates the Initiative folder with an `input/` directory and an `output/` directory for artifacts.

---

### 1.2 Ingest a knowledge base

Drop all six sample files into the Initiative's `input/` folder, then run:

```text
/ingest
```

Expected result:

- `docs/wiki/sources/` gets one page per input file
- `docs/wiki/concepts/` captures recurring ideas such as MVP scope, auditability, and configurable criteria
- `docs/wiki/entities/` captures actors such as applicants, reviewers, and managers
- the Initiative's `output/index.md` becomes the local index for artifact generation

At this point, you can validate the wiki before drafting artifacts:

```text
/query What is in scope for the first release?
/query What constraints affect the MVP?
```

---

### 1.3 Creating artifacts

Generate the Strategic artifacts in this order:

```text
/draft brief
/draft requirements
/draft adr
/draft diagram
```

What each step gives you:

- `brief` frames goals, scope, stakeholders, timeline, and risks
- `requirements` captures quality attributes, constraints, and compliance obligations
- `adr` records foundational decisions such as platform standards and architectural direction
- `diagram` produces the high-level architecture view

Why this matters:

- these artifacts become upstream context for Product work
- child work items read them directly from the parent Initiative

---

## 2. Product view

### 2.1 Epic

Create a Product Epic under the Initiative:

```text
/focus
```

Choose:

- `Product`
- `Epic`
- parent = `Cultural platform MVP`

Suggested values:

- **Title:** `Submission and evaluation flow`
- **Description:** `Plan the end-to-end product slice for call setup, submission intake, document screening, evaluation, ranking, and result publication.`

If you already have Epic-specific documents, add them to this Epic's `input/` folder and run `/ingest`.

If you do not have new files yet, you can still continue. `forge` will use the parent Initiative artifacts as upstream context, but Epic-specific sources will produce better results.

---

### 2.2 Epic artifacts

Generate the Product artifacts for the Epic:

```text
/draft requirements
/draft feature-list
/draft adr
/draft der
/draft diagram
```

Recommended interpretation of the outputs:

- `requirements` turns the business and technical material into functional requirements
- `feature-list` defines the candidate features for the Epic and is a hard dependency for the next steps
- `adr` records Epic-scoped decisions
- `der` models core entities such as call, submission, evaluator, score, and result
- `diagram` visualizes flows or containers at Product level

---

### 2.3 Feature

Create a Product Feature under the Epic:

```text
/focus
```

Choose:

- `Product`
- `Feature`
- parent = `Submission and evaluation flow`

Suggested values:

- **Title:** `Configurable evaluation criteria`
- **Description:** `Allow managers to define evaluation criteria and weights per call for proposal.`

If you have Feature-specific notes, add them to the Feature `input/` folder and run `/ingest`.

---

### 2.4 Feature detail

Generate the detailed Feature artifact:

```text
/draft feature-detail
```

This is the key output at Feature level. It should give you:

- personas involved in the feature
- business rules
- entity and data interactions
- acceptance criteria candidates
- a proposed user story breakdown

This file becomes the primary source for Tactical story generation.

---

## 3. Tactical view

### 3.1 User Story work item

Create a Tactical work item under the Feature:

```text
/focus
```

Choose:

- `Tactical`
- `User Story`
- parent = `Configurable evaluation criteria`

Suggested values:

- **Title:** `Manage criteria weights`
- **Description:** `Break the feature into implementable stories for configuring criteria and weights safely.`

> Best path: make the Tactical item a child of the Feature. In that mode, `/draft user-story` reads the parent's `feature-detail` directly and produces better stories.

---

### 3.2 Generate stories and a Tactical diagram

Run:

```text
/draft user-story
/draft diagram
```

Expected result:

- `user-story` creates one Markdown file per story under `output/artifacts/user-stories/`
- each story includes acceptance criteria, Gherkin scenarios, business rules, dependencies, and Definition of Done
- `diagram` gives you a sequence or state view for the selected Tactical scope

---

## 4. Operate the knowledge base

Use these commands throughout the flow:

```text
/query What did we decide about appeals in MVP?
/query Which constraints came from the technology mandates?
/lint
```

Use `/query` when you want grounded answers with citations.

Use `/lint` after several ingests or before major artifact generation to catch broken links, contradictions, and stale wiki structure.

---

## End state

After completing this quick start, your flow should look like this:

```text
Strategic / Initiative
  /ingest
  /draft brief
  /draft requirements
  /draft adr
  /draft diagram

Product / Epic
  /draft requirements
  /draft feature-list
  /draft adr
  /draft der
  /draft diagram

Product / Feature
  /draft feature-detail

Tactical / User Story
  /draft user-story
  /draft diagram
```

And the artifact chain should be:

```text
brief -> strategic requirements -> epic requirements -> feature-list
     -> feature-detail -> user-stories
```

That is the core `forge` loop: create a work item, ingest knowledge, draft artifacts, move down the hierarchy, and keep every decision traceable to source documents.
