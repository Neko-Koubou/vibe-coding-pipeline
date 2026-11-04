#!/usr/bin/env bash
# ==============================================================================
# ⚡ VIBE CODING PIPELINE — GLOBAL UNINSTALLER (BASH)
# Removes all global /vibe-* commands, skills, workflows, and prompts.
# ==============================================================================
set -euo pipefail

UNAME_S="$(uname -s 2>/dev/null || echo "Unknown")"
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*)
    USER_HOME="$(cygpath -u "${USERPROFILE:-$HOME}" 2>/dev/null || echo "$HOME")"
    APPDATA_DIR="$(cygpath -u "${APPDATA:-$USER_HOME/AppData/Roaming}" 2>/dev/null || echo "$USER_HOME/AppData/Roaming")"
    XDG_CFG="$USER_HOME/.config"
    ;;
  *)
    USER_HOME="$HOME"
    APPDATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
    XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
    ;;
esac

echo "🗑️  Menghapus global commands & skills /vibe-* dari direktori user..."

# Claude Code
rm -f "$USER_HOME/.claude/commands/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.claude/skills/vibe-"* 2>/dev/null || true

# Antigravity (Config & Workflows)
rm -f "$USER_HOME/.gemini/config/global_workflows/vibe-"*.md "$USER_HOME/.gemini/config/workflows/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.gemini/config/skills/vibe-"* 2>/dev/null || true

# Antigravity (Legacy incorrect paths cleanup)
rm -f "$USER_HOME/.gemini/antigravity/global_workflows/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.gemini/antigravity/skills/vibe-"* 2>/dev/null || true
rm -f "$USER_HOME/.agent/workflows/vibe-"*.md 2>/dev/null || true
rm -f "$USER_HOME/.agent/rules/vibe-pipeline.md" 2>/dev/null || true
rm -rf "$USER_HOME/.agents/skills/vibe-"* 2>/dev/null || true

# OpenCode (.config & AppData)
rm -f "$XDG_CFG/opencode/command/vibe-"*.md "$XDG_CFG/opencode/commands/vibe-"*.md 2>/dev/null || true
rm -rf "$XDG_CFG/opencode/skills/vibe-"* 2>/dev/null || true
rm -f "$APPDATA_DIR/opencode/command/vibe-"*.md "$APPDATA_DIR/opencode/commands/vibe-"*.md 2>/dev/null || true
rm -rf "$APPDATA_DIR/opencode/skills/vibe-"* 2>/dev/null || true

# Codex CLI + ChatGPT App
rm -f "$USER_HOME/.codex/prompts/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.codex/skills/vibe-"* 2>/dev/null || true

# Cursor
rm -f "$USER_HOME/.cursor/commands/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.cursor/skills/vibe-"* 2>/dev/null || true
rm -f "$USER_HOME/.cursor/rules/vibe-pipeline.mdc" 2>/dev/null || true

# Windsurf
rm -f "$USER_HOME/.codeium/windsurf/global_workflows/vibe-"*.md 2>/dev/null || true
rm -f "$USER_HOME/.windsurf/workflows/vibe-"*.md 2>/dev/null || true

# Roo Code
rm -f "$USER_HOME/.roo/commands/vibe-"*.md 2>/dev/null || true

echo "✅ Semua global command & skill /vibe-* berhasil dihapus."
