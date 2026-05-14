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

MODE="$(frontmatter_field "$FILE" mode)"
LANG_CODE="$(frontmatter_field "$FILE" language)"
LANG_CODE="${LANG_CODE:-en}"
LOCALE_FILE="$SCRIPT_DIR/../locales/${LANG_CODE}.sh"
[[ -f "$LOCALE_FILE" ]] || LOCALE_FILE="$SCRIPT_DIR/../locales/en.sh"
# shellcheck source=/dev/null
source "$LOCALE_FILE"

case "$MODE" in
  constraints)
    assert_exact_headings "$FILE" 2 "${LOCALE_CONSTRAINTS_H2[@]}"
    assert_body_line "$FILE" "$LOCALE_CONSTRAINTS_TABLE_NFR" "$LOCALE_CONSTRAINTS_TABLE_NFR_MSG"
    assert_body_line "$FILE" "$LOCALE_CONSTRAINTS_TABLE_ARCH" "$LOCALE_CONSTRAINTS_TABLE_ARCH_MSG"
    assert_body_line "$FILE" "$LOCALE_CONSTRAINTS_TABLE_COMP" "$LOCALE_CONSTRAINTS_TABLE_COMP_MSG"
    ;;
  functional)
    assert_exact_headings "$FILE" 2 "${LOCALE_FUNCTIONAL_H2[@]}"
    assert_body_line "$FILE" "$LOCALE_FUNCTIONAL_TABLE_FR" "$LOCALE_FUNCTIONAL_TABLE_FR_MSG"
    assert_body_line "$FILE" "$LOCALE_FUNCTIONAL_TABLE_IR" "$LOCALE_FUNCTIONAL_TABLE_IR_MSG"
    assert_body_line "$FILE" "$LOCALE_FUNCTIONAL_TABLE_DR" "$LOCALE_FUNCTIONAL_TABLE_DR_MSG"
    ;;
  *)
    fail "Unsupported requirements mode: $MODE" 4
    ;;
esac

echo "OK: requirements structure matches template for $FILE"
