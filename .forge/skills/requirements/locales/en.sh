#!/usr/bin/env bash
# Constraints mode
LOCALE_CONSTRAINTS_H2=(
  "## Context"
  "## Non-Functional Requirements"
  "## Architectural Constraints"
  "## Compliance & Regulatory Obligations"
  "## Exclusions"
  "## Open Questions"
  "## Sources"
)
LOCALE_CONSTRAINTS_TABLE_NFR='^\| ID \| Category \| Requirement \| Priority \| Source \|$'
LOCALE_CONSTRAINTS_TABLE_NFR_MSG="Missing Non-Functional Requirements table header"
LOCALE_CONSTRAINTS_TABLE_ARCH='^\| ID \| Constraint \| Rationale \| Source \|$'
LOCALE_CONSTRAINTS_TABLE_ARCH_MSG="Missing Architectural Constraints table header"
LOCALE_CONSTRAINTS_TABLE_COMP='^\| ID \| Obligation \| Regulatory Body / Standard \| Source \|$'
LOCALE_CONSTRAINTS_TABLE_COMP_MSG="Missing Compliance & Regulatory Obligations table header"

# Functional mode
LOCALE_FUNCTIONAL_H2=(
  "## Context"
  "## Functional Requirements"
  "## Integration Requirements"
  "## Data Requirements"
  "## Exclusions"
  "## Gaps"
  "## Open Questions"
  "## Sources"
)
LOCALE_FUNCTIONAL_TABLE_FR='^\| ID \| Title \| Description \| Acceptance Criteria \| Priority \| Source \|$'
LOCALE_FUNCTIONAL_TABLE_FR_MSG="Missing Functional Requirements table header"
LOCALE_FUNCTIONAL_TABLE_IR='^\| ID \| Source System \| Target System \| Interaction \| Source \|$'
LOCALE_FUNCTIONAL_TABLE_IR_MSG="Missing Integration Requirements table header"
LOCALE_FUNCTIONAL_TABLE_DR='^\| ID \| Data Element \| Format \| Volume / Frequency \| Source \|$'
LOCALE_FUNCTIONAL_TABLE_DR_MSG="Missing Data Requirements table header"
