---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: []
session_topic: 'AI-powered monitoring and system quality for Vrtly — once telemetry data starts flowing'
session_goals: 'Generate ideas for AI features that help Vrtly understand what is happening with their screens at scale; start simple (no training data required), build toward more complex options'
selected_approach: 'hybrid-user-guided-with-ai-direction'
techniques_used: ['Cross-Pollination', 'Reversal Inversion', 'Assumption Reversal', 'Chaos Engineering']
ideas_generated: []
context_file: 'layers/layer-3-architecture/intermediate/project-context.md'
---

# Brainstorming Session Results

**Facilitator:** Rafael
**Date:** 2026-06-19

## Session Overview

**Topic:** AI-powered monitoring and system quality for Vrtly — once telemetry data starts flowing

**Goals:** Generate AI feature ideas that:
- Help Vrtly understand at scale what is happening with their screens
- Require no model training upfront — start with simpler approaches
- Progress from quick wins to more complex options
- Work with telemetry data that doesn't exist yet (so the first step is always: get the data)

### Context Guidance

- Vrtly has 25 documented blank screen scenarios, 0 currently logged
- ~2,000 practices, screens in waiting rooms, FireTV-based
- Platform spans 9 repos; state-service is a single point of failure
- Dualboot will initially own monitoring; goal is to hand off to the Vrtly team
- AI layer comes *after* the first telemetry push — data is the prerequisite

### Session Setup

Hybrid approach: user-guided technique selection with AI directional recommendations at each step. Techniques run: Cross-Pollination → Reversal Inversion → Assumption Reversal → Chaos Engineering.

---

## Idea Inventory

### Cross-Pollination

**[CP-1]: Healthy Device Fingerprint as a Telemetry Artifact**
_Concept:_ Before any AI monitoring is possible, the telemetry phase must produce a documented behavioral baseline for a healthy screen — heartbeat cadence, playlist fetch intervals, watchdog event frequency, WebSocket reconnect rate. The fingerprint is not a separate AI task; it is the first telemetry deliverable.
_Novelty:_ Most teams instrument failures first and define "normal" retroactively. This inverts that — instrument health first, derive anomaly detection from deviation. Without this baseline, AI monitoring has nothing to compare against.

**[CP-2]: Watchdog-as-Distress-Signal**
_Concept:_ The playback watchdog currently fires silently and is treated as a recovery mechanism. Reframe it: any watchdog trigger above a baseline frequency within a time window is a degradation signal, not a successful recovery. Log the rate, not just the event.
_Novelty:_ The same code that already exists becomes a health metric with zero additional instrumentation — just a counter and a threshold.

**[CP-3]: Absence-of-Expected-Contact Detection**
_Concept:_ The server tracks when each device last made a playlist fetch. If a device misses its expected poll window, an alert fires — no device-side reporting needed, no ML, no training data. The screen's silence is the signal.
_Novelty:_ Inverts the detection model from "device reports a problem" to "server notices the device stopped talking." Works on day one of telemetry, scales to 2,000+ practices with a simple per-device timestamp.

**[CP-4]: Composite Screen Health Score**
_Concept:_ Assign weighted point values to each degradation signal (watchdog rate, WebSocket drops, fetch errors, re-registration events, absence of contact). Sum them per device on a rolling window. A score above a threshold triggers an alert before the screen goes blank.
_Novelty:_ Combines multiple weak signals into a single actionable number. Eliminates false positives from noisy individual metrics. Fully tunable by the team with no ML required — weight values become institutional knowledge about which signals matter most.

**[CP-5]: Peer-Cohort Deviation Detection**
_Concept:_ Rather than comparing device metrics against absolute thresholds, compare each device against its cohort — devices in the same practice, region, or device type. Outliers within the cohort are flagged regardless of absolute values, making the system self-calibrating across diverse practice environments.
_Novelty:_ Requires zero historical data to start. The cohort provides the baseline from day one. Naturally adapts to environmental variation without manual threshold tuning per location.

---

### Reversal Inversion

**[RI-1]: False-Healthy Re-Registration**
_Concept:_ After a watchdog full-reload, the device re-registers successfully — the server sees a healthy session handshake. But if the playlist fetch fails immediately after, the screen is blank while all server-side signals look green.
_Novelty:_ Registration success and content delivery success are two different things. Monitoring only the first gives a false sense of health.

**[RI-2]: Playlist Confirmed Delivered, Never Played**
_Concept:_ An operator triggers a content update. The JMS message fires, the playlist regenerates, the WebSocket push lands, the device acknowledges. Server-side: success. Device-side: the content has a broken URL, an expired CloudFront signature, or a transcoding artifact — and the screen is blank. No one knows.
_Novelty:_ Delivery confirmation and playback confirmation are not the same signal. The system needs end-to-end verification: did the device actually start playing new content within an expected window after the push?

**[RI-3]: Memory Exhaustion — Device Running, Screen Dead**
_Concept:_ The html5core SPA runs continuously in a FireTV WebView. Over time, memory leaks accumulate. Eventually the WebView crashes or the OS kills the process. Server-side: nothing. The device may not even reconnect if it can't recover the page.
_Novelty:_ This is a device-side failure with zero server-side visibility. The only way to catch it is to have the player report its own memory usage as a telemetry metric — a leading indicator before the crash, not a signal after.

**[RI-4]: No Internet — Device Invisible**
_Concept:_ The device is physically on and showing the last rendered frame. The practice's network is down. From the server, this is indistinguishable from a device simply powered off. Pairing the absence signal with practice-level context — are multiple devices in the same practice all silent simultaneously? — fingerprints a network outage vs. a single device failure.
_Novelty:_ Absence detection alone can't distinguish "device off" from "device on, no network." Multi-device context within the same practice makes the difference.

---

### Assumption Reversal

**[AR-1]: AI-Driven Auto-Remediation from Known Playbook**
_Concept:_ The 25 documented blank screen scenarios already represent a remediation rulebook. An AI layer pattern-matches incoming telemetry signals to known scenarios and triggers a pre-approved automated response — force a device reload, trigger re-registration, or escalate to a human — without waiting for an engineer to read an alert.
_Novelty:_ Turns the audit deliverable itself into operational logic. The scenario catalogue stops being a document and becomes executable. Reduces mean-time-to-recovery for known failure types to near-zero.
_Phase:_ Later-stage. Requires telemetry data to be stable and trustworthy before automation is safe to run.

**[AR-2]: Daily LLM System Health Narrative**
_Concept:_ Each morning an LLM consumes the previous night's telemetry — playlist sweep coverage, device reconnect rates, watchdog frequency, absence-of-contact events — and produces a plain-language summary for the Vrtly team. Not a dashboard, not an alert: a proactive briefing that surfaces what needs attention before the day starts.
_Novelty:_ Eliminates dashboard fatigue for a team too small to monitor metrics continuously. The LLM's job is to surface what matters and ignore what doesn't — the same judgment call a senior engineer would make reading raw logs, but automatic.
_Phase:_ Implementable as soon as telemetry data is flowing. Low engineering effort.

---

### Chaos Engineering / QA

**[CE-1]: 25 Scenarios as QA Automation Test Suite**
_Concept:_ Deliberately trigger each of the 25 documented blank screen scenarios in a controlled environment and verify whether the monitoring system catches it. Each scenario becomes a named test case with an expected alert signature.
_Novelty:_ Turns the audit risk register into a living test suite. Monitoring is only trustworthy if it can be verified against known failures.
_Category:_ QA Automation — belongs in the QA section of the audit, not the AI layer.

**[CE-2]: Chaos-Generated Labeled Data for Future ML**
_Concept:_ Deliberately triggering known failure scenarios in staging generates telemetry data with known ground truth. This labeled data is the seed for a future anomaly detection model — the bridge from rule-based phase 1 to a trained model in phase 2 or 3.
_Novelty:_ Most teams trying to build ML monitoring have no labeled data because failures are rare and undocumented. Controlled chaos injection solves that. The audit's 25 scenarios become the training curriculum.
_Phase:_ Later-stage. Requires staging environment parity and telemetry infrastructure first.

---

### Descoped

**[DESCOPED]: External Screen Visibility for Practices/Brands**
_Reason:_ Expose monitoring data to clients only after internal tooling is mature and data quality is trusted. Premature external exposure creates accountability risk before the system can reliably back it up. Revisit as a phase 3+ product feature.

---

## Idea Organization

### By Theme

**Theme 1 — Baseline & Signal Definition** *(prerequisite for everything else)*
CP-1 · CP-2 · CP-3
These are not AI features — they are the data foundation without which no AI layer can function. Must be delivered as part of the first telemetry push.

**Theme 2 — Smart Detection without ML**
CP-4 · CP-5 · RI-1 · RI-2 · RI-4
Rule-based and statistical approaches that produce actionable signals without training data. Implementable in phase 1 or early phase 2.

**Theme 3 — Device-Side Instrumentation**
CP-2 · RI-3
Signals that require changes inside the html5core player to surface. Memory usage reporting is the key addition here.

**Theme 4 — AI-Powered Intelligence Layer**
AR-2 · AR-1
LLM-based features that consume clean telemetry data and produce human-readable intelligence. AR-2 (daily narrative) is near-term; AR-1 (auto-remediation) is later-stage.

**Theme 5 — Future ML Foundation**
CE-1 · CE-2
Infrastructure for a trained model layer. CE-1 belongs in QA; CE-2 is the data strategy for ML down the road.

---

### By Implementation Phase

| Phase | Ideas | Prerequisite |
|---|---|---|
| Phase 1 — alongside telemetry | CP-1, CP-2, CP-3 | None — define these as telemetry deliverables |
| Phase 2 — once telemetry is stable | CP-4, CP-5, RI-1, RI-2, RI-3, RI-4 | Clean telemetry data flowing |
| Phase 2 — LLM layer | AR-2 | Telemetry data + LLM API integration |
| Phase 3 — automation | AR-1 | Stable telemetry + validated detection accuracy |
| Phase 3+ — ML | CE-2 | Staging environment + labeled data collection |

---

## Session Summary

**Total ideas generated:** 11 (+ 1 descoped, + 1 recategorized to QA)
**Techniques used:** Cross-Pollination, Reversal Inversion, Assumption Reversal, Chaos Engineering
**Key insight:** The telemetry phase and the AI monitoring layer are not sequential — the healthy device fingerprint (CP-1) and the watchdog signal reframe (CP-2) should be designed as AI-monitoring prerequisites from day one of instrumentation, not retrofitted later.
**Strongest near-term ideas:** CP-3 (absence detection), CP-4 (composite health score), AR-2 (daily LLM narrative)
**Strongest later-stage ideas:** AR-1 (auto-remediation from known playbook), CE-2 (chaos-generated labeled data)
