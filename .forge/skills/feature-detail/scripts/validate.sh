#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: feature-detail$' "Frontmatter must include: subtype: feature-detail"
assert_frontmatter_line "$FILE" '^feature_id:' "Missing frontmatter field: feature_id"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Product$' "Frontmatter must include: hierarchy_level: Product"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"
assert_frontmatter_line "$FILE" '^total_stories:' "Missing frontmatter field: total_stories"

assert_exact_headings "$FILE" 2 \
  "## Feature Statement" \
  "## Goal" \
  "## Personas" \
  "## Functional Scope" \
  "## Business Rules" \
  "## Entity & Data Interactions" \
  "## Feature-Level Acceptance Criteria" \
  "## Proposed User Story Breakdown" \
  "## Dependencies" \
  "## Gaps" \
  "## Open Questions" \
  "## Sources"

assert_exact_headings "$FILE" 3 \
  "### In scope" \
  "### Out of scope"

assert_body_line "$FILE" '^\| Persona \| Role \| Interaction with this feature \| Source \|$' "Missing Personas table header"
assert_body_line "$FILE" '^\| # \| Rule \| Source \|$' "Missing Business Rules table header"
assert_body_line "$FILE" '^\| Entity \| Operation \| Notes \| Source \|$' "Missing Entity & Data Interactions table header"
assert_body_line "$FILE" '^\| # \| Criterion \| Source \|$' "Missing Feature-Level Acceptance Criteria table header"
assert_body_line "$FILE" '^\| Story ID \| Story \| Persona \| Priority \| INVEST Notes \| Depends On \|$' "Missing Proposed User Story Breakdown table header"
assert_body_line "$FILE" '^\| Type \| Item \| Direction \| Source \|$' "Missing Dependencies table header"

echo "OK: feature-detail structure matches template for $FILE"
