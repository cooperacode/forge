#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "Usage: $0 <adr-file.md>"
  exit 1
fi

required_sections=(
  "## Status"
  "## Context"
  "## Decision"
  "## Alternatives Considered"
  "## Consequences"
  "## Sources"
)

for section in "${required_sections[@]}"; do
  if ! rg -q "^${section}$" "$FILE"; then
    echo "Missing section: ${section}"
    exit 2
  fi
done

if ! rg -q '^status: accepted$' "$FILE"; then
  echo "Frontmatter must include: status: accepted"
  exit 3
fi

echo "OK: ADR structure looks valid for $FILE"
