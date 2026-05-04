# Documentation Cascade & Update Mechanism

How documentation stays current as products evolve. This document defines how changes are detected, who is responsible for acting on them, and what processes keep documentation from drifting out of sync with reality.

This mechanism supports the layer structure defined in [documentation-framework.md](documentation-framework.md).

---

## Core Problem

Documentation drifts in two directions:

**Top-down:** A business or product decision changes, and downstream layers (architecture, implementation, operations) don't reflect it. This is a human-driven change — someone made a decision, and the ripple effect wasn't communicated or acted on.

**Bottom-up:** Code changes make technical documentation outdated. A developer refactors the auth flow, adds environment variables, or changes the deployment pipeline. The docs now describe something that no longer exists.

Both directions need different detection mechanisms but share the same resolution process.

---

## Document Metadata

Every final document carries YAML frontmatter. This metadata is the foundation — the PR check, the weekly digest, and the status dashboard all depend on it.

```yaml
---
title: Architecture Overview
layer: architecture
owner: "@techlead-handle"
last_updated: 2026-04-01
relates_to:
  - docs/product/prd.md
  - docs/product/domain-glossary.md
status: established
---
```

### Required Fields


| Field          | Type   | Description                                                                             |
| -------------- | ------ | --------------------------------------------------------------------------------------- |
| `title`        | string | Human-readable document title                                                           |
| `layer`        | string | One of: `business`, `product`, `design`, `architecture`, `implementation`               |
| `owner`        | string | GitHub handle or team identifier of the person accountable for this document            |
| `last_updated` | date   | Date of last substantive update (not formatting or typo fixes)                          |
| `relates_to`   | list   | Paths to related documents this document references or is connected to                  |
| `status`       | string | One of: `established`, `in_progress`, `needs_update`                                    |


### Rules

- `last_updated` reflects the last time the document's **content** was meaningfully reviewed or changed.
- `last_updated` is **auto-updated** by a CI step or pre-commit hook: when a PR modifies a file under `docs/`, the hook automatically sets `last_updated` to the current date in the frontmatter. This removes the dependency on people remembering to update it manually. The auto-update runs before the PR is merged, so the metadata is always accurate in the final commit.
- `relates_to` lists only **final documents**, not raw inputs or intermediate artifacts.
- `owner` is a single person, not a team. One person is accountable, even if multiple people contribute.

---

## Change Directions

### Top-Down Changes (Business/Product → Downstream)

These originate from human decisions — a client changes direction, a requirement is added or dropped, a design is revised. The person making the change knows it happened.

**Detection:** The document owner who makes the change is responsible for assessing downstream impact.

**Process:**

1. Owner updates the final document and its `last_updated` date.
2. Owner checks: which documents list this file in their `relates_to`?
3. For each affected related document, the owner notifies that document's owner (Slack message, GitHub issue, or a comment on the document) that a related document changed.
4. Downstream owner reviews their document and either:
  - Updates it (changes content + `last_updated`)
  - Confirms no change needed (updates `last_updated` to re-validate)
  - Marks it `needs_update` if they can't address it immediately

**When this fails:** The weekly digest catches documents where an upstream dependency has a more recent `last_updated` than the document itself.

### Bottom-Up Changes (Code → Technical Docs)

These originate from code changes — new features, refactors, config changes, infrastructure updates. The developer may not realize documentation is affected.

**Detection:** Automated. A CI check on every PR scans changed files against a code-to-docs mapping and flags potentially affected documentation.

**Process:**

1. Developer opens a PR with code changes.
2. CI check scans the changed files against the project's code-to-docs mapping.
3. If matches are found, the CI check adds a comment to the PR listing:
  - Which documentation files may be affected
  - What to check in each file (specific concern, not generic "update docs")
4. Developer reviews the flagged docs and either:
  - Updates them in the same PR
  - Opens a follow-up issue/PR for the doc update
  - Responds that no doc update is needed (creates a record)

**When this fails:** The weekly digest catches documents where related code has changed but `last_updated` hasn't moved.

---

## Code-to-Docs Mapping

Each project maintains a mapping file that connects code paths to related documentation. This is what the PR check uses to know which docs to flag.

### Location

The mapping lives in the project repository as `.doc-triggers.yml` (or equivalent configuration for whichever tool or workflow is used for the PR check).

### Structure

```yaml
mappings:
  - paths: ["src/auth/**", "src/middleware/auth*"]
    docs: ["docs/architecture/architecture-overview.md"]
    check: "Auth flow, token handling, session management"

  - paths: [".env*", "src/config/**", "config/**"]
    docs: ["docs/implementation/environment.md"]
    check: "Environment variables, config keys, default values"

  - paths: [".github/workflows/**", "Dockerfile*", "docker-compose*"]
    docs: ["docs/implementation/deployment.md"]
    check: "CI/CD pipeline stages, deployment process, environments"

  - paths: ["db/migrations/**", "src/models/**", "prisma/**"]
    docs: ["docs/architecture/architecture-overview.md", "docs/architecture/flows.md"]
    check: "Data models, entity relationships, key flows"

  - paths: ["src/routes/**", "src/controllers/**", "src/api/**"]
    docs: ["docs/architecture/architecture-overview.md", "docs/architecture/flows.md"]
    check: "API endpoints, request/response contracts, key flows"
```

### Maintenance

- The Tech Lead owns this file.
- It is updated when project structure changes (new modules, moved directories, new documentation files).
- It does not need to be exhaustive — it should cover the common, high-impact mappings. Rare edge cases are caught by the weekly digest or human judgment.

---

## PR Documentation Check

A CI step that runs on every pull request. Advisory, not blocking — except for the automatic `last_updated` update, which is a silent fix.

### Behavior

1. **Auto-update `last_updated`.** If the PR modifies any file under `docs/` that contains YAML frontmatter, automatically update the `last_updated` field to the current date. This is committed to the PR branch so the metadata is accurate when merged. No human action required.
2. **Scan the diff** against `.doc-triggers.yml`. If changed files match any mapping, comment on the PR with the affected docs and what to check.
3. **Check related documents.** If the PR modifies any file listed in another document's `relates_to`, comment with a list of related documents that may need review.
4. **Prompt when docs are untouched.** If the mapping triggered but no documentation files were modified in the PR, add a note: "This PR changes files related to [doc name]. No documentation was updated — is that intentional?"

### What It Does NOT Do

- Does not block merges.
- Does not auto-generate documentation changes.
- Does not replace human judgment — it surfaces the question, the developer answers it.

### Implementation

A custom, reusable GitHub Action owned by the organization. Built once, published internally, and added to any project.

The MVP PR check is pattern matching and frontmatter parsing — it does not require AI or external services. It reads `.doc-triggers.yml`, compares against the PR diff, reads `relates_to` from frontmatter, and posts comments. Zero ongoing cost, no vendor dependency, and fully customizable to the framework.

If smarter drift detection is needed later (e.g., semantic analysis of whether a code change actually contradicts what the docs say), the action can be extended with AI-assisted analysis (Claude Code + GitHub Actions or a dedicated tool) on a per-project basis. The `.doc-triggers.yml` mapping file works with both approaches.

---

## Weekly Documentation Digest

A scheduled job that runs once per week and posts a summary to the project's Slack channel. This catches everything the PR check misses — cascade drift, gradual staleness, and documents that were flagged but never addressed.

### What It Reports

**Cascade signals:** Documents where a related document (`relates_to` target) has a more recent `last_updated` than the document itself. This means something changed in a related document and this document hasn't been re-validated.

**Staleness signals:** Documents where `last_updated` is older than the layer's threshold AND there has been relevant activity since (code commits in mapped paths, upstream doc changes, or PRs that triggered the mapping). Time alone does not trigger staleness — a project in maintenance mode with no activity should not generate false alerts.

Default staleness thresholds by layer:


| Layer                      | Threshold | Trigger Condition                                                             |
| -------------------------- | --------- | ----------------------------------------------------------------------------- |
| Business                   | 180 days  | Time-based only (not tied to code activity — this layer is engagement-scoped) |
| Product                    | 90 days   | Time + development activity in the project                                    |
| Design                     | 60 days   | Time + development activity or upstream (product) doc changes                 |
| Architecture               | 90 days   | Time + code activity in mapped paths or upstream doc changes                  |
| Implementation & Operations | 30 days   | Time + code activity in mapped paths (covers dev, deployment, and monitoring docs) |


These are defaults. Each project can override them based on cadence — a project in active feature development might tighten implementation to 14 days, while a stable project might loosen everything.

**Unresolved flags:** Documents with `status: needs_update` that haven't been addressed.

**PR activity without doc updates:** Count of PRs in the past week that triggered the code-to-docs mapping but had no documentation changes.

### Example Message

```
📋 Documentation Health — Project X (Week of Apr 1)

⚠️ Cascade signals (upstream changed, downstream not re-validated):
  • docs/architecture/architecture-overview.md
    └─ Upstream docs/product/prd.md updated Apr 1 (this doc: Mar 22)
    └─ Owner: @techlead

⏰ Staleness:
  • docs/implementation/environment.md — last updated Feb 15 (48 days)
    └─ Owner: @dev-name

🔴 Needs update (unresolved):
  • docs/architecture/flows.md — flagged Mar 28
    └─ Owner: @techlead

📊 This week: 12 PRs merged, 3 triggered doc mapping alerts, 0 included doc updates
```

### Who Receives It

The message is posted to the **project team channel**. Individual owners are tagged on their specific items. The Tech Lead is tagged on the summary line if any items are unresolved for more than two consecutive weeks.

### Implementation

A scheduled GitHub Action (or equivalent cron job) that:

1. Reads YAML frontmatter from all files in `docs/`
2. Compares `last_updated` and `relates_to` relationships
3. Queries recent git activity for related code paths (using `.doc-triggers.yml` mappings)
4. Formats and posts to Slack via webhook

---

## Change Protocol

When documentation changes, follow this protocol. It applies regardless of which layer the change is in.

### When You Update a Final Document

1. Update the content.
2. Set `status` to `established` (if it was `needs_update` or `in_progress`). The `last_updated` date is handled automatically by the CI step — no need to set it manually.
3. Check: does any other document list this file in its `relates_to`?
  - If yes, notify that document's owner that a related document changed.
  - If the change is significant (scope change, removed sections, new constraints), open a GitHub issue tagging the downstream owners.
4. If the change was driven by an upstream change, reference it in the commit message or PR description.

### When the PR Check Flags Something

1. Review the flagged documentation.
2. If it needs updating — update it in the same PR, or open a follow-up PR/issue.
3. If it does not need updating — reply to the comment confirming no change is needed. This creates a record that the assessment was done.

### When the Weekly Digest Flags Something

1. Document owner reviews the flagged item.
2. If it needs updating — update it and close the loop.
3. If it's still current — update `last_updated` to today (re-validates freshness) and ensure `status` is `established`.
4. If it can't be addressed now — set `status: needs_update` (it will be flagged again next week until resolved).

---

## Documentation Status Dashboard

The project documentation index is auto-generated from frontmatter metadata. It lives at `docs/index.md` and provides a single view of documentation health.

### Generated From

All `.md` files under `docs/` that contain the required YAML frontmatter fields.

### Format

```markdown
# Documentation Status

Last generated: 2026-04-03

| Layer                      | Document              | Owner     | Status       | Last Updated | Cascade Alert          |
| -------------------------- | --------------------- | --------- | ------------ | ------------ | ---------------------- |
| Business                   | Client Overview       | @pm       | Established  | Mar 15       | —                      |
| Product                    | PRD                   | @pm       | Established  | Apr 1        | —                      |
| Design                     | Design Spec           | @designer | Established  | Mar 28       | —                      |
| Architecture               | Architecture Overview | @techlead | Needs update | Mar 22       | ⚠️ PRD updated Apr 1  |
| Implementation & Operations | Development Guide    | @team     | In progress  | Apr 1        | —                      |
| Implementation & Operations | Deployment Guide     | @dev      | Established  | Feb 15       | ⏰ 48 days             |
```

### Regeneration

The index is regenerated:

- On every PR that modifies files under `docs/` (as a CI step)
- On the weekly digest schedule (same job, before posting to Slack)

The index file itself is committed to the repo so it's always visible and browsable.

---

## What This Mechanism Does NOT Cover

These are explicitly out of scope for the MVP and may be addressed later:

- **Automated documentation generation or rewriting.** The mechanism detects drift and notifies — it does not auto-fix. AI-assisted doc update PRs are a future enhancement.
- **Traceability IDs across layers.** Lightweight `relates_to` paths are sufficient for now. Formal requirement IDs (e.g., FR-AUTH-001 traced from PRD to code) are a future consideration.
- **Blocking merges on stale documentation.** The PR check is advisory. Enforcement gates may be introduced later if advisory checks prove insufficient.
- **Non-repo documentation sync.** If documentation exists outside the repository (Confluence, Notion, Google Docs), this mechanism does not track it. All final documents are expected to live in the repo.
- **Cross-project cascade.** Layer 0 (Business) is scoped per engagement and may feed multiple projects. Cross-project cascade (one business doc affecting docs in multiple project repos) is not handled by this mechanism.

