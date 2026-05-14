#!/usr/bin/env bash
LOCALE_H2=(
  "## Summary"
  "## Features"
  "## Out of Scope"
  "## Gaps"
  "## Dependency Map"
  "## Open Questions"
  "## Sources"
)
LOCALE_TABLE_FEATURES='^\| ID \| Feature \| Description \| Beneficiary \| Priority \| Dependencies \| Source \|$'
LOCALE_TABLE_FEATURES_MSG="Missing Features table header"
LOCALE_TABLE_OUT_OF_SCOPE='^\| Feature \| Reason for exclusion \| Source \|$'
LOCALE_TABLE_OUT_OF_SCOPE_MSG="Missing Out of Scope table header"
