---
title: "forge — README (Project Overview)"
slug: readme
type: source
date_ingested: 2026-05-09
original_file: docs/Strategic/initiatives/20260509-forge-documentation/input/README.md
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
authors: [yan-justino]
tags: [forge, overview, pipeline, wiki, artifacts]
related_concepts: [artifact-pipeline, work-item-hierarchy, source-traceability]
related_entities: [yan-justino, protocolo-es-ai]
---

## Summary

**forge** is an AI-assisted plugin for Claude Code and VS Code that transforms a plain git repository into a structured knowledge base and artifact generation pipeline. Teams register work items, drop source documents (specs, PDFs, meeting notes, emails) into an `input/` folder, and the plugin ingests them into cross-linked wiki pages. From the wiki, the plugin generates software engineering artifacts that build progressively on each other.

The tool operates on a work item hierarchy that mirrors what teams already use in Jira, Azure DevOps, and SAFe: **Strategic** (Themes, Initiatives), **Product** (Epics, Features), and **Tactical** (User Stories, Tasks, Bugs). Artifacts generated at the strategic level propagate as constraints into product-level work; product artifacts flow into tactical ones. Knowledge travels with the hierarchy.

The core promise of forge is traceability: every artifact traces back to a source document, and every decision can be explained. The wiki acts as the compounding layer between raw sources and the generated artifacts, accumulating cross-references and syntheses over time — inspired by Andrej Karpathy's LLM Wiki concept.

The project was created by Yan Justino and is grounded in two prior bodies of work: the SPReaD methodology (a structured process for legacy system migration to microservices, SOCA 2022) and protocolo-es-ai (a protocol for structuring LLM adoption across the software development lifecycle, validated at Itaú Unibanco).

## Key claims

- forge turns a git repo into a structured knowledge base + artifact pipeline using Claude Code and VS Code as the AI runtime.
- The five-step workflow is: **Register** (`/focus`) → **Drop** files in `input/` → **Ingest** (`/ingest`) → **Query/Lint** → **Draft** (`/draft`).
- Artifact types generated in sequence: briefs, quality attributes & constraints, ADRs, feature lists, feature details, diagrams, user stories.
- The work item hierarchy (Strategic → Product → Tactical) propagates context and constraints downward — artifact generated at a higher level constrains artifacts at lower levels.
- The academic foundation is SPReaD (SOCA 2022) and software traceability research (Cleland-Huang et al., FOSE 2014); the wiki architecture comes from Karpathy's LLM Wiki.

## Connections to existing wiki

This is the founding document of this wiki — no prior pages exist to connect to yet.

## Open questions

- How does forge handle conflicting information between multiple source documents at the same work item level?
- What is the intended frequency of `/lint` runs — on-demand only, or also automated (e.g., pre-commit hook)?
- How are constraints from strategic artifacts surfaced in tactical artifact prompts?

## Notable quotes

> "An AI-assisted knowledge and artifact pipeline for engineering teams — traceable from source document to shipped user story."

> "The idea that an LLM should maintain a persistent, compounding wiki — rather than re-derive knowledge on every query — is the architectural principle that made forge possible. Academic rigour gave it structure. Industry reality gave it scope."
