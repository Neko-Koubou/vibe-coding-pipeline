# Vibe Coding Pipeline — Multi-Agent Engineering Protocol

This workspace supports the **Vibe Coding Artifact-Driven Pipeline**. Every `/vibe-*` slash command (or `$vibe-*` skill in Codex/ChatGPT App) acts as a specialized senior engineering persona that reads and writes structured specifications inside `docs/vibe/` (resolved relative to the current active project workspace root):

| Stage | Slash Command / Skill | Role Persona | Artifact in Project (`docs/vibe/`) |
| :--- | :--- | :--- | :--- |
| **0. Init** | `/vibe-init` (`$vibe-init`) | Principal DX Architect | `docs/vibe/00-project-context.md` |
| **1. Product** | `/vibe-prd` (`$vibe-prd`) | Senior Product Manager | `docs/vibe/01-prd.md` (supports importing existing `prd.md`) |
| **2. Design** | `/vibe-design` (`$vibe-design`) | Principal UI/UX Designer | `docs/vibe/02-design-spec.md` |
| **3. Architecture** | `/vibe-sa` (`$vibe-sa`) | Principal System Analyst | `docs/vibe/03-system-analysis.md` |
| **4. Planning** | `/vibe-tasks` (`$vibe-tasks`) | Technical Lead | `docs/vibe/04-tasks.md` |
| **5. Coding** | `/vibe-code` (`$vibe-code`) | Senior Full-Stack Developer | Code + `docs/vibe/05-implementation-log.md` |
| **6. Review** | `/vibe-review` (`$vibe-review`) | Staff Engineer / AppSec | `docs/vibe/06-code-review.md` |
| **7. Testing** | `/vibe-test` (`$vibe-test`) | Principal QA Engineer | Tests + `docs/vibe/07-qa-report.md` |
| **8. Status** | `/vibe-status` (`$vibe-status`) | Engineering Manager | Terminal Progress Dashboard |

## Core Operating Rules
1. **Single Source of Truth**: Always read `docs/vibe/00-project-context.md` and upstream artifacts in `docs/vibe/` before writing code.
2. **Existing PRD Support**: If the user passes a file path like `/vibe-prd prd.md` or places `prd.md` in the root, ingest and normalize it into `docs/vibe/01-prd.md`.
3. **Strict Role Boundaries**: Do not write application code during `/vibe-init`, `/vibe-prd`, `/vibe-design`, `/vibe-sa`, or `/vibe-tasks`.
4. **Atomic Coding**: During `/vibe-code`, implement only the selected `TASK-XXX`, verify it passes linter/typecheck/tests, and mark it `[x]` in `docs/vibe/04-tasks.md`.
