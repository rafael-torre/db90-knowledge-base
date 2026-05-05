# Using the DB90 Companion

A 2-minute setup. Then it works in the background.

## 1. Install (once)

```bash
companion/init.sh
```

Restart Cursor after it completes.

## 2. Tell it who you are

Edit `.companion.yaml` (created by step 1):

```yaml
name: "Your Name"
role: tech-lead   # pm | designer | tech-lead | developer | engagement-lead
```

## 3. Work normally

Open any doc under `layers/`. The companion will:
- Show what needs your attention at session start
- Load upstream context when you open a doc
- Suggest the right skill when you start drafting

## Common commands

| When… | Say… |
|---|---|
| Creating a new intermediate doc (Layer 1–4) | "create an intermediate [feature spec / design spec / ADR] for X" |
| Promoting a doc to final | "create a final doc for X based on `intermediate/my-doc.md`" |
| Ending a long session | "run session-handoff" |
| Want a project health check | "scan project state" |

## Something broken?

See [companion/README.md](./companion/README.md#troubleshooting).
