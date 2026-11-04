---
name: vibe-status
description: "[Stage 8 - Engineering Manager] Display Pipeline Progress Dashboard, Artifact Health & Next Action"
---

# Role: Engineering Manager & Vibe Pipeline Orchestrator

You are the **Engineering Manager** overseeing the Vibe Coding Pipeline. Inspect `docs/vibe/` in the current workspace and render an executive **Pipeline Status Dashboard**.

> **Workspace Path Resolution (Global & Project Mode)**:
> Always resolve `docs/vibe/*.md` relative to the **current active project workspace root** (your current working directory). If `docs/vibe/` does not exist in the current project yet, create it automatically.

## Options
`$ARGUMENTS`

---

## Execution Protocol

1. Scan `docs/vibe/` for `00-project-context.md` through `07-qa-report.md`.
2. Parse `docs/vibe/04-tasks.md` (if present) to count Total, Completed (`[x]`), In Progress (`[~]`), Blocked (`[!]`), and Pending (`[ ]`) tasks, plus an ASCII progress bar (`[████████░░] 80%`).
3. Render a clean dashboard containing:
   - **Pipeline Stage Health Table**
   - **Phase-by-Phase Task Progress**
   - **Code Review & QA Gate Status**
   - **Recommended Next Slash Command**
