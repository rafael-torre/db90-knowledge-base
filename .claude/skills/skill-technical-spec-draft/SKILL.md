---
name: skill-technical-spec-draft
description: 'Draft a Layer 3 Feature Technical Spec from upstream documentation only, no codebase access. Use for Phase 1 of the technical spec pipeline, normally invoked by skill-technical-spec.'
---

# Technical Spec — Draft

## Purpose
Produce the first draft of a Layer 3 Feature Technical Spec from Layer 1/Layer 2 documentation and the Architecture Overview alone. Captures technical approach, data model intent, API contract shape, frontend architecture decisions, key flows, and a rough work breakdown. Codebase-specific detail (actual file paths, current schema fields, real component/route names) is deliberately left as a guiding placeholder — that's Phase 2's job (`skill-technical-spec-enrich`).

## Personas
Layer 3 — apply `agent-architect` (Winston) + `agent-developer` (Amelia) framing.

## Inputs
- Layer 1 feature spec, `status: consensus` (hard prerequisite — stop and report if not met, don't draft against an unresolved product spec)
- Layer 2 feature design spec, when the feature has a UI surface
- `layers/layer-3-architecture/latest/architecture-overview.md`
- `layers/layer-3-architecture/latest/data-model.md` — read before drafting Data Model; reuse or extend an existing table/column rather than proposing a duplicate. A genuinely new table/column is expected and fine — note it as new, don't force-fit it into something existing.
- Feature/domain name (from the caller)

## Outputs
- `layers/layer-3-architecture/latest/features/[domain]/[feature].md`, `status: in_progress`, all template sections present (see `latest/features/_example-domain/_example-feature-technical-spec.md`)
- `relates_to` frontmatter populated: Layer 1 spec, Layer 2 spec if applicable, Architecture Overview
- Sections with no codebase grounding yet are marked with an inline placeholder describing what Phase 2 needs to fill in — not fabricated file paths, schema, or component names

## Steps
1. Validate the Layer 1 prerequisite. If it isn't `status: consensus`, stop and report what's blocking — don't draft.
2. Load upstream context: Layer 1 spec, Layer 2 spec (if present), Architecture Overview, current `data-model.md`.
3. Determine which template sections apply per `latest/features/README.md`'s skip rules (e.g. no Frontend Architecture for a backend-only feature) — mark skipped sections per that convention rather than leaving them blank.
4. Draft each applicable section: Overview, Acceptance Criteria, Technical Approach, Data Model (checked against `data-model.md` for reuse), API Contracts (shape/verbs, not necessarily final routes), Frontend Architecture (decisions, not real component paths), Integration Points, Key Flows, Technical Constraints and Risks, Testing Approach, a rough Work Breakdown.
5. Write the file with `status: in_progress` and the `relates_to` links above.
6. Report a short summary: what's drafted, which sections are placeholders awaiting Phase 2, and any open questions for the tech lead. Stop here — do not proceed to enrichment.

## Guardrails
- No codebase access in this phase — don't guess at file paths, schema fields, or component names; that's exactly what Phase 2 exists to ground.
- Don't invent a new Data Model table/column without first checking `data-model.md` for something reusable.
- Don't advance `status` past `in_progress` — that's the tech lead's call, applied by `skill-technical-spec` after review.
- `skill-technical-spec` normally runs this phase in a fresh subagent with no memory of any prior conversation — treat the Inputs above (feature/domain name, upstream doc paths) as the complete set of context available; don't assume anything discussed earlier is known.
