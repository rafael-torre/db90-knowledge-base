# Step 2: Extract Requirements

**Actions:**
- Read the technical spec section by section:
  - Acceptance Criteria (product + technical) — becomes each ticket's definition of done
  - Business Rules and Constraints — becomes implementation constraints per ticket
  - Technical Approach — includes design/architectural constraints not phrased as Acceptance Criteria (e.g., "module X never receives parameter Y"); don't lose these just because they're not in the AC table
  - Data Model, API Contracts, Frontend Architecture, Integration Points — functional scope per surface
  - Technical Constraints and Risks — carry into ticket notes or spin out as spike tickets
  - Testing Approach — maps directly onto each ticket's acceptance criteria; don't re-derive test scope from scratch
- Load architecture overview: identify cross-cutting constraints (auth, observability, error handling, performance budgets)
- Identify natural ticket boundaries (by feature slice, layer, or component)
