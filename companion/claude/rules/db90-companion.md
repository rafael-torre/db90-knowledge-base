# DB90 Companion — Layer Guidance

This rule is layer-aware. When working on any document, detect the layer from the file path and apply the guidance below.

## Layer Detection

| Path pattern | Layer |
|---|---|
| `layers/layer-0-business/` | Layer 0 — Business |
| `layers/layer-1-product/` | Layer 1 — Product |
| `layers/layer-2-design/` | Layer 2 — Design |
| `layers/layer-3-architecture/` | Layer 3 — Architecture |
| `layers/layer-4-implementation/` | Layer 4 — Implementation |

## Layer-to-Persona Activation

| Layer | Auto-suggested Persona |
|---|---|
| Layer 0 — Business | agent-analyst (Mary) |
| Layer 1 — Product | agent-pm (John) |
| Layer 2 — Design | agent-designer (Sally) |
| Layer 3 — Architecture | agent-architect (Winston) + agent-developer (Amelia) |
| Layer 4 — Implementation | agent-developer (Amelia) |
| All layers | agent-writer (Paige) for promotion/review |

## Layer-Aware Guidance

- Before drafting or reviewing a Layer N document, load the Layer N-1 `latest/` documents via `relates_to` links
- Surface key decisions and constraints from upstream before proceeding
- Enforce sequencing: do not promote Layer N to latest before Layer N-1 latest reaches `consensus`
- Detect which layer you are in and tailor suggestions accordingly

## Session State

- At session start the `SessionStart` hook runs `scan-project-state.sh`, writing `.claude/session-state.md`
- Read that file and surface docs with `status: needs_review`, `needs_update`, or `in_progress`
- Propose a concrete focused scope for the session based on what is unfinished

## Skill Suggestions

When working on a document, check `~/.claude/skills/` for a skill matching the document type:

- `skill-product-feature-spec` — for Layer 1 feature spec drafts and edits (product)
- `skill-ux-spec` — for Layer 2 design spec drafts
- `skill-create-architecture` — for Layer 3 architecture spec drafts
- `skill-technical-spec` — for Layer 3 feature technical specs: single entry point for draft, codebase enrichment, and ticket creation; auto-detects phase from frontmatter `status`
- `skill-review-prose` — for prose quality review across any layer
- `skill-review-structure` — for structural review across any layer
- `skill-review-adversarial` — for adversarial review of Layer 3 specs
- `skill-review-edge-cases` — for edge case hunting
- `skill-brainstorm` — for ideation and exploration
- `skill-elicitation` — for deeper critique and refinement
- `skill-product-brief` — for Layer 0 product briefs
- `skill-research-market` — for Layer 0 market research
- `skill-research-domain` — for Layer 0 domain research
- `skill-research-technical` — for technical research
- `skill-readiness-check` — for implementation readiness validation
- `skill-generate-context` — for generating project context
- `skill-index-docs` — for indexing documentation
- `skill-shard-doc` — for splitting large documents
- `skill-investigate` — for investigation tasks
- `skill-navigator` — for help and orientation
- `scan-project-state` — project health snapshot
- `session-handoff` — end-of-session resume packet
- `skill-promote-to-latest` — suggest when user indicates readiness to move content from intermediate/ to latest/ (phrases like "ready to finalize", "promote this", "move to latest")
- `skill-generate-tickets` — suggest when a Layer 3 feature technical spec reaches consensus status (requires board config in .companion.yaml: board.type and board.project_number)

If a matching skill exists, load and follow it. Otherwise use the template structure in the document as a guide.

## Handoff

When ending a session or switching context, run the `session-handoff` skill. It writes `.claude/session-handoff.md` capturing decisions, blockers, and next steps.

## Latest Document Style

`latest/` documents (including ADRs under `latest/adrs/`) must read as a clean, current-state description of the system/product — never as a changelog or session log:

- Do not wrap new or changed content in dated callouts like "> ⚠️ Added this session:". Integrate the content directly into the prose, in the same voice as the rest of the document, as if it had always been there.
- This applies even inside ADRs: an ADR's permanence *is* its decision history (plus git history and `last_updated`). Its `Context`/`Decision` body should still read as one coherent account of the decision, not a narrated log of edits to the ADR itself.
- Unresolved or evolving decisions belong in the Open Questions table (or equivalent) or in `adr_status: proposed` / inline ⚠️ markers — not in prose narrating what changed and when.
- Git history and `last_updated` are the record of *when* something changed; the document body is the record of *what is true now*.

## Providing Guidance

- Always reference the specific layer and frontmatter `status` of the current document
- Tailor tone and focus to the role in `.companion.yaml` (`pm`, `designer`, `tech-lead`, `developer`, `engagement-lead`)
- If no `.companion.yaml` exists, offer to create one
