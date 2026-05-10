#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: requirements$' "Frontmatter must include: subtype: requirements"
assert_frontmatter_line "$FILE" '^mode:' "Missing frontmatter field: mode"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level:' "Missing frontmatter field: hierarchy_level"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"

MODE="$(frontmatter_text "$FILE" | sed -n 's/^mode: //p' | head -n1)"

case "$MODE" in
  constraints)
    assert_exact_headings "$FILE" 2 \
      "## Context" \
      "## Non-Functional Requirements" \
      "## Architectural Constraints" \
      "## Compliance & Regulatory Obligations" \
      "## Exclusions" \
      "## Open Questions" \
      "## Sources"
    assert_body_line "$FILE" '^\| ID \| Category \| Requirement \| Priority \| Source \|$' "Missing Non-Functional Requirements table header"
    assert_body_line "$FILE" '^\| ID \| Constraint \| Rationale \| Source \|$' "Missing Architectural Constraints table header"
    assert_body_line "$FILE" '^\| ID \| Obligation \| Regulatory Body / Standard \| Source \|$' "Missing Compliance table header"
    ;;
  functional)
    assert_exact_headings "$FILE" 2 \
      "## Context" \
      "## Functional Requirements" \
      "## Integration Requirements" \
      "## Data Requirements" \
      "## Exclusions" \
      "## Gaps" \
      "## Open Questions" \
      "## Sources"
    assert_body_line "$FILE" '^\| ID \| Title \| Description \| Acceptance Criteria \| Priority \| Source \|$' "Missing Functional Requirements table header"
    assert_body_line "$FILE" '^\| ID \| Source System \| Target System \| Interaction \| Source \|$' "Missing Integration Requirements table header"
    assert_body_line "$FILE" '^\| ID \| Data Element \| Format \| Volume / Frequency \| Source \|$' "Missing Data Requirements table header"
    ;;
  *)
    fail "Unsupported requirements mode: $MODE" 4
    ;;
esac

echo "OK: requirements structure matches template for $FILE"
