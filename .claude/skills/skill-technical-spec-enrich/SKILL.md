---
name: skill-technical-spec-enrich
description: 'Enrich an in-progress Layer 3 Feature Technical Spec with real codebase details, one read-only subagent per configured repo. Use for Phase 2 of the technical spec pipeline, normally invoked by skill-technical-spec.'
---

# Technical Spec — Enrich

## Purpose
Ground an in-progress Feature Technical Spec in the actual codebase(s): real file paths, current schema, live API routes, existing component names. Runs one read-only subagent per relevant repo in parallel, then merges their findings into the spec in a single write — repo subagents never edit the spec file directly, so parallel reads never race on the write.

Also handles change-driven re-enrichment: when the spec is flagged `needs_review`/`needs_update` because an upstream doc changed, this skill re-runs targeted at just the affected sections instead of the whole file.

## Personas
Layer 3 — apply `agent-architect` (Winston) + `agent-developer` (Amelia) framing.

## Inputs
- The in-progress spec file (`status: in_progress`, or `needs_review`/`needs_update` for re-grounding)
- `.companion.yaml` `technical_spec.repos`: repo name → local filesystem path → the spec sections it owns (`data_model`, `api_contracts`, `frontend_architecture`, `integration_points`) → optionally, `domains` it applies to
- `.companion.yaml` `technical_spec.domain_aliases`, if present: alias → real feature-folder name, for repos whose `domains` list uses a friendlier name than the literal folder
- `layers/layer-3-architecture/latest/data-model.md`, for the repo(s) that own `data_model`

## Outputs
- Same spec file, sections updated in place with concrete references
- `latest/data-model.md` re-synced if the Data Model section changed — this file must never lag behind a feature spec's schema
- A finalized Work Breakdown, synthesized across all repos that contributed (no single repo subagent owns this section — it's assembled centrally)

## Steps
1. Read the spec. Confirm it's in a state this skill handles (`in_progress`, `needs_review`, or `needs_update`). For `needs_review`/`needs_update`, identify which sections the upstream change actually affects — scope the run to those.
2. Read `technical_spec.repos` from `.companion.yaml`. The spec's domain is the top-level folder under `layers/layer-3-architecture/latest/features/` in its own path (e.g. `checkout`, `billing-portal`). For each repo: skip it if every section it owns is marked N/A/skipped in the spec, if it has no `path` configured yet (e.g. not cloned locally), or if it declares a `domains` list that doesn't match this spec's domain — a repo with no `domains` key applies regardless of domain. When comparing, resolve each entry in `domains` through `technical_spec.domain_aliases` first (alias → real folder name) before comparing to the spec's own folder-derived domain, so a repo can use a friendlier alias (e.g. `mobile_architecture`) instead of the literal folder name (e.g. `checkout`). This is what lets two repos own the same section (e.g. `frontend_architecture` on both a web and a mobile repo) without a manual override: only the repo whose `domains` matches the spec's own domain runs. Prepare one subagent per repo that survives this filter.
3. Spawn all applicable repo subagents in parallel. Each subagent:
   - Is **read-only** against its repo (no Edit/Write tools) — it inspects the codebase, it does not change it.
   - Receives: the repo's local path, the current draft text for the section(s) it owns, and — for a repo that owns `data_model` — `latest/data-model.md` for the reuse-check.
   - Returns structured findings only (per-section proposed content, with concrete `path:line` references backing every claim) — never touches the spec file.
4. Once all subagents return, apply their findings to the spec in one serialized write: each repo's findings replace the placeholder content in the section(s) it owns. Synthesize the Work Breakdown from all repos' findings together — it spans repos by nature, so no single repo subagent can own it.
5. If the Data Model section changed, sync `latest/data-model.md` (add/update the affected tables and columns — this mirrors the sync `skill-promote-to-latest` does for other latest-doc types, since Layer 3 feature specs bypass that skill's intermediate→latest path).
6. Write the file. Report a per-section summary of what changed (or what's still open, e.g. a repo that wasn't configured/available). Stop here — do not flip `status` to `consensus`; that's the tech lead's call, applied by `skill-technical-spec` after review.

## Guardrails
- Repo subagents are read-only. If a finding can't be backed by a concrete `path:line` citation, it doesn't go in the spec as fact — flag it as an open question instead.
- Never let two subagents' findings for the same section overwrite each other silently — if two repos both claim a section for the same domain (shouldn't happen with correct `owns`/`domains` config, but check), surface the conflict rather than picking one.
- Don't advance `status` — report and stop.
- `skill-technical-spec` normally runs this phase itself in a fresh subagent with no memory of any prior conversation — treat the Inputs above (spec path, affected sections for re-grounding, `.companion.yaml` config) as the complete set of context available; don't assume anything discussed earlier is known. This subagent then fans out to its own per-repo subagents as described above — two delegation layers deep.
