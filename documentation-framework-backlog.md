# Documentation Framework — Backlog

Open items across all framework documents. Each item references the document it relates to.

---

## Definition

- Define document templates for each layer (section structure, level of detail) — [documentation-framework.md](documentation-framework.md)
  - Layer 0 (Business): **done** — [layers/layer-0-business/](layers/layer-0-business/)
  - Layer 1 (Product): **done** — [layers/layer-1-product/](layers/layer-1-product/)
  - Layer 2 (Design): **done** — [layers/layer-2-design/](layers/layer-2-design/)
  - Layer 3 (Architecture): **done** — [layers/layer-3-architecture/](layers/layer-3-architecture/)
  - Layer 4 (Implementation & Operations): **done** — [layers/layer-4-implementation/](layers/layer-4-implementation/)
- Define how projects in different starting states (greenfield vs. brownfield) enter the framework — [documentation-framework.md](documentation-framework.md)
- Define how AI tools consume and produce documentation at each layer — [documentation-framework.md](documentation-framework.md)
- Define the relationship between this framework and AI agent configuration files (AGENTS.md, .cursorrules) — [documentation-framework.md](documentation-framework.md)
- Define how `.doc-triggers.yml` is bootstrapped for new projects (must cover all layers, not just technical code paths) — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Build Layer 0 tools (AI skills, process guides) — [layers/layer-0-business/tools/](layers/layer-0-business/tools/)
- Build Layer 1 tools (AI skills, process guides) — [layers/layer-1-product/tools/](layers/layer-1-product/tools/)
- Build Layer 2 tools (AI skills, process guides) — [layers/layer-2-design/tools/](layers/layer-2-design/tools/)
- Build Layer 3 tools (AI skills, process guides) — [layers/layer-3-architecture/tools/](layers/layer-3-architecture/tools/)
- Build Layer 4 tools (AI skills, process guides) — [layers/layer-4-implementation/tools/](layers/layer-4-implementation/tools/)

## Build

- Build the custom GitHub Action (frontmatter auto-update, mapping check, dependency check) — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Build the weekly Slack digest script — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Build the documentation index generator script — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)

## Completed

- Define the layer structure (Layers 0–5), principles, and ownership — [documentation-framework.md](documentation-framework.md)
- Define the cascade/update mechanism in detail — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Define the specific tool or workflow for the PR documentation check → custom reusable GitHub Action — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Define staleness thresholds per layer — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Build the Companion System — [companion/](companion/)
  - Companion rule (`db90-companion.mdc`) — always-on, layer-aware guidance in Cursor
  - `scan-project-state` hook — runs on session start, generates `.cursor/session-state.md`
  - `update-metadata.sh` hook — auto-updates `last_updated` and cascades `needs_review` on file edit
  - `scan-project-state` skill — on-demand project health check
  - `session-handoff` skill — captures decisions and context when a session ends or drifts
  - `init.sh` setup script and `.companion.yaml.example` — [companion/init.sh](companion/init.sh)
  - `GETTING-STARTED.md` — [GETTING-STARTED.md](GETTING-STARTED.md)