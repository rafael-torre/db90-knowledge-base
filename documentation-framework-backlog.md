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
  - Layer 5: removed — merged into Layer 4 (see Decision 11 in [documentation-framework-decisions.md](documentation-framework-decisions.md))
- Define how projects in different starting states (greenfield vs. brownfield) enter the framework — [documentation-framework.md](documentation-framework.md)
- Define how AI tools consume and produce documentation at each layer — [documentation-framework.md](documentation-framework.md)
- Define the relationship between this framework and AI agent configuration files (AGENTS.md, .cursorrules) — [documentation-framework.md](documentation-framework.md)
- Define how `.doc-triggers.yml` is bootstrapped for new projects (must cover all layers, not just technical code paths) — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Build Layer 0 tools (AI skills, process guides) — [layers/layer-0-business/tools/](layers/layer-0-business/tools/)

## Build

- Build the custom GitHub Action (frontmatter auto-update, mapping check, dependency check) — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Build the weekly Slack digest script — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Build the documentation index generator script — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)

## Completed

- Define the layer structure (Layers 0–5), principles, and ownership — [documentation-framework.md](documentation-framework.md)
- Define the cascade/update mechanism in detail — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Define the specific tool or workflow for the PR documentation check → custom reusable GitHub Action — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)
- Define staleness thresholds per layer — [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md)