<p align="center">
    <img src="assets/images/banner.png" alt="manifesto logo" width="400"/>
</p>

> A `wiki` for software development teams, organized around `work items` and their relationships.

**New here?** → [How To: all commands in order](HOW_TO.md)

**manifast** is an AI plugin for **Claude Code** and **VS Code** that turns a plain git repository into a living, AI-assisted knowledge base. Teams register work items from their backlog, drop source documents (specs, research, meeting notes, PDFs) into a structured folder, and let the plugin ingest, cross-link, and query that knowledge — all from inside the editor.

The work item model mirrors the hierarchy consolidated by tools like Jira, Azure DevOps, and scaled frameworks like SAFe — breaking large business abstractions into manageable, executable pieces across three levels: **Strategic**, **Product**, and **Tactical**.

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
2. **Drop** source files into `input/` (Markdown, PDF, plain text, images).
3. **Ingest** — the plugin reads each source, discusses key takeaways with you, then writes structured wiki pages into `output/`.
4. **Query** — ask questions; every answer cites a wiki page, which traces back to a source file.
5. **Lint** — periodic health check that finds orphan pages, broken links, contradictions, and stale content.

---

**Want to go deeper?** → [Full documentation](WIKI.md)

---

## License

MIT — see [LICENSE](LICENSE).
