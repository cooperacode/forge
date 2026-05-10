---
title: "SPReaD Methodology"
slug: spread-methodology
type: entity
subtype: product
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
tags: [methodology, microservices, devops, reengineering, research]
related_sources: [sources/readme, sources/research]
related_concepts: [source-traceability, artifact-pipeline]
---

**SPReaD** (Service-oriented Process for Reengineering and DevOps) is a structured methodology for migrating legacy systems to microservice architectures while integrating DevOps practices throughout the process. It was published at SOCA 2022 (Springer) by da Silva, Justino & Adachi.

SPReaD established the foundational principle that software engineering activities should follow a traceable, repeatable process with defined steps, artifacts, and quality checkpoints. This principle became the theoretical backbone of [[entities/protocolo-es-ai]] and, through it, of forge itself.

The three-generation lineage is:
```
SPReaD (Springer, 2021) → structured process for SE + DevOps
       ↓
protocolo-es-ai (2025)  → protocol for LLM adoption in SE activities
       ↓
forge                   → tooling that runs the protocol inside your editor
```

SPReaD was validated in production at a major Brazilian bank, providing the empirical grounding for its claims about traceable, repeatable software engineering processes.

Reference: [SPReaD on Springer](https://link.springer.com/article/10.1007/s11761-021-00329-x)
