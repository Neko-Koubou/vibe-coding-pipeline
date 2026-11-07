<!-- vibe-pipeline:start -->
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
4. **Atomic Coding**: During `/vibe-code`, implement only the selected `TASK-XXX` (resume a `[~]` task before selecting a new one), verify it passes linter/typecheck/tests, mark it `[x]` (or `[!]` if blocked) in `docs/vibe/04-tasks.md`, then stop.
5. **Compaction-Safe State**: Long sessions are compacted (summarized) automatically, and the active `/vibe-*` instructions can be summarized away or re-attached after the summary. Chat memory is not reliable; `docs/vibe/` is.
   - **Re-anchor after any compaction or resume**: before acting, re-read `docs/vibe/04-tasks.md` (a `- [~]` task is the active one), its checkpoint in `docs/vibe/05-implementation-log.md`, the artifact you were writing, and `git status`. If the active `vibe-*` skill/command instructions are no longer in your context, re-open that skill/command file and follow it again.
   - **Resume, never skip**: never start a new task while one is `[~]`, and never mark `[x]` without a passing Definition of Done check.
   - **Checkpoint to disk as you go**: task progress in `05-implementation-log.md`, review fixes in `06-code-review.md`, test coverage in `07-qa-report.md`, and `> **Status**: DRAFT` → `COMPLETE` on each stage artifact.

## Compact Instructions
When compacting or summarizing this conversation, always preserve: the active `/vibe-*` stage and its arguments, the active `TASK-XXX` and its status marker, files created or modified so far, the last verification command and its result, unresolved errors, and the exact next step.
<!-- vibe-pipeline:end -->
