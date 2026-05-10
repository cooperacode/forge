#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: user-story$' "Frontmatter must include: subtype: user-story"
assert_frontmatter_line "$FILE" '^feature_id:' "Missing frontmatter field: feature_id"
assert_frontmatter_line "$FILE" '^story_id:' "Missing frontmatter field: story_id"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Tactical$' "Frontmatter must include: hierarchy_level: Tactical"
assert_frontmatter_line "$FILE" '^persona:' "Missing frontmatter field: persona"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"

assert_exact_headings "$FILE" 2 \
  "## Business Context" \
  "## Acceptance Criteria" \
  "## Gherkin Scenarios" \
  "## Business Rules" \
  "## Definition of Done" \
  "## Dependencies & Blockers" \
  "## Out of Scope" \
  "## Open Questions" \
  "## Sources"

assert_body_line "$FILE" '^\| # \| Criterion \| Source \|$' "Missing Acceptance Criteria table header"
assert_body_line "$FILE" '^```gherkin$' "Missing Gherkin code block"
assert_body_line "$FILE" '^Feature: ' "Missing Gherkin Feature title"
assert_body_line "$FILE" '^[[:space:]]+Given ' "Each story must include a Given step"
assert_body_line "$FILE" '^[[:space:]]+When ' "Each story must include a When step"
assert_body_line "$FILE" '^[[:space:]]+Then ' "Each story must include a Then step"
assert_body_line "$FILE" '^\| # \| Rule \| Source \|$' "Missing Business Rules table header"
assert_body_line "$FILE" '^\| Type \| Item \| Status \| Source \|$' "Missing Dependencies & Blockers table header"

echo "OK: user-story structure matches template for $FILE"
