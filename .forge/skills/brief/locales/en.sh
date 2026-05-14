#!/usr/bin/env bash
LOCALE_H2=(
  "## Executive Summary"
  "## Business Context"
  "## Goals & Objectives"
  "## Scope"
  "## Key Stakeholders"
  "## Success Metrics"
  "## Timeline & Milestones"
  "## Risks & Dependencies"
  "## Open Questions"
  "## Sources"
)
LOCALE_H3=("### In scope" "### Out of scope")
LOCALE_TABLE_GOALS='^\| # \| Objective \| Expected Outcome \|$'
LOCALE_TABLE_GOALS_MSG="Missing Goals & Objectives table header"
LOCALE_TABLE_STAKEHOLDERS='^\| Stakeholder \| Role / Interest \|$'
LOCALE_TABLE_STAKEHOLDERS_MSG="Missing Key Stakeholders table header"
LOCALE_TABLE_METRICS='^\| Metric \| Target \| Source \|$'
LOCALE_TABLE_METRICS_MSG="Missing Success Metrics table header"
LOCALE_TABLE_TIMELINE='^\| Milestone \| Target Date \| Notes \|$'
LOCALE_TABLE_TIMELINE_MSG="Missing Timeline & Milestones table header"
LOCALE_TABLE_RISKS='^\| # \| Risk / Dependency \| Likelihood \| Impact \| Mitigation \|$'
LOCALE_TABLE_RISKS_MSG="Missing Risks & Dependencies table header"
