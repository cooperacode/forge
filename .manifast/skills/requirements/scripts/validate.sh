#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "Usage: $0 <file.md>"
  exit 1
fi

if ! rg -q '^---$' "$FILE"; then
  echo "Missing frontmatter block"
  exit 2
fi

echo "OK: basic markdown/frontmatter validation passed for $FILE"
