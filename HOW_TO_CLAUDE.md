# HOW TO: Using forge with Claude Code

This guide explains how to load and use the **forge** plugin inside [Claude Code](https://claude.ai/code).

---

## What is forge?

**forge** is a Claude Code plugin that provides AI-assisted agile artifact generation. It organizes work around a **Strategic → Product → Tactical** hierarchy and manages a knowledge wiki, producing engineering artifacts (briefs, requirements, ADRs, diagrams, user stories) from ingested sources.

---

## Loading the Plugin

### Option A — Local development (recommended for contributors)

Run Claude Code from the root of this repository, pointing `--plugin-dir` at the project root:

```bash
claude --plugin-dir .
```

Claude Code detects `.claude-plugin/plugin.json` at the directory root and loads **forge** for that session.

### Option B — Test a packaged archive

If a `.zip` release is available at a URL:

```bash
claude --plugin-url https://example.com/forge-plugin.zip
```

### Reload after changes

When you edit any command or hook file during a session, run:

```
/reload-plugins
```

---

## Available Commands

All forge commands are namespaced under `forge:`. Run `/help` to see them listed.

| Command | Description |
|---|---|
| `/forge:focus` | Create or switch the active work item (Strategic / Product / Tactical). |
| `/forge:draft` | Generate an engineering artifact for the active work item. |
| `/forge:ingest` | Add new sources to the wiki; updates pages and index automatically. |
| `/forge:query` | Answer questions by synthesizing information from the wiki (always cites sources). |
| `/forge:lint` | Scan the wiki for structural and navigational problems and fix what it can. |
| `/forge:lang` | Set the language for artifact generation (`en` or `pt-BR`). |

### Command details

#### `/forge:focus [title]`

Sets the active work item. When run without arguments it prompts you interactively to create a new item or switch to an existing one. The selection is persisted in `.env` and used by all other commands.

```
/forge:focus
/forge:focus "Authentication module redesign"
```

#### `/forge:draft [artifact-type]`

Generates an artifact for the currently active work item. The artifact type is routed automatically based on the hierarchy level:

| Level | Available artifact types |
|---|---|
| Strategic | `brief`, `requirements`, `adr`, `diagram` |
| Product | `requirements`, `der`, `adr`, `feature-list`, `feature-detail`, `diagram` |
| Tactical | `user-story`, `diagram` |

Run without arguments to see the menu for the active level:

```
/forge:draft
/forge:draft adr
/forge:draft user-story
```

#### `/forge:ingest [path]`

Adds a source document (file or URL) to the wiki. Non-interactive by default. Pass `-buddy` for step-by-step confirmation:

```
/forge:ingest ./docs/spec.pdf
/forge:ingest ./docs/spec.pdf -buddy
```

#### `/forge:query [question]`

Answers questions about the domain using only wiki content. Every claim is cited back to a source:

```
/forge:query "What are the authentication requirements?"
```

#### `/forge:lint`

Scans the wiki for broken links, missing index entries, and inconsistent structure. Fixes issues it can resolve automatically and flags anything that needs manual review:

```
/forge:lint
```

#### `/forge:lang [code]`

Sets the output language. Omit the argument to see the current setting and choose interactively:

```
/forge:lang en
/forge:lang pt-BR
```

---

## Hooks (Automatic Behaviors)

forge registers hooks that run automatically — no action required from you.

| Event | Trigger | Behavior |
|---|---|---|
| `PermissionRequest` | `git add`, `git commit`, `grep` | Auto-approves these Bash commands without prompting. |
| `PostToolUse` | Any `Write` or `Edit` operation | Runs `.forge/scripts/validate_hook.sh` to validate the written artifact. |

---

## Typical Workflow

```
1. /forge:lang pt-BR          # (optional) set language
2. /forge:focus               # select or create a work item
3. /forge:ingest ./research   # add source documents to the wiki
4. /forge:draft adr           # generate an artifact
5. /forge:query "..."         # query the wiki for answers
6. /forge:lint                # health-check the wiki
```

---

## Plugin Structure Reference

```
manifesto/
├── .claude-plugin/
│   └── plugin.json           # plugin manifest (name, version, author)
└── .forge/
    ├── commands/             # slash command definitions
    │   ├── draft.prompt.md
    │   ├── focus.prompt.md
    │   ├── ingest.prompt.md
    │   ├── lang.prompt.md
    │   ├── lint.prompt.md
    │   └── query.prompt.md
    └── hooks/
        └── hooks.json        # PermissionRequest and PostToolUse hooks
```

> **Note:** only `plugin.json` lives inside `.claude-plugin/`. All commands and hooks are at the plugin root under `.forge/`.

---

## Further Reading

- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins)
- [Create plugins](https://code.claude.com/docs/en/plugins)
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Agent Skills](https://code.claude.com/docs/en/skills)
- [Hooks](https://code.claude.com/docs/en/hooks)
