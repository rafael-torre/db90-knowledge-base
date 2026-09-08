# Layer 1 Product Feature — Document Standard

Applies to every feature document this skill writes, always under `layers/layer-1-product/latest/features/**` — new or edited. Goal: get the document right the first time, since there is no later promotion pass to catch gaps.

## Structure

Frontmatter: `title`, `layer: product`, `owner`, `last_updated`, `relates_to`, `status`.

Sections, in order:
1. Problem and Context
2. Users
3. Feature Description
4. Business Rules
5. Edge Cases
6. Out of Scope
7. Dependencies
8. Open Questions

## Section rules

**Problem and Context** — the problem the feature solves and why it needs to exist. Framing only, no solution detail.

**Users** — every actor touched by the feature, and what each one actually does or experiences (who triggers, who is affected). Don't just list role names.

**Feature Description** — state only what the feature does: the behavior, the actors' actions, the outcomes. Never state what it excludes or where something else is handled ("this doesn't cover...", "the technical detail belongs in Layer 3", "does not include X"). Exclusions belong exclusively in Out of Scope — nowhere else. Layer boundaries (e.g. Layer 3 owning implementation detail) are structural and never need restating in prose.

**Business Rules** — table: `Rule | Description | Confidence | Source`.

- Confidence is exactly one of `Confirmed` or `Provisional`. No other values, always in English.
- Source is exactly one of, always in English:
  - `<upstream-doc-name>` (e.g. `product-brief`) — traceable to an explicit statement there.
  - `Team decision` — resolved live with the user during drafting/editing. Always pairs with `Confirmed`. Never pair `Team decision` with `Provisional` — a team decision is confirmed by definition.
  - `Inferred from <rule/feature>` — logically implied by an already-confirmed rule. Can be `Provisional` if not independently validated.
  - `No explicit source` — a real gap, not yet decided. Always `Provisional`, and must have a matching row in Open Questions.
- A `Provisional` / `No explicit source` row without a matching Open Question is a bug. An Open Question whose answer the user already gave in conversation is also a bug — resolve it immediately, don't let both states coexist.

**Edge Cases** — table: `Scenario | Expected Behavior | Notes`. Notes only carries a pointer to Open Questions while the underlying behavior is genuinely undecided. Once resolved, clear the note — a stale "see Open Questions" pointer to an already-answered question is wrong.

**Out of Scope** — bullet list, each a short noun phrase plus the reason it's excluded, e.g. `- *<excluded thing> — <why: not mentioned in product-brief / owned by another feature>*.` The only place exclusions live.

**Dependencies** — table: `Dependency | Type (Depends on / Interacts with) | Notes`.

**Open Questions** — table: `Question | Context | Owner | Target Date | Status | Resolution`. Holds only unresolved rows. When the user answers one: fold the answer into the relevant Business Rule (`Confirmed` / `Team decision`) and any Edge Case note, then delete the row — don't keep it around marked "Resolved." An empty table (headers only) means the doc is fully resolved, and is a valid, common end state.

## Prose rules (apply everywhere in the doc)

- No inline narration of scope/layer boundaries ("this is detailed in Layer 3", "the how doesn't belong in this document") — Out of Scope and Dependencies already carry that.
- No inline narration of decision provenance ("as decided in the meeting", "per the discussion with the team") — the Source column already carries that.
- No dated changelog callouts ("Update 2026-07-29: ...", "> ⚠️ Added this session"). The document is a clean current-state description; git history and `last_updated` are the record of when things changed.
- Schema/code-shaped names that leak into a product spec (endpoint names, field names, enum values) stay in English; everything else follows the project's documentation language.
