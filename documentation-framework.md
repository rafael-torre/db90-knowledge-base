# Documentation Framework

A layered documentation structure for software products across the full development lifecycle. Designed to be replicable across projects, readable by both humans and AI systems, and maintainable as products evolve.

---

## Core Principles

### 1. Final Documents Are the Source of Truth

Raw inputs (transcripts, interviews, client materials) inform the process but are never canonical. Contradictions and ambiguities in raw inputs get resolved during synthesis. The resolution is what gets documented — the final document at each layer is the authoritative reference.

### 2. Each Layer Inherits From the Layers Above

The final documents of Layer N are explicit inputs to Layer N+1. This inheritance is not implicit — each layer's inputs section names the upstream documents it depends on. This creates a traceable chain from business context all the way down to operational runbooks.

### 3. Every Layer Follows the Same Refinement Pipeline

Regardless of the layer, documentation moves through three stages:


| Stage               | Description                                                                    |
| ------------------- | ------------------------------------------------------------------------------ |
| **Raw inputs**      | Gathered, not authored. Unstructured. Includes upstream layer final documents. |
| **Intermediate**    | Synthesized from raw inputs into structured artifacts. Living, iterative.      |
| **Final documents** | Canonical, reviewed, consumable. The source of truth for this layer.           |


### 4. Documentation State Is Per-Layer, Not Global

A project may have mature product docs but no operations docs yet. Each layer carries its own status independently. The framework does not require all layers to exist simultaneously.

---

## Layer Structure

### Layer 0: Business

**Purpose:** Understand the client, their market, their goals, and their constraints. This is the context that informs every downstream decision. Written in language anyone can understand.

**Owner:** PM / Engagement Lead

**Scope:** Per client or engagement — created once, updated rarely. A single Business layer can feed multiple Product layers over the life of a client relationship.


| Stage               | Artifacts                                                                                                                                                 |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Raw inputs**      | Client onboarding materials, stakeholder interviews, industry research, existing systems/products the client has, contracts/SOWs, initial discovery calls |
| **Intermediate**    | Open collection — meeting summaries, research syntheses, discovery notes, and other working documents produced during synthesis                           |
| **Final documents** | Business Overview, Strategic Goals and Constraints, Stakeholder Map, Competitive Landscape                                                                |


**Flows into:** Layer 1 (Product), and referenced by all downstream layers for business context.

**Detailed templates:** [layers/layer-0-business/](layers/layer-0-business/)

---

### Layer 1: Product

**Purpose:** Define the problem space, the users, and what we're building. This is where alignment happens and ambiguity gets resolved.

**Owner:** PM

**Contributors:** Designer, stakeholders, client


| Stage               | Artifacts                                                                                                                                                                                                    |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Raw inputs**      | **Layer 0 final documents**, meeting transcripts, client briefs, stakeholder interviews, chat threads, existing product docs, market research, competitor products                                           |
| **Intermediate**    | Personas, Problem Statement, Business Context, Competitive Landscape, Gap Analysis (unclear or contradictory information from raw inputs), Decision Log (resolutions of ambiguities with rationale and date) |
| **Final documents** | Product Brief, PRD, User Journeys, Success Metrics & KPIs, Domain Glossary                                                                                                                                   |


**Flows into:** Layer 2 (Design) and Layer 3 (Architecture).

---

### Layer 2: Design

**Purpose:** Define the user experience — what people interact with, how it behaves, how it feels.

**Owner:** Designer

**Contributors:** PM, QA (accessibility), engineers (feasibility)


| Stage               | Artifacts                                                                                                                                                               |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Raw inputs**      | **Layer 0 final documents**, **Layer 1 final documents** (PRD, personas, user journeys), user research sessions, usability tests, design critiques, reference materials |
| **Intermediate**    | Wireframes, Prototypes, Information Architecture, Interaction Patterns                                                                                                  |
| **Final documents** | Design Spec (screens, behavior, states), Design System / Component Library, Accessibility Requirements                                                                  |


**Flows into:** Layer 3 (Architecture) and Layer 4 (Implementation).

**When this layer does not apply:** API-only projects, data pipelines, backend systems, or projects without a dedicated designer. In those cases, mark as N/A — Layer 3 takes its inputs directly from Layers 0 and 1.

---

### Layer 3: Architecture

**Purpose:** Define the structural decisions — system boundaries, components, integrations, and the reasoning behind each choice.

**Owner:** Tech Lead

**Contributors:** DevOps, senior engineers, PM (constraints)


| Stage               | Artifacts                                                                                                                                                                                                                                                                                      |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Raw inputs**      | **Layer 0 final documents**, **Layer 1 final documents** (PRD, success metrics, domain glossary), **Layer 2 final documents** (design spec, component library — when applicable), tech spike results, PoC outcomes, vendor evaluations, existing system audits, client-provided technical docs |
| **Intermediate**    | C4 diagrams (context, container), Data models, API contracts, Integration maps, Decision Log (tech choices with rationale — raw material for ADRs)                                                                                                                                             |
| **Final documents** | Architecture Overview, ADRs, Key Flows (sequence diagrams), Non-functional Requirements, Tech Stack Rationale                                                                                                                                                                                  |


**Flows into:** Layer 4 (Implementation).

---

### Layer 4: Implementation & Operations

**Purpose:** Enable engineers to contribute effectively without tribal knowledge, and keep the system running once it is in production. The bridge between architectural decisions and working code — and the operational knowledge needed to deploy, monitor, and maintain the system.

**Owner:** Dev Team (engineers + Tech Lead)

**Contributors:** DevOps, QA (testing approach)


| Stage               | Artifacts                                                                                                                                                                                                                                |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Raw inputs**      | **Layer 3 final documents** (architecture overview, ADRs, feature technical specs, NFRs, tech stack rationale), **Layer 2 final documents** (design spec — when applicable), codebase, PR discussions, code review threads, retro notes |
| **Intermediate**    | Working drafts — open collection, no required artifacts                                                                                                                                                                                  |
| **Final documents** | Development Guide (mandatory), Deployment Guide (optional), Monitoring & Observability (optional)                                                                                                                                        |


**This is the terminal layer.**

**Detailed templates:** [layers/layer-4-implementation/](layers/layer-4-implementation/)

---

## Cross-Cutting Concerns

### Decision Tracking

Decisions happen at every layer. The format differs but the mechanism is the same: record what was decided, why, what alternatives were considered, and when. Decisions should be traceable backward to the information that drove them.


| Layer                      | Decision Format                                                |
| -------------------------- | -------------------------------------------------------------- |
| Business                   | Stakeholder alignment records, engagement-level decisions      |
| Product                    | Decision Log (tied to client conversations and gap resolution) |
| Design                     | Design rationale (why this pattern over alternatives)          |
| Architecture               | ADRs (formal, numbered, versioned)                             |
| Implementation & Operations | PR descriptions, code review resolutions, post-mortems        |


### Quality Assurance

QA contributes to every layer but owns none. Their accountability is ensuring quality gates exist at each layer.


| Layer                      | QA Contribution                                                          |
| -------------------------- | ------------------------------------------------------------------------ |
| Product                    | Acceptance criteria on stories/requirements                              |
| Design                     | Accessibility validation, usability heuristics                           |
| Architecture               | Test strategy, quality attributes definition                             |
| Implementation & Operations | Test cases, automation, coverage standards, smoke tests, health checks  |


---

## Project Documentation State

Each layer carries its own status. A simple maturity table gives a dashboard view of where a project's documentation stands.

### Layer States


| State            | Meaning                                                              |
| ---------------- | -------------------------------------------------------------------- |
| **N/A**          | This layer does not apply to this project                            |
| **Not started**  | Layer applies but no documentation exists yet                        |
| **In progress**  | Raw inputs gathered, synthesis underway, final docs not yet complete |
| **Established**  | Final documents exist and are current                                |
| **Needs update** | Final documents exist but are known to be outdated                   |


### Example Status Dashboard


| Layer                      | Status      | Owner          | Last Updated |
| -------------------------- | ----------- | -------------- | ------------ |
| Business                   | Established | PM name        | 2026-03-15   |
| Product                    | Established | PM name        | 2026-03-20   |
| Design                     | In progress | Designer name  | 2026-03-28   |
| Architecture               | Established | Tech Lead name | 2026-03-22   |
| Implementation & Operations | In progress | Team           | 2026-04-01   |


---

## Cascade and Update Mechanism

Defined in detail in [documentation-cascade-mechanism.md](documentation-cascade-mechanism.md). Summary of the approach:

**Document metadata:** Every final document carries YAML frontmatter (`title`, `layer`, `owner`, `last_updated`, `relates_to`, `status`) that enables automated tracking.

**Top-down changes** (business/product decisions cascading downstream) are handled through a change protocol: the person updating a document checks downstream dependencies and notifies affected owners. The weekly digest catches missed notifications.

**Bottom-up changes** (code changes making docs outdated) are handled through a PR check: a CI step scans changed files against a code-to-docs mapping (`.doc-triggers.yml`) and flags potentially affected documentation on the PR.

**Weekly Slack digest** reports documentation health per project — cascade signals, staleness, unresolved flags, and PR activity without doc updates.

**Documentation status dashboard** (`docs/index.md`) is auto-generated from frontmatter metadata, providing a single view of documentation health across all layers.