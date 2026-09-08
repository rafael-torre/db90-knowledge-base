# Layer 3 Spec Scoping

- Layer 1/2 context and ADR rationale are load-bearing when drafting or reviewing a Layer 3 spec — not when implementing from it or generating tickets from it.
- Don't narrate upstream decision provenance in body prose — not the rationale ("read Layer 1 first," "this spec doesn't reopen ADR-X") and not the mere fact that a link exists ("this is linked above for traceability, no need to open it"). Put the link in `relates_to` / References and say nothing about it in prose; state the resolved technical fact directly wherever it's needed.
- If implementation genuinely depends on something only stated upstream, that means the fact is missing from this spec — carry it forward as a concrete rule/criterion instead of pointing at the upstream doc.
- Acceptance Criteria "technical" rows must be independently, observably testable at the integration/E2E level:
  - Not a restated unit test — the same engineer usually writes both, so it only proves the code matches itself.
  - Not a reworded business rule — put those in Business Rules and Constraints.
  - Not a design/architectural property with no observable pass/fail outcome (e.g., "module X never receives parameter Y") — put those in Technical Approach.
