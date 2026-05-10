---
title: "forge (Claude Code Plugin)"
slug: forge-plugin
type: entity
subtype: product
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
tags: [forge, claude-code, plugin, product]
related_sources: [sources/readme, sources/how-to-claude]
related_concepts: [artifact-pipeline, work-item-hierarchy, source-traceability]
---

**forge** is a Claude Code plugin created by [[entities/yan-justino]] that provides AI-assisted agile artifact generation. It is the tooling realization of [[entities/protocolo-es-ai]].

**Loading:**
- Local development: `claude --plugin-dir .` — Claude Code detects `.claude-plugin/plugin.json` and activates the plugin.
- Packaged release: `claude --plugin-url <url>`
- Reload mid-session: `/reload-plugins`

**Command namespace:** all commands are prefixed with `forge:` — e.g., `/forge:focus`, `/forge:draft`, `/forge:ingest`, `/forge:query`, `/forge:lint`, `/forge:lang`.

**File layout:**
```
.claude-plugin/
  plugin.json           ← manifest (name, version, author)
.forge/
  commands/             ← slash command prompt files (*.prompt.md)
  hooks/
    hooks.json          ← hook registrations
  scripts/
    validate_hook.sh    ← artifact validation script
```

**Auto-registered hooks:**
- `PermissionRequest` — auto-approves `git add`, `git commit`, and `grep` Bash commands without prompting.
- `PostToolUse` — runs `validate_hook.sh` after every `Write` or `Edit` operation to validate the written artifact.

**Supported environments:** Claude Code CLI; VS Code (via `chat.promptFilesLocations` / `chat.agentSkillsLocations` in `.vscode/settings.json`).

See [[sources/how-to-claude]] for the full loading walkthrough and command reference.
