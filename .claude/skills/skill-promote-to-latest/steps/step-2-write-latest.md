# Step 2: Write to Latest

**Input:** Validated source document, target latest/ path

**Actions:**
- Derive latest/ path: replace /intermediate/ with /latest/ in source path
- Ensure latest/ directory exists
- Copy document content; update frontmatter:
  - status: needs_review
  - last_updated: <today YYYY-MM-DD>
  - relates_to: populate with upstream layer latest/ doc paths
- Apply content conventions (below)
- If the source is a Layer 3 Feature Technical Spec and its Data Model section is non-empty, sync layers/layer-3-architecture/latest/data-model.md (see Data Model sync below)
- Write to latest/ path

**Content conventions:**
- Open Questions / unresolved-items tables: once a question is answered, remove the row — don't keep it marked "Resolved". The answer lives in the ADR or feature doc that resolved it, linked via `relates_to`, not as a table row.
- ADR-backed decisions: state the current fact plus a bare pointer, e.g. `PostgreSQL is the single source of truth ([ADR-0001](...))`. Don't restate the ADR's rationale, trade-offs, or alternatives in the overview's prose — that's what the ADR is for.

**Data Model sync** (Layer 3 Feature Technical Specs only): data-model.md is an index, not a mirror — never copy the spec's column table into it, and never restate relationships in prose.

**Output:** Promoted document at latest/ path;
