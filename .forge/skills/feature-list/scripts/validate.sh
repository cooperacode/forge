#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: feature-list$' "Frontmatter must include: subtype: feature-list"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Product$' "Frontmatter must include: hierarchy_level: Product"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"
assert_frontmatter_line "$FILE" '^total_features:' "Missing frontmatter field: total_features"

assert_exact_headings "$FILE" 2 \
  "## Summary" \
  "## Features" \
  "## Out of Scope" \
  "## Gaps" \
  "## Dependency Map" \
  "## Open Questions" \
  "## Sources"

assert_body_line "$FILE" '^\| ID \| Feature \| Description \| Beneficiary \| Priority \| Dependencies \| Source \|$' "Missing Features table header"
assert_body_line "$FILE" '^\| Feature \| Reason for exclusion \| Source \|$' "Missing Out of Scope table header"

echo "OK: feature-list structure matches template for $FILE"
