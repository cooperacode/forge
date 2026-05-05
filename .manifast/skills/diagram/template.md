# Diagram Templates

Use the matching section below for `{DIAGRAM_TYPE}`.

## c4-context

````markdown
---
title: "C4 L1 System Context — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: c4-context
hierarchy_level: Strategic
generated: YYYY-MM-DD
---

# C4 Level 1: System Context — {WORK_ITEM_TITLE}

## Diagram

```mermaid
C4Context
  title System Context for {WORK_ITEM_TITLE}

  Person(personAlias, "Actor Name", "Description from wiki")
  System(systemAlias, "System Name", "Description from wiki")
  System_Ext(extAlias, "External System", "Description from wiki")

  Rel(personAlias, systemAlias, "Uses", "channel if stated")
  Rel(systemAlias, extAlias, "Calls", "protocol if stated")
```
````

## c4-container

````markdown
---
title: "C4 L2 Container — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: c4-container
hierarchy_level: Strategic
generated: YYYY-MM-DD
---

# C4 Level 2: Container — {WORK_ITEM_TITLE}

## Diagram

```mermaid
C4Container
  title Container Diagram for {WORK_ITEM_TITLE}

  Person(personAlias, "Actor Name", "Description")
  System_Boundary(sysBoundary, "System Name") {
    Container(containerAlias, "Container Name", "Technology", "Description")
    ContainerDb(dbAlias, "Database Name", "Technology", "Stores what")
  }
  System_Ext(extAlias, "External System", "Description")

  Rel(personAlias, containerAlias, "Uses", "HTTPS")
  Rel(containerAlias, dbAlias, "Reads/Writes", "SQL")
  Rel(containerAlias, extAlias, "Calls", "REST")
```
````

## c4-component

````markdown
---
title: "C4 L3 Component — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: c4-component
hierarchy_level: Product
generated: YYYY-MM-DD
---

# C4 Level 3: Component — {WORK_ITEM_TITLE}

## Diagram

```mermaid
C4Component
  title Component Diagram for {WORK_ITEM_TITLE}

  Container_Boundary(containerBoundary, "Container Name") {
    Component(compAlias, "Component Name", "Technology", "Responsibility")
  }
```
````

## process-flow

````markdown
---
title: "Process Flow — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: process-flow
hierarchy_level: Product
generated: YYYY-MM-DD
---

# Process Flow: {WORK_ITEM_TITLE}

## Diagram

```mermaid
flowchart TD
  START([Start]) --> STEP1[Step name]
  STEP1 --> DEC1{Decision?}
  DEC1 -->|Yes| STEP2[Next step]
  DEC1 -->|No| STEP3[Alternative step]
  STEP2 --> END([End])
  STEP3 --> END
```
````

## data-flow

````markdown
---
title: "Data Flow — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: data-flow
hierarchy_level: Product
generated: YYYY-MM-DD
---

# Data Flow: {WORK_ITEM_TITLE}

## Diagram

```mermaid
flowchart LR
  SRC([Source]) -->|"Data element"| PROC[Process]
  PROC -->|"Transformed data"| DEST([Destination])
```
````

## sequence

````markdown
---
title: "Sequence Diagram — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: sequence
hierarchy_level: Tactical
generated: YYYY-MM-DD
---

# Sequence Diagram: {WORK_ITEM_TITLE}

## Diagram

```mermaid
sequenceDiagram
  actor User
  participant ServiceA
  participant ServiceB
  User->>ServiceA: Request (data)
  ServiceA->>ServiceB: Call (payload)
  ServiceB-->>ServiceA: Response
  ServiceA-->>User: Response
```
````

## state

````markdown
---
title: "State Diagram — {WORK_ITEM_TITLE}"
type: artifact
subtype: diagram
diagram_type: state
hierarchy_level: Tactical
generated: YYYY-MM-DD
---

# State Diagram: {WORK_ITEM_TITLE}

## Diagram

```mermaid
stateDiagram-v2
  [*] --> StateName
  StateName --> OtherState : event / condition
  OtherState --> [*] : terminal condition
```
````
