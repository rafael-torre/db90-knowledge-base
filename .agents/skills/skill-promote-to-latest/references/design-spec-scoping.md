# Layer 2 Design Spec Scoping

Loaded by `skill-promote-to-latest` step 1 when the target layer is Layer 2 (design).

- Layer 1 context is load-bearing when drafting or reviewing a Layer 2 design spec — not when implementing from it.
- Don't narrate upstream provenance in body prose — not the rationale ("read Layer 1 first," "this also builds on X for context") and not the mere fact that a `relates_to` link exists. Put the link in `relates_to` and say nothing about it in prose.
- Don't open the doc with a "this document covers X" scope recap restating what Figma and Layer 1 already establish. That's the folder-wide convention, already stated once in `features/README.md` — restating it per-doc is the same redundancy as narrating the Layer 1 link, and it drifts from reality the moment a claimed section is filled in or left as a placeholder (a doc that claims to cover accessibility requirements while its Accessibility section is still unfilled is actively wrong, not just redundant). The section headings already show what the doc covers — no preamble needed.
- Figma is the source of truth for final on-screen copy — headers, body/support text, button labels, messages. Link to the frame; don't transcribe the copy into the spec. A transcription is a second copy that drifts the moment Figma changes.
- "Content Specifications" covers content *rules* a static frame can't show (character limits, truncation, whether visible text is dynamic/co-created content vs. fixed design copy) — not the content itself. Omit the section if there are no such rules.
- Document what Figma, a static tool, cannot show: motion/animation timing and intent, non-obvious states (loading/error/empty/permission-based), interaction triggers and edge cases, accessibility requirements.
- If a fact is genuinely needed and only stated upstream (Layer 1 or Figma), that means it's missing from this spec — restate it as a concrete rule here instead of pointing at the source.
