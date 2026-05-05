#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "Usage: $0 <diagram-file.md>"
  exit 1
fi

for s in "## Diagram" "## Sources"; do
  if ! rg -q "^${s}$" "$FILE"; then
    echo "Missing section: ${s}"
    exit 2
  fi
done

if ! rg -q '^diagram_type:' "$FILE"; then
  echo "Missing frontmatter field: diagram_type"
  exit 3
fi

echo "OK: diagram artifact structure looks valid for $FILE"
