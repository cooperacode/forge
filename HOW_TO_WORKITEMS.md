# How To: Work Items

This guide walks you through creating your first work item in manifast. It assumes you have the repository open in your editor and have never used the framework before.

---

## What is a work item?

A work item is simply a unit of work that your team needs to do. It could be a big strategic goal, a feature to build, or a single user story to implement.

manifast organizes work items in a three-level hierarchy — the same structure used by tools like Jira, Azure DevOps, and SAFe:

```
Strategic  →  the big picture: goals and directions
  Product  →  what gets built to achieve those goals
   Tactical →  the daily execution: stories, tasks, bugs
```

You don't need to fill all three levels at once. Start where your current work is.

---

## The hierarchy at a glance

| Level | Type | When to use | Example |
|---|---|---|---|
| Strategic | **Theme** | A broad area of focus that groups multiple initiatives | "Improve developer experience" |
| Strategic | **Initiative** | A specific effort spanning months or teams | "Redesign the onboarding process" |
| Product | **Epic** | A large body of work, too big for one sprint | "User authentication system" |
| Product | **Feature** | A concrete piece of functionality for one release | "Social login with Google" |
| Tactical | **User Story** | The smallest unit of user-facing value | "As a user, I want to reset my password…" |
| Tactical | **Task** | A technical step inside a story | "Design the password reset page" |
| Tactical | **Bug** | Something broken that needs fixing | "Login fails with special characters" |

**Rule of thumb:** if you are exploring and planning, start at Strategic. If you are building, start at Product. If you are executing a sprint, start at Tactical.

---

## Before you start

Make sure the repository is open and manifast is active in your environment. The commands below work through any AI assistant that has manifast configured — no specific editor or tool is required.

---

## Running `/workitem` for the first time

Run:

```
/workitem
```

If you have never created a work item before, Claude will skip straight to creation. If you have existing items, it will ask what you want to do:

```
What action would you like to perform?
  ▸ Create a new work item
    Select an existing work item
```

Choose **Create a new work item**.

---

## Step-by-step: creating a work item

The following example creates a Strategic Initiative called *"Redesign the onboarding process"*. Follow the same steps for any level or type.

---

### Step 1 — Choose the hierarchy level

```
What hierarchy level should this work item be?
  ▸ Strategic
    Product
    Tactical
```

Choose **Strategic**.

> **Not sure which level to pick?** Ask yourself: "Is this something we decide, or something we build?" Decisions live at Strategic. What gets built lives at Product. How it gets built lives at Tactical.

---

### Step 2 — Choose the work item type

```
What type of work item is this?
  ▸ Theme
    Initiative
```

Choose **Initiative**.

> **Theme vs. Initiative:** A Theme is an umbrella ("Improve performance"). An Initiative is a concrete effort under that umbrella ("Reduce API latency by 40%"). If in doubt, use Initiative.

---

### Step 3 — Fill in the details

Claude asks for three things:

```
Title (required):
> Redesign the onboarding process

Description (optional — press Enter to skip):
> Reduce time-to-first-value for new users by redesigning
  the onboarding flow end-to-end.

Tags (optional, comma-separated — press Enter to skip):
> onboarding, ux, strategic
```

Title is the only required field. Description and tags can be added later.

---

### Step 4 — Link a parent (optional)

If you have existing work items at a compatible level, Claude shows a list:

```
Select the parent work item (or "None" for a root-level item):
  ▸ None — root-level item
    Improve User Experience (Theme · Strategic)
```

For a root-level item with no parent, choose **None**. If this initiative belongs to a Theme you already created, select it — this builds the traceability chain.

| Work item level | Valid parent |
|---|---|
| Strategic | *(none — always root-level)* |
| Product | Strategic (Theme or Initiative) |
| Product | Product (Feature as child of Epic) |
| Tactical | Product |

> **Epic → Feature:** within the Product level, an Epic can be the parent of a Feature. This matters for artifact generation: `feature-list` is generated on the Epic; `feature-detail` is generated on the Feature and reads the parent Epic's `feature-list` as its source. User stories then read `feature-detail` from the parent Feature.

---

### Step 5 — Done

Claude confirms and shows what was created:

```
Work item created.

Title:  Redesign the onboarding process
Level:  Strategic · Initiative
Path:   docs/strategic/initiatives/20260503-redesign-the-onboarding-process/
Parent: (none)

Active item updated in .env.
```

---

## What gets created

manifast creates the following structure on disk:

```
docs/
  wiki/                ← centralized wiki, shared across all work items
    sources/
    concepts/
    entities/
    index.md           ← navigation + synthesis overview
    log.md
  strategic/
    initiatives/
      20260503-redesign-the-onboarding-process/
        input/         ← place your source documents here
        output/
          artifacts/   ← generated artifacts (brief, requirements, ADRs, etc.)
          log.md       ← artifact generation history for this work item
```

> **Wiki vs. artifacts:** source documents go to `input/`, wiki pages go to `docs/wiki/` (shared), and generated artifacts go to `output/artifacts/` (per work item).

And appends the item to `docs/manifast.yaml`:

```yaml
items:
  - title: Redesign the onboarding process
    description: Reduce time-to-first-value for new users by redesigning the onboarding flow end-to-end.
    tags: [onboarding, ux, strategic]
    hierarchyLevel: Strategic
    workItemType: Initiative
    createdAt: "2026-05-03"
    updatedAt: "2026-05-03"
    path: docs/strategic/initiatives/20260503-redesign-the-onboarding-process
    parent: ""
```

The `.env` file is also updated so every subsequent command (`/ingest`, `/artifact`, etc.) knows which work item is active:

```env
MWI_TITLE=redesign-the-onboarding-process
MWI_TAGS=[onboarding, ux, strategic]
MWI_LEVEL=Strategic
MWI_TYPE=Initiative
MWI_PATH=docs/strategic/initiatives/20260503-redesign-the-onboarding-process/
MWI_PARENT=
MWI_LANG=en
```

---

## Selecting an existing work item

If you have multiple work items and want to switch between them:

```
/workitem
```

Choose **Select an existing work item**. Claude lists everything in `manifast.yaml`:

```
Select a work item:
  ▸ Redesign the Onboarding Process (Initiative · Strategic)
    User Authentication System (Epic · Product)
    Social Login with Google (Feature · Product)
```

Selecting one updates `.env` and makes it the active item for all subsequent commands.

---

## What to do next

With a work item active, the typical next steps are:

```
1. Drop source files into input/
   (specs, meeting notes, PDFs, emails, research)

2. /ingest
   Claude reads each source and writes structured wiki pages
   to the centralized docs/wiki/ folder.

3. /artifact
   Generate briefs, quality attributes, ADRs, feature lists,
   diagrams, and user stories — written to this work item's
   output/artifacts/ folder.
```

See [HOW_TO.md](HOW_TO.md) for the full end-to-end sequence.

---

## Common questions

**Can I have multiple active work items?**
No — `.env` tracks one active item at a time. Run `/workitem` to switch.

**Can I rename or edit a work item after creation?**
Edit `docs/manifast.yaml` directly and update the `title`, `description`, or `tags` fields. Do not rename the folder path — it would break existing wiki links.

**What if I chose the wrong level or type?**
Delete the folder and its entry in `manifast.yaml`, then run `/workitem` again. No artifacts have been generated yet, so nothing is lost.

**Do I need to fill all three levels?**
No. You can work at a single level. The hierarchy becomes valuable when you link items — strategic constraints propagate down to inform product and tactical work.
