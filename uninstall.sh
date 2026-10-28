#!/usr/bin/env bash
set -euo pipefail
USER_HOME="$HOME"
XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "🗑️  Menghapus global commands & skills /vibe-* dari direktori user..."
rm -f "$USER_HOME/.claude/commands/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.claude/skills/vibe-"* 2>/dev/null || true
rm -f "$USER_HOME/.gemini/antigravity/global_workflows/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.gemini/antigravity/skills/vibe-"* 2>/dev/null || true
rm -f "$USER_HOME/.agent/workflows/vibe-"*.md 2>/dev/null || true
rm -f "$XDG_CFG/opencode/command/vibe-"*.md "$XDG_CFG/opencode/commands/vibe-"*.md 2>/dev/null || true
rm -rf "$XDG_CFG/opencode/skills/vibe-"* 2>/dev/null || true
rm -f "$USER_HOME/.codex/prompts/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.codex/skills/vibe-"* "$USER_HOME/.agents/skills/vibe-"* 2>/dev/null || true
rm -f "$USER_HOME/.cursor/commands/vibe-"*.md 2>/dev/null || true
rm -rf "$USER_HOME/.cursor/skills/vibe-"* 2>/dev/null || true
rm -f "$USER_HOME/.codeium/windsurf/global_workflows/vibe-"*.md 2>/dev/null || true
rm -f "$USER_HOME/.roo/commands/vibe-"*.md 2>/dev/null || true
echo "✅ Semua global command & skill /vibe-* berhasil dihapus."
