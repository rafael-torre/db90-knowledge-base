---
name: skill-product-feature-spec
description: 'Create, edit, or review a Layer 1 (product) feature document against the finalized documentation standard. Use when the user wants to draft a new Layer 1 product feature, edit an existing one, or resolve open questions on one.'
---

# Product Feature Spec

## Purpose
The dedicated path for Layer 1 (product) feature documents, writing directly against a concrete, enforced standard. This skill exists because most rework on these docs comes from the same recurring gaps: unresolved rules left silently unconfirmed, exclusions bleeding into the Feature Description, and prose narrating scope or decision provenance instead of just stating the fact. See `standard.md` for the full document standard this skill enforces.

## Inputs
- Layer 0 product brief in `latest/` (ideally `status: consensus`) for upstream context
- Feature or domain name from the user
- For edits: the existing feature document path

## Outputs
- Always `layers/layer-1-product/latest/features/<domain>/<feature-name>.md` — new or edited, this skill never writes to `intermediate/`. New docs get `status: in_progress` until the content reaches consensus.

## Steps
1. Load `standard.md` for the structure, table conventions, and prose rules below — apply them for the whole session, not just at the end.
2. Load the Layer 0 product brief and any `relates_to` docs for context.
3. Determine intent: new feature doc vs. editing/resolving an existing one.
4. Draft or update each section per `standard.md`'s structure.
5. For every behavior the brief doesn't settle, ask the user directly instead of guessing or leaving it silently unconfirmed. If they answer: record `Confirmed` / `Team decision`. If they defer: record `Provisional` / `No explicit source` and add an Open Questions row.
6. Self-check before presenting the doc:
   - Feature Description contains no exclusion language — move anything found to Out of Scope.
   - No prose narrates scope/layer boundaries or decision provenance.
   - No changelog-style callouts.
   - Every `Provisional` row has a matching Open Question; every Open Question the user already answered this session is resolved and removed.
7. Write directly to `layers/layer-1-product/latest/features/<domain>/<feature-name>.md` and present it to the user; iterate in place.
