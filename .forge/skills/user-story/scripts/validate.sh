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

LANG_CODE="$(frontmatter_field "$FILE" language)"
LANG_CODE="${LANG_CODE:-en}"
LOCALE_FILE="$SCRIPT_DIR/../locales/${LANG_CODE}.sh"
[[ -f "$LOCALE_FILE" ]] || LOCALE_FILE="$SCRIPT_DIR/../locales/en.sh"
# shellcheck source=/dev/null
source "$LOCALE_FILE"

assert_exact_headings "$FILE" 2 "${LOCALE_H2[@]}"
assert_body_line "$FILE" '^```gherkin$' "Missing Gherkin code block"
assert_body_line "$FILE" '^Feature: ' "Missing Gherkin Feature title"
assert_body_line "$FILE" '^[[:space:]]+Given ' "Each story must include a Given step"
assert_body_line "$FILE" '^[[:space:]]+When ' "Each story must include a When step"
assert_body_line "$FILE" '^[[:space:]]+Then ' "Each story must include a Then step"
assert_body_line "$FILE" "$LOCALE_TABLE_CRITERIA" "$LOCALE_TABLE_CRITERIA_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_RULES" "$LOCALE_TABLE_RULES_MSG"
assert_body_line "$FILE" "$LOCALE_TABLE_DEPS" "$LOCALE_TABLE_DEPS_MSG"

echo "OK: user-story structure matches template for $FILE"
