---
name: skill-generate-tickets
description: 'Generate tickets from a Layer 3 feature technical spec and create them on the configured GitHub board. Use when a technical spec is ready for implementation.'
---

# Generate Tickets

## Purpose

Turn a Layer 3 feature technical spec's Work Breakdown into real GitHub tickets, one per repo, tracked on the configured Project board — without maintaining ticket text in two places. The spec keeps a one-line description and a Reference link; the ticket body (title, description, AC, dependencies, labels, verification scope) lives only on GitHub.

Every ticket must be self-contained — see `ticket-template.md` for what that means and why.

## Personas

This is Layer 3 technical decomposition — apply the `agent-architect` (Winston) + `agent-developer` (Amelia) framing from the Layer-to-Persona table. Business-priority sequencing (e.g. "ship X before Y for a demo") is not a technical call — when the pure dependency graph allows more than one valid build order, ask the user directly rather than picking one or invoking a PM persona to decide on their behalf.

## Inputs

- Layer 3 feature technical spec in `latest/` (status: `consensus`)
- Layer 3 architecture overview (cross-cutting constraints)
- `.companion.yaml` board configuration: `board.type`, `board.org`, `board.project_number`, `board.repos` (Layer → repo map), `board.labels`

## Outputs

- A reviewed, possibly revised Work Breakdown table (see Step 2 — the existing table is a draft, not a given), ending in one closing feature ticket row
- Ticket definitions, reviewed by the user before anything is created
- Tickets created on the configured GitHub Project, filed in the correct repo, labeled — the dev tickets linked as native GitHub sub-issues of the closing feature ticket
- Work Breakdown `Reference` column populated with ticket URLs — this table is the single list of tickets for the feature; nothing duplicates it on the GitHub side

## Steps

1. **Validate prerequisites.** Spec status is `consensus`. `.companion.yaml` has board config. If `board.repos` maps a Layer to a repo that doesn't exist yet, note it and continue — tasks for that Layer get flagged for manual placement later, not blocked on.

2. **Load full context, not just the table.** Read Technical Approach, Data Model, API Contracts, Frontend Architecture, Integration Points, Key Flows, Business Rules and Constraints, Technical Constraints and Risks, and Testing Approach. The Work Breakdown table can't be assessed against itself. Also check any `relates_to`-linked sibling spec that defines an overlapping field or table — a field that looks unspecified in this spec may already be resolved there, or by a precedent the sibling spec already established for the same kind of data.

3. **Assess the existing Work Breakdown — don't just execute it.** For each row, check:
   - True atomicity: one deliverable, one repo, completable in a single focused session.
   - Correct repo/Layer assignment against `board.repos`.
   - Correct `Depends On` order against the *actual* technical dependencies in the spec (schema before the logic that reads it, API contract before its frontend/mobile consumer).
   - Completeness: infra, config, or migration tasks implied elsewhere in the spec but missing from the table.

   If the table already holds up, say so and move on. If it doesn't, propose a revised table with a one-line rationale per changed row, shown against the original. Get explicit approval before applying it — this table lives in a `latest/` doc, and a wrong call here cascades into every ticket generated from it, so the user resolves the disagreement, not the model.

   If two build orders are both technically valid and the remaining choice is a business-priority call, ask the user rather than picking one.

4. **Draft ticket content per approved dev task**, following `ticket-template.md`'s structure and its inline-vs-link and Out of Scope rules. Verification scoped to what's actually observable at that task:
   - `type:infra` → operating infra: CI/CD pipeline steps, provisioning, config, running a migration as part of a deploy — verified via pipeline/deploy checks.
   - `type:logic` → business logic, including authoring migration files (schema design) — verified via unit tests (migration applies/rolls back, schema matches spec); add an integration test only if this is the first code path to touch something added by an earlier `type:infra`/schema task.
   - `type:api` → integration test against the endpoint.
   - `type:ui` → component test + E2E covering the user-observable behavior; name which earlier task(s) it's exercising.

   **Never fill a gap with a plausible-sounding assumption — but check it's a real gap before escalating it.** "The spec doesn't state this" and "no one has decided this yet" are not the same claim. Before treating something as missing, check whether it's already resolved in a raw-input artifact (open the actual file) or by a sibling spec covering the same field/table. Only what's genuinely absent everywhere becomes a gap. Engineering-resolvable gaps become an open question tied to the ticket, asked before creating it. Gaps only a non-engineering party can resolve (product/compliance/data sign-off, a spec not yet written) go under `Blocked By:` instead — build against a mocked/injectable seam and track the real resolution as its own ticket, rather than stalling ticket creation on it.

5. **Draft one closing feature ticket**, label `type:qa` (routing tag only — see below), per `ticket-template.md`'s Feature Ticket section. Title it as the feature/capability itself, matching how the source spec names it — never prefix or frame the title as a testing task. Description opens with what the feature delivers (from the spec's Overview), not with what's being verified. Acceptance Criteria comes from the spec's `Acceptance Criteria` "product" rows; Manual Test Steps comes from `End-to-End Tests`, as concrete steps against the assembled feature. `Depends On` lists every dev ticket drafted in Step 4. If the feature has no user- or system-observable surface without another spec's tickets (e.g. a headless backend module only reachable once a consumer UI ships), scope the manual steps to what's actually exercisable now (a CLI script, a direct function call) and note the rest under Out of Scope as belonging to that other spec's own closing ticket — never stretch this ticket to claim coverage it can't actually exercise.

6. **User review.** Show every draft ticket, dev and feature, with resolved answers folded in, before creating anything on the board.

7. **Create on the board.** For each approved dev ticket: `gh issue create` in the repo from `board.repos`, apply its labels, add it to the Project (`board.project_number`). Then create the feature ticket the same way, and link each dev ticket as its native GitHub sub-issue (`gh issue edit <feature ticket> --add-sub-issue <dev ticket>` per dev ticket, same repo).

8. **Write back.** Populate the Work Breakdown's `Reference` column with each ticket's URL, including a final row for the feature ticket. Its `Task` cell is the bare feature name, exactly matching the ticket title — no "(closing ticket)"/"(QA)" suffix; the row's position and Reference already make what it is obvious. Resolve any `Depends On` entries that were task names into real cross-repo issue references now that IDs exist.

## Guardrails

- Ticket text lives only on GitHub. The spec keeps a one-line description and a link — never the full ticket body.
- No content-free tracking epics. The one exception is the closing feature ticket (Step 5): it's a parent via native sub-issues, but it carries real content of its own — the feature's definition of done — not a bookkeeping wrapper that just lists children. The Work Breakdown table is still the only list of a feature's tickets; don't recreate it on the board otherwise.
- The `type:qa` label on the feature ticket is a routing tag (how it's verified), not its identity — same sense as `type:ui` meaning "verified via component/E2E," not "this ticket is a UI." Never let the title or Description frame the ticket as existing for QA's sake; it exists to represent the feature, and QA is one of its readers.
- Every ticket states its own verification scope explicitly, matching its label — e.g. a pipeline/deploy check is a valid, expected answer for an infra-labeled ticket; it doesn't need a unit test bolted on to look more rigorous.
- Every assumption needed to complete a ticket gets verified with the user before the ticket is created — never resolved unilaterally.
- Every dev ticket is self-contained per `ticket-template.md` — missing an Out of Scope section is the most common way this silently fails. The feature ticket is the one ticket type allowed to reference its sub-issues instead of re-deriving their content, since its job is representing the assembled feature, not standing alone for an implementer.
- `Depends On` ≠ `Blocked By` — see Step 4.
