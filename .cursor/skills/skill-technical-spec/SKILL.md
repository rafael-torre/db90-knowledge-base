---
name: skill-technical-spec
description: 'Guide a Layer 3 Feature Technical Spec through its full lifecycle -- draft, codebase enrichment, and ticket creation -- detecting the current phase automatically and pausing for tech-lead approval at each transition. Use when the user wants to create, continue, or check status on a feature technical spec, so they do not have to remember or re-run the underlying phase skills themselves.'
---

# Technical Spec — Orchestrator

## Purpose
Single entry point for the Layer 3 Feature Technical Spec pipeline described in `latest/features/README.md`. Detects the spec's current phase from its frontmatter `status`, runs the right phase via a subagent, and stops for explicit tech-lead review/approval before advancing — so the user never has to remember whether they're on Draft, Enrich, or Ticket, or which skill each maps to.

This skill coordinates; it does not do the drafting or enrichment work itself. Draft and Enrich are each run in a single fresh subagent (Agent tool, not a fork) that follows the phase skill end to end and returns only its final summary — so this session's own context stays small regardless of how large the upstream docs or target codebases are. Review (step 4) runs inline in this session instead, deliberately: the tech lead's disposition of each finding is interactive and benefits from the reasoning trail staying in context, not just the finding list.

## Personas
Layer 3 — apply `agent-architect` (Winston) + `agent-developer` (Amelia) framing, per the Layer-to-Persona table in `db90-companion.md`.

## Inputs
- Feature/domain name (ask if not given)
- Whatever state currently exists: nothing yet, an `in_progress` draft, a `needs_review`/`needs_update` spec, or a `consensus` spec

## Outputs
- Progress through exactly one phase per invocation, with a clear stop-and-review point
- Before `status: consensus` is ever set: an adversarial review and an edge-case review of the enriched spec, findings dispositioned by the tech lead
- On resume (re-invoking this skill for the same feature later), correctly picks up wherever the spec was left

## Steps
1. **Resolve the feature.** Locate `layers/layer-3-architecture/latest/features/[domain]/[feature].md`. If it doesn't exist, confirm the domain/feature name and the corresponding Layer 1 path with the user before proceeding.
2. **Detect phase from `status`:**
   - No file yet → **Draft.** Check the Layer 1 feature spec is `status: consensus` first; if not, stop and report what's missing.
   - `status: in_progress` → **Enrich.**
   - `status: needs_review` or `needs_update` → **Enrich (re-grounding mode)** — the cascade mechanism flagged this spec because an upstream doc changed.
   - `status: consensus` (or legacy `status: established` on specs written before this skill existed — treat as equivalent for detection, don't rewrite the file just to relabel it) → **Ticket.**
3. **Run the phase:**
   - Draft → spawn one fresh subagent with the feature/domain name and the resolved Layer 1/2 paths; instruct it to follow `.claude/skills/skill-technical-spec-draft/SKILL.md` end to end and report back its step-6 summary (what's drafted, what's placeholder, open questions). The subagent does the reading and writing; this session sees only the summary.
   - Enrich / re-grounding → spawn one fresh subagent with the spec path (and, for re-grounding, which sections are affected) and instruct it to follow `.claude/skills/skill-technical-spec-enrich/SKILL.md` end to end (it fans out to its own per-repo subagents internally) and report back its step-6 per-section summary. This session sees only that summary, never the individual repos' raw findings.
   - Ticket → offer to invoke `skill-generate-tickets` (don't force it — the user may want to review consensus status further first).
   - Before spawning either subagent: resolve anything ambiguous (feature/domain name, which sections a re-grounding pass targets) with the user in this session first — a fresh subagent can't ask. Also restate, in the subagent's prompt, any decision the tech lead already made earlier in this session that bears on this phase (e.g. "skip the reporting repo") — the subagent starts cold and won't otherwise see it.
4. **After Enrich specifically, run the quality gate before anything is presented for approval, inline in this session (not delegated — see Purpose).** Every other `latest/` doc type in this framework gets editorial + adversarial review via `skill-promote-to-latest` before it's promoted; Layer 3 feature specs bypass that skill (they go straight to `latest/`), so this skill carries the equivalent bar itself:
   - Invoke `skill-review-adversarial` against the enriched spec — surfaces weak assumptions, unresolved gaps, inconsistencies with the Architecture Overview/NFRs.
   - Invoke `skill-review-edge-cases` against Acceptance Criteria and Key Flows — surfaces unhandled branches/boundary conditions before they turn into missing Work Breakdown tasks.
   - Fold both findings reports into what gets presented at the next gate. Don't silently drop or auto-resolve a finding — every one gets an explicit disposition from the tech lead (fixed now, tracked as an open question, or knowingly accepted) before `status: consensus` is set.
5. **Gate on human approval before advancing — this is the core job of this skill:**
   - After Draft returns: present its summary (what's drafted, what's placeholder) and stop. Do not auto-run Enrich in the same turn. Wait for the tech lead to review and explicitly say to continue.
   - After Enrich + the quality gate (step 4): present the enrichment summary together with the adversarial and edge-case findings, and stop. Only after every finding has a disposition and the tech lead explicitly approves does this skill itself set `status: consensus` and bump `last_updated` — the phase and review skills never flip status themselves, by design.
   - After setting `status: consensus`: offer Ticket creation; proceed only if the user wants to continue now.
6. **On any later re-invocation** for the same feature, re-run step 2 — the frontmatter is the only state this skill needs, so nothing about the process has to be remembered between sessions.

## Guardrails
- Never advance `status` without the user's explicit go-ahead at that specific gate — a prior approval doesn't carry forward to the next phase.
- Never set `status: consensus` without both `skill-review-adversarial` and `skill-review-edge-cases` having run against the enriched spec and every finding having an explicit disposition.
- Never run more than one phase per invocation without stopping for review in between.
- If the detected phase's prerequisite isn't met (Layer 1 not `consensus`, `technical_spec.repos` missing/empty in `.companion.yaml` for Enrich), stop and report the gap rather than working around it.
- Draft and Enrich subagents start cold — they have no memory of this session. Never rely on one to recall a decision made earlier at a gate; put it explicitly in the spawn prompt instead.
- Never spawn the Draft or Enrich subagent with an unresolved input (ambiguous feature/domain name, unclear re-grounding scope) — resolve it with the user first, since the subagent can't ask.
- Don't delegate step 4 (review) to a subagent — it stays inline so the tech lead can interrogate individual findings during disposition without a round trip.
