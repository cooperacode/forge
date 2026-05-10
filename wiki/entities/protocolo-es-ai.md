---
title: "protocolo-es-ai"
slug: protocolo-es-ai
type: entity
subtype: product
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
tags: [predecessor, llm-adoption, software-engineering, protocol]
related_sources: [sources/readme, sources/research]
related_concepts: [artifact-pipeline, source-traceability]
---

**protocolo-es-ai** (2025) is a protocol created by [[entities/yan-justino]] for structuring LLM adoption across the full software development lifecycle. It is organized across three layers: **Framework**, **Process**, and **AI-Enabled Activities**. The Framework layer defines structured guidelines and evaluation metrics for AI use; the Process layer defines the software engineering activities covered (requirement extraction, user story generation, architecture diagramming, API contract creation); the AI-Enabled Activities layer defines how LLMs execute each activity. The protocol was designed and applied during real transformation programs at Itaú Unibanco.

## From [[sources/research]]

RESEARCH clarifies the year (2025) and explicitly maps each Protocol activity to forge commands: Ideation/Benchmarking → `/focus` + `/ingest`; Planning → `/draft brief`; Analysis → `/draft requirements`; Design → `/draft feature-list`, `/draft adr`, `/draft der`, `/draft diagram`; Maintenance → `/lint`, `/query`.

It is the direct predecessor of [[concepts/artifact-pipeline|forge's artifact pipeline]]. Where the protocol defined the *what* and *why* of LLM-assisted software engineering, forge is its tooling realization — the *how*. The protocol validated the core thesis that AI-assisted software engineering activities must follow traceable, repeatable steps with defined artifacts and quality checkpoints.

Source: [protocolo-es-ai on GitHub](https://github.com/yanjustino/protocolo-es-ai)
