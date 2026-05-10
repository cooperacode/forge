---
title: "How To: Using forge with Claude Code"
slug: how-to-claude
type: source
date_ingested: 2026-05-09
original_file: docs/Strategic/initiatives/20260509-forge-documentation/input/HOW_TO_CLAUDE.md
source_workitem: docs/Strategic/initiatives/20260509-forge-documentation/
authors: [yan-justino]
tags: [forge, claude-code, plugin, installation, hooks, commands]
related_concepts: [artifact-pipeline]
related_entities: [yan-justino, forge-plugin]
---

## Summary

This guide covers loading and using forge inside Claude Code. It documents the plugin loading mechanisms, all available commands with their arguments, the automatic hook registrations, the plugin file structure, and the typical end-to-end workflow.

forge is a Claude Code plugin. In local development, it is loaded with `claude --plugin-dir .` — Claude Code detects `.claude-plugin/plugin.json` and activates all commands and hooks for the session. A packaged release can be loaded via `--plugin-url`. The command namespace is `forge:` (e.g., `/forge:focus`, `/forge:draft`).

Two hooks run automatically without user action: `PermissionRequest` auto-approves `git add`, `git commit`, and `grep` commands (reducing interruptions); `PostToolUse` validates every file written or edited using `.forge/scripts/validate_hook.sh`.

The plugin filesystem layout is split: `.claude-plugin/plugin.json` holds the manifest (name, version, author); `.forge/commands/` holds the slash command prompt files; `.forge/hooks/hooks.json` defines the hook registrations.

## Key claims

- Load command: `claude --plugin-dir .` (local); `claude --plugin-url <url>` (packaged).
- Command prefix: `forge:` — all commands are namespaced (e.g., `/forge:focus`, `/forge:draft adr`).
- `/reload-plugins` reloads all command and hook files mid-session.
- Two auto-registered hooks: `PermissionRequest` (auto-approves git/grep Bash commands) and `PostToolUse` (artifact validation via `validate_hook.sh`).
- `/forge:ingest` accepts a file path argument and a `-buddy` flag for interactive mode.
- Plugin structure: `.claude-plugin/plugin.json` (manifest only); `.forge/commands/*.prompt.md` (6 commands); `.forge/hooks/hooks.json`.

## Connections to existing wiki

This source adds the implementation layer — how forge commands are actually invoked and how the plugin integrates with Claude Code's hook system. It does not change any existing concept pages but introduces [[entities/forge-plugin]] as a new entity.

## Open questions

- What does `validate_hook.sh` check — schema, content, or structure of written artifacts?
- Is there a VS Code equivalent of `PermissionRequest` auto-approval, or does that only apply to Claude Code?
- Can hooks be disabled per session, or are they always active when the plugin is loaded?

## Notable quotes

> "Claude Code detects `.claude-plugin/plugin.json` at the directory root and loads forge for that session."
