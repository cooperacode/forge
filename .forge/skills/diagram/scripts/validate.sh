#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <diagram-file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: diagram$' "Frontmatter must include: subtype: diagram"
assert_frontmatter_line "$FILE" '^diagram_type:' "Missing frontmatter field: diagram_type"
assert_frontmatter_line "$FILE" '^hierarchy_level:' "Missing frontmatter field: hierarchy_level"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"

LANG_CODE="$(frontmatter_field "$FILE" language)"
LANG_CODE="${LANG_CODE:-en}"
LOCALE_FILE="$SCRIPT_DIR/../locales/${LANG_CODE}.sh"
[[ -f "$LOCALE_FILE" ]] || LOCALE_FILE="$SCRIPT_DIR/../locales/en.sh"
# shellcheck source=/dev/null
source "$LOCALE_FILE"

assert_exact_headings "$FILE" 2 "${LOCALE_H2[@]}"

DIAGRAM_TYPE="$(frontmatter_field "$FILE" diagram_type)"

case "$DIAGRAM_TYPE" in
  c4-context|c4-container|c4-component)
    assert_mermaid_keyword "$FILE" "flowchart TB"
    ;;
  process-flow)
    assert_mermaid_keyword "$FILE" "flowchart TD"
    ;;
  data-flow)
    assert_mermaid_keyword "$FILE" "flowchart LR"
    ;;
  sequence)
    assert_mermaid_keyword "$FILE" "sequenceDiagram"
    ;;
  state)
    assert_mermaid_keyword "$FILE" "stateDiagram-v2"
    ;;
  *)
    fail "Unsupported diagram_type: $DIAGRAM_TYPE" 4
    ;;
esac

echo "OK: diagram structure matches template for $FILE"
