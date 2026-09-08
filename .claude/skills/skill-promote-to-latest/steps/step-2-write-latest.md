# Step 2: Write to Latest

**Input:** Validated source document, target latest/ path

**Actions:**
- Derive latest/ path: replace /intermediate/ with /latest/ in source path
- Ensure latest/ directory exists
- Copy document content; update frontmatter:
  - status: needs_review
  - last_updated: <today YYYY-MM-DD>
  - relates_to: populate with upstream layer latest/ doc paths
- Write to latest/ path

**Output:** Promoted document at latest/ path
