#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/validate_common.sh"

FILE="${1:-}"
require_file "$FILE" "Usage: $0 <file.md>"

assert_frontmatter_line "$FILE" '^title:' "Missing frontmatter field: title"
assert_frontmatter_line "$FILE" '^type: artifact$' "Frontmatter must include: type: artifact"
assert_frontmatter_line "$FILE" '^subtype: brief$' "Frontmatter must include: subtype: brief"
assert_frontmatter_line "$FILE" '^work_item_type:' "Missing frontmatter field: work_item_type"
assert_frontmatter_line "$FILE" '^hierarchy_level: Strategic$' "Frontmatter must include: hierarchy_level: Strategic"
assert_frontmatter_line "$FILE" '^generated:' "Missing frontmatter field: generated"
assert_frontmatter_line "$FILE" '^sources_read:' "Missing frontmatter field: sources_read"

assert_exact_headings "$FILE" 2 \
  "## Executive Summary" \
  "## Business Context" \
  "## Goals & Objectives" \
  "## Scope" \
  "## Key Stakeholders" \
  "## Success Metrics" \
  "## Timeline & Milestones" \
  "## Risks & Dependencies" \
  "## Open Questions" \
  "## Sources"

assert_exact_headings "$FILE" 3 \
  "### In scope" \
  "### Out of scope"

assert_body_line "$FILE" '^\| # \| Objective \| Expected Outcome \|$' "Missing Goals & Objectives table header"
assert_body_line "$FILE" '^\| Stakeholder \| Role / Interest \|$' "Missing Key Stakeholders table header"
assert_body_line "$FILE" '^\| Metric \| Target \| Source \|$' "Missing Success Metrics table header"
assert_body_line "$FILE" '^\| Milestone \| Target Date \| Notes \|$' "Missing Timeline & Milestones table header"
assert_body_line "$FILE" '^\| # \| Risk / Dependency \| Likelihood \| Impact \| Mitigation \|$' "Missing Risks & Dependencies table header"

echo "OK: brief structure matches template for $FILE"
