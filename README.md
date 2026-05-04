<p align="center">
    <img src="assets/images/banner.png" alt="manifesto logo" width="400"/>
</p>

> An AI-assisted knowledge and artifact pipeline for engineering teams — traceable from source document to shipped user story.


**manifast** is an AI plugin for **Claude Code** and **VS Code** that turns a plain git repository into a structured knowledge base and artifact generation pipeline. Teams register work items, drop source documents (specs, meeting notes, PDFs, emails) into a folder, and the plugin ingests them into cross-linked wiki pages — then generates software engineering artifacts that build progressively on each other: briefs, quality attributes & constraints, ADRs, feature lists, diagrams, and user stories.

Every artifact traces back to a source document. Every decision can be explained.

The work item hierarchy mirrors what teams already use in Jira, Azure DevOps, and SAFe — **Strategic** (Themes, Initiatives), **Product** (Epics, Features), and **Tactical** (User Stories, Tasks, Bugs). Artifacts generated at the strategic level automatically propagate as constraints into product-level work; product artifacts flow into tactical ones. The knowledge travels with the hierarchy.

## How it works

```mermaid
flowchart LR
    A([Team]) -->|/workitem| B[Register<br/>work item]
    B --> C[(workitems.yaml<br/>+ .env)]
    C --> D[Drop files<br/>into input/]
    D -->|/ingest| E[Knowledge<br/>wiki]
    E -->|/query| F([Answer<br/>with citations])
    E -->|/lint| G([Health<br/>check])
    E -->|/artifact| H([Engineering<br/>artifact])
```

1. **Register** a work item — creates the folder structure and tracks the active item in `.env`. 
     - See [How To: Create Work Items](HOW_TO_WORKITEMS.md) for details on the work item hierarchy and best practices.
2. **Drop** source files into `input/` (Markdown, PDF, plain text, images).
     - See [How To: Ingest a Source](HOW_TO_WIKI.md#ingest--adding-a-source) for a walkthrough of the ingestion process and how to guide the AI's understanding.
4. **Query** — ask questions; every answer cites a wiki page, which traces back to a source file.
    - See [How To: Answer Questions](HOW_TO_WIKI.md#query--answering-questions) for tips on crafting effective queries and interpreting citations.
5. **Generate artifacts** — produce briefs, quality attributes & constraints, ADRs, feature lists, diagrams, and user stories directly from the wiki. Each artifact enriches the next.
     - See [How To: Generate Artifacts](HOW_TO_ARTIFACTS.md) for a step-by-step guide to generating each artifact type and how they build on each other.
6. **Lint** — periodic health check that finds orphan pages, broken links, contradictions, and stale content.

---

## Guides

| Guide | Description |
|---|---|
| [How To: Create Work Items](HOW_TO_WORKITEMS.md) | Create and select work items; understanding the hierarchy |
| [How To: Create and Maintain a Wiki](HOW_TO_WIKI.md) | Ingest sources, query the wiki, and run health checks |
| [How To: Generate Artifacts](HOW_TO_ARTIFACTS.md) | Generate briefs, requirements, ADRs, diagrams, and user stories |
| [Research & Documentation](RESEARCH.md) | Deep-dive reference for every command, skill, and concept |

---

## References

- [SPReaD: Service-oriented Process for Reengineering and DevOps](https://link.springer.com/article/10.1007/s11761-021-00329-x) — da Silva, Justino & Adachi, SOCA 2022. The academic origin of manifast: a structured process for migrating legacy systems to microservices integrating DevOps, establishing the principle that software engineering activities must follow traceable, repeatable steps with defined artifacts and quality checkpoints.
- [protocolo-es-ai](https://github.com/yanjustino/protocolo-es-ai) — Yan Justino. The direct predecessor of manifast: a protocol for adopting LLMs across the software development cycle, organized across Framework, Process, and AI-Enabled Activities layers. Validated in a real transformation scenario at a major Brazilian bank. manifast is its tooling realization.
- [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — Andrej Karpathy. The foundational concept behind manifast: instead of re-deriving knowledge on every query (RAG), an LLM incrementally maintains a persistent wiki that accumulates cross-references and syntheses over time. The wiki is the compounding artifact between raw sources and the user.
- [Scaled Agile Framework — Big Picture](https://framework.scaledagile.com/#big-picture) — Scaled Agile, Inc. The work item hierarchy that manifast mirrors: Strategic (Themes, Initiatives), Product (Epics, Features), and Tactical (User Stories, Tasks) — the same structure used by teams in Jira, Azure DevOps, and SAFe programs.
- [Software traceability: trends and future directions](https://dl.acm.org/doi/10.1145/2593882.2593891) — Cleland-Huang et al., FOSE 2014. The academic grounding for manifast's core promise: every artifact must be traceable back to its source. This paper surveys traceability as a first-class engineering concern, not an afterthought.

---

## License

MIT — see [LICENSE](LICENSE).
