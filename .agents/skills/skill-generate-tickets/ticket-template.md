# Ticket Template

<!-- Format guide for skill-generate-tickets. Each ticket follows this structure. -->

A ticket must be fully actionable on its own — an implementer, human or model, should never need to open the source feature spec to do the work. Handed the full spec, a model tends to treat the whole feature as its job and reach into neighboring work it wasn't asked to touch; handed a scoped ticket with its boundary stated, it builds exactly that. The operative rule: **don't point back to the spec that generated this ticket** — inline what it says instead. That's different from linking to a genuine external source of truth that lives outside the spec (a Figma file, a corpus data file, a client-provided doc) — those are fine to link, the same way an importer ticket links to the `.xlsx` it reads rather than pasting its rows. The distinction is *what* you're pointing at, not whether pointing is ever allowed.

## Title

**Labels** (applied as actual GitHub labels): `type:infra` | `type:api` | `type:ui` | `type:logic`

**Depends On**: [other tickets that must merge first for a real technical reason — cross-repo `owner/repo#N` once IDs exist, task name otherwise; "none"]

**Blocked By**: [include this line only if applicable — something engineering cannot resolve by writing code: a pending decision from a non-engineering party, a spec that doesn't exist yet. Naming it here instead of silently absorbing it as an assumption is what keeps a gap from turning into an invented answer.]

### Description
The concrete technical facts needed to build this, inlined — exact step order, schema snippets, state transitions. Never a pointer back to the spec ("see Data Model section", "per the sequence diagram above") — reproduce the relevant piece directly, even if that means repeating a few lines that also live in the spec. If this ticket calls into another module (built or not), state that module's input/output contract explicitly, so this ticket's boundary doesn't require reading another ticket either.

If the ticket's own mechanics use domain-specific vocabulary that isn't defined anywhere else in it (a business term, an internal name for a concept — "node," "tree," "cell"), open with one short sentence defining it. That's a fact needed to parse the rest of the ticket, not a motivation paragraph: "The pricing engine walks a decision tree of rules, branch by branch, until it reaches a terminal node with a resolved price" is a definition; "The pricing engine exists because manual pricing overrides were slow and inconsistent" is motivation — keep the first, cut the second (see What doesn't belong). Skip this when the deliverable is purely mechanical and the vocabulary appears only as literal identifiers to create (e.g. a migration matching an exact column spec) — there's nothing to reason about conceptually, so there's nothing to orient.

Describe queries and mutations as precise, stack-agnostic prose — exact table/column names, exact conditions, exact transaction boundaries — not as literal SQL or a specific ORM's API. Don't assume an ORM/query layer that isn't a confirmed decision in Architecture Overview/ADRs; naming one that was never chosen invents an architecture decision, the same failure as inventing any other fact. ("Look up the `node_transition` row where `source_node_id` matches the current node and `response_value` matches the response; read its `destination_node_id`" — not `SELECT destination_node_id FROM node_transition WHERE ...`.) Schema/DDL notation in Data/Schema is exempt — a migration's columns/types/constraints look the same regardless of ORM, so there's no stack assumption being smuggled in.

### Data/Schema — `type:logic` tickets that touch a table
[Inline the exact columns/types/constraints/indices this ticket creates or touches. Not a reference to a section number. Omit if not applicable.]

### API Contract — `type:api` tickets, or any ticket that consumes one
[The exact request/response shape (fields, types, status codes) this ticket exposes or calls. If consuming an endpoint another ticket owns, inline its contract here too — don't send the implementer to that other ticket to look it up.]

### Design Reference — `type:ui` tickets
[Link to the Figma frame/design file (a genuine external source of truth — fine to link, see above). Then inline what the AC actually needs to check without opening it: the states this component must handle (loading / empty / error / success), copy strings (verbatim, in the language they'll ship in), breakpoints or responsive behavior called out in the design, any interaction/animation behavior that isn't obvious from a static frame.]

### Acceptance Criteria
1. [ ] [Specific, testable, observable pass/fail condition — not a restated unit test, not a reworded business rule]
2. [ ] [...]

### Out of Scope
[Adjacent things this ticket does NOT include — neighboring Work Breakdown tasks, modules, or spec sections that touch the same file, table, flow, or screen as this one. This is the section that keeps an implementing model from over-building. Skipping it is the most common way a "self-contained" ticket still isn't.]

### Verification
[The test scope for this ticket]

### Reference
[Link to the source feature spec, for traceability only. Never required reading to do the ticket's work.]

## Feature Ticket (one per feature, closes the Work Breakdown)

The closing ticket in every Work Breakdown — the feature itself, User-Story-shaped: what it delivers and what "done" means, not a task. The dev tickets are its technical decomposition, linked as native GitHub sub-issues, so closing all of them is visible progress toward this one. Title it as the feature/capability, the same way the source spec names it — never prefix or frame it as if its purpose were testing; verification is one section of it, not its identity. Label `type:qa` is still applied, but only as a routing tag (same sense as `type:ui` meaning "verified via component/E2E," not "this ticket is a UI") so QA can filter the board for what to run — it doesn't say what the ticket is.

**Labels**: `type:qa`

**Depends On**: every dev ticket from this Work Breakdown (`owner/repo#N` list) — also linked as native GitHub sub-issues of this ticket, so closing all of them is visible progress toward this one.

### Description
Open with what the feature actually delivers — one or two sentences pulled from the spec's Overview, the same way a reader would be told what they're getting, not what they're testing. Then, if relevant: what a person needs available to verify it (test data, a seeded environment, a specific role/account). If the feature has no user- or system-observable surface yet (a headless backend module only reachable once another spec's UI ships), say so plainly and scope the steps below to what's actually exercisable now — a CLI script, a direct function call — not a walkthrough that can't happen yet.

### Acceptance Criteria
Pull directly from the spec's Acceptance Criteria "product" rows (or equivalent product-level criteria) — the observable product behavior, not the technical/implementation criteria a dev ticket already owns. This is the feature's definition of done.

### Manual Test Steps
Numbered, concrete steps a person follows against the running feature — exact commands, inputs, or UI actions and the expected observable result at each step. Not a restatement of any one dev ticket's unit/integration tests; this is the feature working end to end (or as end-to-end as this feature's own boundary allows — see Out of Scope).

### Out of Scope
Behavior that looks like it belongs here but is owned by a different feature's own closing ticket (e.g. a downstream UI or consumer spec not yet built) — name it and say where its coverage actually lives, rather than silently stretching this ticket to claim it.

### Reference
[Link to the source feature spec.] Unlike a dev ticket, this one may point a reader to the spec's Key Flows or Acceptance Criteria for the fuller picture — its job is representing an assembled feature, not building a piece of it in isolation.

## What doesn't belong

- A "why" / motivation paragraph. The spec has that; the ticket needs the resolved fact, not the reasoning that produced it.
- A restated dependency graph ("this depends on X, which depends on Y, which..."). List only this ticket's own direct dependencies.
- Mermaid diagrams reproduced wholesale. If a sequence diagram matters to this ticket, translate the relevant steps into the numbered list the implementer will actually follow — not the diagram syntax itself.
- A Figma link with no inlined states/copy. The link tells the implementer what it looks like; it doesn't tell them what to build when the API call fails. That still has to be in the ticket.
