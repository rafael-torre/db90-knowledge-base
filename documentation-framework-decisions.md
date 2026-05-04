# Documentation Framework — Decision Log

Design decisions made during the creation of the documentation framework. Each entry captures what was decided, what alternatives were considered, and why. This document exists so future sessions can understand the reasoning without re-doing the analysis.

---

## Strategic Context

This framework was initiated by Rafael Torre, Practice Lead Engineer at Dual Boot Partners, as part of a broader initiative: **documentation as the foundation of the AI strategy**. The core thesis is that structured, layered documentation serves a dual purpose — it aligns human teams AND feeds AI tools with accurate context for better output. Good structure across all projects means good context, which means better AI results and faster iteration.

Dual Boot is a consulting company with multiple teams working on client projects across different tech stacks. The framework must be replicable across projects, adoptable by teams of varying sizes, and practical enough to survive contact with real delivery pressure.

---

## Decision 1: Six Layers, Not Fewer

**Decision:** The framework has six layers: Business (0), Product (1), Design (2), Architecture (3), Implementation (4), Operations (5).

**Alternatives considered:**

- **Two layers** (product + technical) — Rafael's initial framing. Too coarse. "Technical" conflates architecture decisions with implementation details and operational concerns, which have different owners, audiences, and change velocities.
- **Three layers** (product, architecture, implementation) — misses the operational layer entirely and collapses business context into product.
- **Four layers** (product, architecture, implementation, operations) — workable, but loses the distinction between business context and product definition, and between design and architecture.

**Why six:** Each layer has a distinct owner, audience, change velocity, and purpose. Collapsing layers forces one person to own things with different lifecycles, or one document to serve audiences with different needs. The layers map to real roles at Dual Boot (PM, Designer, Tech Lead, Dev Team, DevOps) and real phases of work.

---

## Decision 2: Business as a Separate Layer (Layer 0)

**Decision:** Business understanding is its own layer above Product, not part of it.

**Alternatives considered:**

- **Business as part of Product** — simpler, fewer layers. The PM handles both anyway. But business context gets buried inside product docs, and the "why the client cares" gets lost in the "what we're building."
- **Business as a "context envelope"** — not a layer in the pipeline but ambient context referenced by all layers. Elegant in theory but hard to operationalize. Without clear ownership and status tracking, it rots.

**Why separate:** Business context is stable and product-agnostic. A client's market, goals, and constraints don't change when you build a new feature. It has a different lifecycle (created once per engagement, updated rarely) and different scope (per client relationship, not per project). Separating it avoids duplicating business context across multiple product-level docs (DRY) and makes it explicit that you always need to understand the business before defining any product work. For a consulting company, this maps to a real phase: onboarding to a client before executing projects.

---

## Decision 3: Design as an Optional Layer

**Decision:** Design (Layer 2) exists as a full layer but is marked N/A for projects without a UI or dedicated designer.

**Why:** Not every project has a design component — API-only projects, data pipelines, backend systems. Forcing a Design layer on these projects adds empty ceremony. But when design does apply, it's a distinct discipline with its own owner (designer), artifacts (specs, prototypes, component libraries), and downstream consumers (architecture and implementation). Collapsing it into Product or Architecture loses the specificity.

---

## Decision 4: QA as Cross-Cutting, Not a Layer

**Decision:** QA contributes to every layer but owns none. No dedicated QA layer.

**Alternatives considered:**

- **QA as its own layer** — would contain test strategy, test cases, quality metrics. But QA's value is distributed: acceptance criteria at the product level, accessibility at design, test strategy at architecture, test cases at implementation, health checks at operations. A single QA layer would either duplicate information from other layers or become a disconnected artifact.

**Why cross-cutting:** QA's accountability is ensuring quality gates exist at each layer. Their contributions are embedded where they matter — in the layer they validate — rather than isolated in a document nobody reads in context.

---

## Decision 5: The Refinement Pipeline Pattern

**Decision:** Every layer follows the same three-stage pipeline: raw inputs → intermediate artifacts → final documents. The final documents of Layer N are explicit inputs to Layer N+1.

**Why:** This pattern emerged from observing how documentation actually gets created. You don't go from a client meeting directly to a PRD — you gather raw inputs, synthesize them (personas, gap analysis, decision logs), and then produce the canonical document. Making this explicit serves two purposes: it normalizes the process across layers (everyone follows the same pattern), and it clarifies that raw inputs are never the source of truth. Contradictions in raw inputs get resolved during synthesis — the resolution is what gets documented.

The cross-layer inheritance (Layer N final docs → Layer N+1 raw inputs) makes the dependency chain visible and traceable, which is the foundation for the cascade/update mechanism.

---

## Decision 6: Final Documents as the Source of Truth

**Decision:** Raw inputs (transcripts, interviews, client materials) inform the process but are never canonical. The final document at each layer is the authoritative reference.

**Why:** Raw inputs frequently contradict each other — one meeting says X, a client doc says Y. If raw inputs are treated as truth, there's no resolution mechanism. The synthesis step (raw → intermediate → final) is where judgment calls happen: gaps are identified, contradictions are resolved, and decisions are recorded. The final document reflects the resolved state. This also means the PM owns resolving ambiguity at the product level, the tech lead owns it at architecture, etc. — decision-making authority follows layer ownership.

---

## Decision 7: Docs-as-Code (Documentation Lives in the Repo)

**Decision:** All final documents live in the project repository as Markdown files with YAML frontmatter.

**Alternatives considered:**

- **Knowledge platform (Confluence, Notion, Google Docs)** — accessible to non-technical people, but disconnected from code. Can't run CI checks, can't automate drift detection, version control is weaker, and AI coding tools can't read docs stored in Notion.
- **Split system** — technical docs in repo, product/business docs in Notion. Cross-layer references break. Maintaining consistency across two systems is exactly the kind of thing that rots.
- **Repo + rendering layer** — Markdown in repo, rendered via GitBook/Docusaurus for non-technical access. Best of both worlds but adds a tool to maintain.

**Why docs-as-code:** Single source of truth. Full version history. PR-based review. CI automation (frontmatter updates, drift detection, index generation) is straightforward. AI coding tools can read docs directly from the repo. For the MVP, PMs can edit through GitHub's web UI. A rendering layer can be added later without changing the underlying structure.

---

## Decision 8: Custom GitHub Action for PR Checks

**Decision:** Build a custom, reusable GitHub Action for the PR documentation check rather than using a paid tool.

**Alternatives evaluated:**

- **Doctective** ($10-350/mo) — semantic code-to-doc mapping via AST parsing, companion PRs. GitHub only, no Slack, no periodic staleness. Code-level focus (functions, classes, APIs). Cost multiplies across projects.
- **DeepDocs** (~$25/seat/mo) — continuous sync on commits/PRs, opens PRs with updates. GitHub only, no Slack. Broader doc scope (guides, tutorials). Pricing inconsistencies across their own pages.
- **FluentDocs** ($0-35/mo) — git push triggered, WYSIWYG diff editor, cross-repo. Free tier with BYOK. Some plans "coming soon." No Slack.
- **DocSentry** — staleness detection, Slack/Teams notifications, ownership tracking. Not launched yet (waitlist). Doesn't do code-to-doc drift, only time-based freshness.
- **Claude Code + GitHub Actions** (MIT + ~$0.50-2/run) — most flexible, can handle multi-layer docs, customizable. Requires prompt maintenance.

**Why custom:** The MVP PR check is pattern matching and frontmatter parsing — it doesn't need AI or external services. A custom action reads `.doc-triggers.yml`, compares against the diff, reads `relates_to`, and posts comments. Zero ongoing cost, no vendor dependency, reusable across all projects. If smarter analysis is needed later, the action can be extended with AI on a per-project basis. The `.doc-triggers.yml` mapping file works with both.

The tool evaluation is documented here for reference if the decision needs revisiting.

---

## Decision 9: Advisory, Not Blocking

**Decision:** The PR check comments on PRs but does not block merges. The weekly digest notifies but does not enforce.

**Why:** Blocking merges on documentation would add friction that teams resist, especially under delivery pressure. Advisory checks surface the question — "is that intentional?" — which is enough to trigger awareness without becoming a gate that teams learn to circumvent. If advisory proves insufficient over time, enforcement can be added incrementally. Starting permissive and tightening is easier than starting strict and loosening.

---

## Decision 10: Weekly Slack Digest Over Real-Time Alerts

**Decision:** A weekly summary rather than per-event notifications for documentation health.

**Why:** Real-time alerts for every staleness signal or cascade mismatch would create noise that gets ignored. A weekly digest batches everything into one actionable message. It's infrequent enough to be read, specific enough to be acted on (tags owners, lists exact docs), and provides trend visibility (PR activity without doc updates). The weekly cadence also matches sprint rhythms for most teams.

---

## Decision 11: Merge Layers 4 and 5 into a Single Terminal Layer

**Decision:** The original six-layer framework (Layers 0–5) is collapsed to five layers (Layers 0–4). The original Layer 4 (Implementation) and Layer 5 (Operations) are merged into a single Layer 4: Implementation & Operations.

**Alternatives considered:**

- **Keep six layers** — preserves the conceptual distinction between building and running. But the distinction depends on different owners and audiences, which does not hold at Dual Boot's team sizes.
- **Operations as a standalone optional layer** — mark Layer 5 as N/A for projects that don't need it. This works structurally, but creates a "ghost layer" that exists only on paper for most projects, adding cognitive overhead to the framework without value.

**Why merge:**

Four criteria drive the decision:

1. **Same owner at Dual Boot's scale.** Teams of 3–15 engineers don't have dedicated ops engineers. The people writing the Development Guide are the same people writing runbooks and setting up monitoring. A layer boundary implies ownership separation that doesn't exist.

2. **Consulting context.** Many Dual Boot projects are handed off to the client before the system reaches operational maturity. Layer 5 would frequently be "not started" or "N/A" — adding a layer that is regularly absent weakens the framework's signal.

3. **Thin document set.** When the original Layer 5 documents were analyzed in Dual Boot's context — SLAs overlap with NFRs in Layer 3, incident response is org-level not project-level, monitoring config lives in tools not docs — only a monitoring and observability document and a deployment guide remained as genuinely project-specific artifacts. Both fit comfortably in a merged Layer 4.

4. **Lifecycle timing handled by document status.** The argument for separation was that implementation docs are written before production while ops docs are written after. But the framework already handles maturity differences through document status (not started → in progress → established). Layer boundaries are for different owners and audiences, not for different timing. A single Layer 4 with optional documents (Deployment Guide, Monitoring & Observability) captures the maturity difference without a separate layer.

**What changed:** Layer 5 is removed. Layer 4 is renamed to "Implementation & Operations." The Deployment Guide and Monitoring & Observability document are optional within Layer 4. The Development Guide remains mandatory. The `layer` frontmatter value `operations` is removed; `implementation` covers both.

---

## Existing Write-Docs Skill Assessment

The existing `write-docs` skill (at `~/.cursor/skills/write-docs/SKILL.md`) was reviewed during this process. It generates technical documentation from an existing codebase through a 4-phase workflow: scan, discover interactively, generate in parallel, self-review.

**What it covers well:**

- Layers 3-4 (Architecture and Implementation) — architecture.md, flows.md, ADRs, development.md, environment.md, deployment.md, glossary.md
- Depth tiers (Lean/Standard/Comprehensive) based on team size and onboarding frequency
- Interactive discovery phase to avoid inventing decisions
- Client-shareable vs. internal tagging

**What it doesn't cover:**

- Layers 0-2 (Business, Product, Design) — no PRD, product brief, or business-level documentation
- AI-consumable output (AGENTS.md or compressed context files)
- Glossary is Standard+ only — should arguably be in every tier given its value for onboarding and AI context
- Operational docs (Layer 5) — runbooks, monitoring, incident response

**Decision:** Set aside for now. The skill may need restructuring to align with the full framework, but that work depends on finalizing document templates and the bootstrapping approach. It could become the implementation tool for Layers 3-4 within the broader framework.

---

## Research Context

The following industry trends and methodologies informed the framework design. Captured here so future sessions don't need to re-research.

**Specification-Driven Development (SDD):** A methodology where structured specs precede implementation and serve as the source of truth for AI-assisted code generation. Rests on four pillars — Traceability, DRY, Deterministic Enforcement, Parsimony. Relevant because the framework's layered docs serve a similar role: structured context that AI consumes. (Source: Alex Rezvov, ForEach Partners)

**Context Engineering:** The discipline of managing what information AI models access during development. SDD and context engineering are described as "two halves of the same solution" — specs define what context matters, context engineering makes specs actionable. The framework's cross-layer inheritance is essentially a context engineering structure. (Source: WeBuild-AI)

**Coherence-Driven Development (CoDD):** Addresses maintaining design coherence when requirements change mid-development. Uses structured design documents with dependency graphs rather than single monolithic context files. Extends beyond prompt engineering to "Harness Engineering" — constraining AI with rules, hooks, and guardrails. (Source: dev.to)

**Structured MADR:** Machine-readable ADRs using YAML frontmatter. Enables programmatic querying, automated compliance tracking, and AI context injection. Influenced the decision to use YAML frontmatter on all final documents, not just ADRs. (Source: zircote.com)

**AI Agent Config Files:** AGENTS.md has emerged as the cross-tool standard for AI coding agent context (supported by Codex, Copilot, Cursor, Windsurf, Amp, Devin). These files are compressed derivatives of architectural and implementation knowledge. The framework positions the AI agent config as a future distillation of Layers 3-4, not a standalone artifact. (Source: multiple, Linux Foundation Agentic AI Foundation)

**Docs-as-Code (2026):** Now the default approach — documentation in the same repo as code, same version control, same CI/CD. Automated drift detection tools are emerging (Drift, DocDrift, DeepDocs, Doctective, FluentDocs). None handle multi-layer documentation or cross-layer cascade — they all focus on code-to-docs sync. (Source: multiple)

**State of Docs 2026:** Documentation increasingly embedded in product development cycles through automated change detection, formal "definition of done" including docs, and testing automation. (Source: stateofdocs.com)