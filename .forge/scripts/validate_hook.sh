#!/usr/bin/env bash
set -uo pipefail

# Expose rg (bundled inside the Claude Code binary) to subshell validate scripts
if ! command -v rg &>/dev/null; then
    _CC_BIN="${CLAUDE_CODE_EXECPATH:-$(command -v claude 2>/dev/null || echo "$HOME/.local/bin/claude")}"
    if [[ -x "$_CC_BIN" ]]; then
        _TMP_RG=$(mktemp -d)
        printf '#!/bin/bash\nARGV0=rg %s "$@"\n' "$_CC_BIN" > "$_TMP_RG/rg"
        chmod +x "$_TMP_RG/rg"
        export PATH="$_TMP_RG:$PATH"
        trap "rm -rf $_TMP_RG" EXIT
    fi
fi

INPUT="$(cat)"
FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"

[[ -z "$FILE" ]] && exit 0
[[ "$FILE" != *"output/artifacts/"*".md" ]] && exit 0
[[ ! -f "$FILE" ]] && exit 0

SUBTYPE="$(awk '
  BEGIN { c=0 }
  /^---/ { c++; if (c==2) exit; next }
  c==1 && /^subtype:/ { sub(/^subtype:[[:space:]]*/, ""); print; exit }
' "$FILE")"

[[ -z "$SUBTYPE" ]] && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATE="$SCRIPT_DIR/../skills/$SUBTYPE/scripts/validate.sh"
[[ ! -f "$VALIDATE" ]] && exit 0

if ! RESULT="$(bash "$VALIDATE" "$FILE" 2>&1)"; then
    MSG="Artifact validation FAILED for '$(basename "$FILE")' (subtype: $SUBTYPE).\n$RESULT\n\nFix the artifact before proceeding."
    jq -n --arg ctx "$MSG" '{
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": $ctx
        }
    }'
fi

exit 0
