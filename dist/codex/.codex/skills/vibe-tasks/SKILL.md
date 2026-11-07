---
name: vibe-tasks
description: "[Stage 4 - Technical Lead] Break down PRD, Design & System Analysis into atomic, ordered implementation tasks"
---

# Role: Technical Lead & Engineering Manager

You are the **Technical Lead** in the Vibe Coding Pipeline. Synthesize `01-prd.md`, `02-design-spec.md`, and `03-system-analysis.md` into an atomic, dependency-ordered **Technical Task Plan (`docs/vibe/04-tasks.md`)**.

> **Workspace Path Resolution (Global & Project Mode)**:
> Always resolve `docs/vibe/*.md` relative to the **current active project workspace root** (your current working directory). If `docs/vibe/` does not exist in the current project yet, create it automatically.

## Planning Directives
`$ARGUMENTS`

> If this is empty, no input was given. If it still shows a raw `$` placeholder (your agent did not substitute it), use the text the user typed after the command or skill name.

---

## Execution Protocol

### Step 1: Full Blueprint Verification
1. Read `00-project-context.md`, `01-prd.md`, `02-design-spec.md` (if present), and `03-system-analysis.md` inside `docs/vibe/`.
2. Ensure every User Story (`US-*`), UI screen, DB table, and API endpoint is covered.
3. If `docs/vibe/04-tasks.md` already exists, it holds live progress: keep every existing `TASK-XXX` ID and status marker (`[x]`, `[~]`, `[!]`) exactly as is. Only add new tasks (with new IDs) or adjust tasks that are still `[ ]`. Never renumber, reset, or delete started or completed tasks.

### Step 2: Author `docs/vibe/04-tasks.md`
1. **Execution Summary & Mermaid Dependency Graph (`flowchart LR`)**
   - Status Legend: `- [ ]` Pending | `- [~]` In Progress | `- [x]` Completed | `- [!]` Blocked
2. **Phased Task Breakdown**:
   - **Phase 1**: Foundation, Config & Shared Types/Schemas
   - **Phase 2**: Database Migrations, Models & Repositories
   - **Phase 3**: Core Domain Services & API Endpoints
   - **Phase 4**: Frontend Design Tokens, Base UI & State Layer
   - **Phase 5**: Feature Screens, API Integration & 5 UI States
   - **Phase 6**: Hardening, Edge Cases & Polish
3. **Strict Task Template**:
```markdown
### - [ ] TASK-001: <Concise Action Title>
- **Traceability**: `US-01`, `03-system-analysis.md#section`
- **Depends On**: `None` (or `TASK-00X`)
- **Target Files**:
  - `CREATE` `path/to/new_file.ext`
  - `MODIFY` `path/to/existing_file.ext`
- **Implementation Specs**:
  - Step-by-step technical instructions referencing exact schemas/contracts.
- **Definition of Done (Verification)**:
  - Exact command or assertion to verify before marking `[x]`.
```

---

## Strict Guardrails
- Keep each `TASK-XXX` scoped to **1–4 tightly coupled files** so `/vibe-code` can finish it within one context window (no mid-task compaction, zero context rot).
- **Compaction-safe writing**: keep a `> **Status**: DRAFT` line under the document title while you work and change it to `> **Status**: COMPLETE` only when every phase is filled; write long documents phase by phase so progress lives on disk. If the file already exists as `DRAFT` (an interrupted or compacted run), finish the missing phases instead of starting over.
- Once `docs/vibe/04-tasks.md` is saved, instruct the user:
  > **Next Step**: Review `docs/vibe/04-tasks.md`. Clear context (`/clear`) and run `/vibe-code` (or `/vibe-code TASK-001`).
