# Step 1: Validate Prerequisites

**Input:** Source intermediate/ document path from user

**Actions:**
- Read source document frontmatter
- Identify layer from path (layers/layer-N-*/intermediate/...)
- Load Layer N-1 latest/ documents via relates_to or layer path
- Check: at least one Layer N-1 latest/ doc has status: consensus
- Check: source doc has been reviewed (look for review-findings.md alongside, or ask user)
- For Layer 3 feature technical specs: read the body (excluding frontmatter and the References section) and check for upstream citations — sentences that point back to an ADR or a Layer 1/Layer 2 spec instead of stating the fact directly. Each hit violates technical-spec-scoping.md unless the fact is genuinely missing from this spec (then write it in). Otherwise cut the citation — the fact should already be stated directly; `relates_to` and References already carry the link
- For Layer 2 design specs: read references/design-spec-scoping.md, then check the opening paragraph (before the first section heading) for two anti-patterns: narrating the Layer 1 `relates_to` link instead of just linking it, and a "this document covers X" scope recap that restates the folder-wide convention already in features/README.md (wrong the moment a claimed section is left unfilled, not just redundant). Also check any "## Content Specifications" section for transcribed on-screen copy (headers, button labels, messages) instead of a content rule. Each hit violates design-spec-scoping.md — cut the narration/recap, and either strip transcribed copy or fold any genuinely non-obvious fact into States and Behavior instead

**Halt if:**
- Layer N-1 has no consensus docs → block with message: "Upstream layer N-1 must reach consensus before promoting Layer N documents"
- Source document has open blockers in review findings
- Layer 3 spec has an unresolved upstream citation from the grep check above
