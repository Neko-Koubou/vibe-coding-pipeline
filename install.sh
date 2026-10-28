#!/usr/bin/env bash
# ==============================================================================
# ⚡ VIBE CODING PIPELINE — OS-AWARE INTERACTIVE INSTALLER (2026 EDITION)
# Supports:
#   - OS Detection (macOS, Linux, WSL2, Windows Git-Bash/MSYS2/Cygwin)
#   - Scope Selection: Global (all projects) vs Single Project
#   - Interactive Multi-Select Agent Picker
#   - Latest 2026 Agent Paths (Commands + Agent Skills SKILL.md + Rules)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
DIM="\033[2m"
RESET="\033[0m"

# 1. DETECT OS
OS_TYPE="unknown"
OS_LABEL="Unknown OS"

UNAME_S="$(uname -s 2>/dev/null || echo "Unknown")"
case "$UNAME_S" in
  Darwin*)
    OS_TYPE="macos"
    OS_LABEL="macOS ($(uname -m))"
    USER_HOME="$HOME"
    APPDATA_DIR="$HOME/Library/Application Support"
    XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
    ;;
  Linux*)
    OS_TYPE="linux"
    if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
      OS_LABEL="Linux (WSL2 / Windows Subsystem for Linux)"
    else
      OS_LABEL="Linux ($(uname -m))"
    fi
    USER_HOME="$HOME"
    APPDATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
    XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    OS_TYPE="windows"
    OS_LABEL="Windows (Git Bash / MSYS2)"
    USER_HOME="$(cygpath -u "${USERPROFILE:-$HOME}" 2>/dev/null || echo "$HOME")"
    APPDATA_DIR="$(cygpath -u "${APPDATA:-$USER_HOME/AppData/Roaming}" 2>/dev/null || echo "$USER_HOME/AppData/Roaming")"
    XDG_CFG="$USER_HOME/.config"
    ;;
  *)
    OS_TYPE="linux"
    OS_LABEL="$UNAME_S"
    USER_HOME="$HOME"
    APPDATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
    XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
    ;;
esac

# 2026 Global Paths per Agent
GLOBAL_CLAUDE_CMD="$USER_HOME/.claude/commands"
GLOBAL_CLAUDE_SKILLS="$USER_HOME/.claude/skills"
GLOBAL_CLAUDE_RULE="$USER_HOME/.claude/CLAUDE.md"

GLOBAL_ANTIGRAVITY_CMD="$USER_HOME/.gemini/antigravity/global_workflows"
GLOBAL_ANTIGRAVITY_SKILLS="$USER_HOME/.gemini/antigravity/skills"
GLOBAL_ANTIGRAVITY_RULE="$USER_HOME/.gemini/GEMINI.md"

GLOBAL_OPENCODE_CMD_SINGULAR="$XDG_CFG/opencode/command"
GLOBAL_OPENCODE_CMD_PLURAL="$XDG_CFG/opencode/commands"
GLOBAL_OPENCODE_SKILLS="$XDG_CFG/opencode/skills"
GLOBAL_OPENCODE_RULE="$XDG_CFG/opencode/AGENTS.md"

GLOBAL_CODEX_PROMPTS="$USER_HOME/.codex/prompts"
GLOBAL_CODEX_SKILLS="$USER_HOME/.codex/skills"
GLOBAL_AGENTS_SKILLS="$USER_HOME/.agents/skills"
GLOBAL_CODEX_RULE="$USER_HOME/.codex/AGENTS.md"

GLOBAL_CURSOR_CMD="$USER_HOME/.cursor/commands"
GLOBAL_CURSOR_SKILLS="$USER_HOME/.cursor/skills"
GLOBAL_CURSOR_RULE="$USER_HOME/.cursor/rules"

GLOBAL_WINDSURF_CMD="$USER_HOME/.codeium/windsurf/global_workflows"
GLOBAL_WINDSURF_RULE="$USER_HOME/.codeium/windsurf/memories"

GLOBAL_ROO_CMD="$USER_HOME/.roo/commands"
GLOBAL_ROO_RULE="$USER_HOME/.roo/rules"

SCOPE=""
TARGET_DIR="$(pwd)"
AGENTS_ARG=""

print_banner() {
  echo -e "${CYAN}${BOLD}"
  echo "======================================================================"
  echo "   ⚡ VIBE CODING PIPELINE — MULTI-AGENT INSTALLER (2026 EDITION)"
  echo "   Artifact-Driven SDLC: Init -> PRD -> Design -> SA -> Tasks -> QA"
  echo -e "======================================================================${RESET}"
  echo -e "   🖥️  Detected OS   : ${GREEN}${BOLD}${OS_LABEL}${RESET}"
  echo -e "   🏠 Home Directory: ${DIM}${USER_HOME}${RESET}"
  echo "----------------------------------------------------------------------"
}

usage() {
  print_banner
  echo ""
  echo "Usage: ./install.sh [OPTIONS]"
  echo "  -g, --global                Install GLOBALLY for current OS user (usable in all projects)"
  echo "  -p, --project [dir]         Install into a single project directory"
  echo "  -a, --agents <list>         Comma-separated: claude,antigravity,opencode,codex,cursor,windsurf,roocode,all"
  echo "  -t, --target <dir>          Target project path when using --project"
  echo "  -h, --help                  Show help"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global) SCOPE="global"; shift ;;
    -p|--project)
      SCOPE="project"
      if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then TARGET_DIR="$2"; shift 2; else shift; fi
      ;;
    -t|--target) TARGET_DIR="$2"; shift 2 ;;
    -a|--agent|--agents) AGENTS_ARG="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo -e "${RED}Unknown option: $1${RESET}"; usage; exit 1 ;;
  esac
done

if [[ -z "$SCOPE" ]]; then
  print_banner
  echo ""
  echo -e "${BOLD}LANGKAH 1/2 — Pilih Mode Instalasi (Installation Scope):${RESET}"
  echo -e "  ${GREEN}${BOLD}[1] 🌍 GLOBAL (Recommended)${RESET}"
  echo -e "      Install satu kali di level OS (${OS_LABEL})."
  echo -e "      Slash command ${CYAN}/vibe-*${RESET} & skill ${CYAN}\$vibe-*${RESET} langsung aktif di ${BOLD}SEMUA project${RESET}!"
  echo ""
  echo -e "  ${YELLOW}${BOLD}[2] 📁 SINGLE PROJECT${RESET}"
  echo -e "      Install hanya di dalam 1 folder project spesifik."
  echo ""
  read -rp "👉 Pilih mode [1 = Global, 2 = Project] (default: 1): " scope_choice
  scope_choice="${scope_choice:-1}"
  case "$scope_choice" in
    1|g|G|global) SCOPE="global" ;;
    2|p|P|project)
      SCOPE="project"
      read -rp "📂 Masukkan path folder project (ENTER untuk $TARGET_DIR): " input_dir
      [[ -n "${input_dir:-}" ]] && TARGET_DIR="$input_dir"
      ;;
    *) echo -e "${RED}Pilihan tidak valid.${RESET}"; exit 1 ;;
  esac
fi

AGENT_KEYS=("claude" "antigravity" "opencode" "codex" "cursor" "windsurf" "roocode")
AGENT_NAMES=(
  "Claude Code (CLI & IDE)         "
  "Antigravity (White Icon IDE/CLI)"
  "OpenCode (CLI / Desktop)        "
  "Codex CLI + ChatGPT App         "
  "Cursor (AI IDE)                 "
  "Windsurf (Agentic IDE)          "
  "Roo Code / Cline                "
)

get_agent_path_preview() {
  local idx="$1"
  if [[ "$SCOPE" == "global" ]]; then
    case "$idx" in
      0) echo "~/.claude/{commands,skills}" ;;
      1) echo "~/.gemini/antigravity/{global_workflows,skills}" ;;
      2) echo "~/.config/opencode/{command,skills}" ;;
      3) echo "~/.codex/{skills,prompts} + ~/.agents/skills" ;;
      4) echo "~/.cursor/{commands,skills,rules}" ;;
      5) echo "~/.codeium/windsurf/global_workflows" ;;
      6) echo "~/.roo/{commands,rules}" ;;
    esac
  else
    case "$idx" in
      0) echo ".claude/{commands,skills}" ;;
      1) echo ".agent/{workflows,skills,rules}" ;;
      2) echo ".opencode/{command,skills}" ;;
      3) echo ".codex/{skills,prompts} + .agents/skills" ;;
      4) echo ".cursor/{commands,skills,rules}" ;;
      5) echo ".windsurf/{workflows,rules}" ;;
      6) echo ".roo/{commands,rules}" ;;
    esac
  fi
}

SELECTED=(1 1 0 1 0 0 0)

if [[ -n "$AGENTS_ARG" ]]; then
  SELECTED=(0 0 0 0 0 0 0)
  IFS=', ' read -r -a parsed_agents <<< "$AGENTS_ARG"
  for item in "${parsed_agents[@]}"; do
    low="$(echo "$item" | tr '[:upper:]' '[:lower:]')"
    if [[ "$low" == "all" ]]; then SELECTED=(1 1 1 1 1 1 1); break; fi
    case "$low" in
      1|claude|claude-code)      SELECTED[0]=1 ;;
      2|antigravity|ag)          SELECTED[1]=1 ;;
      3|opencode)                SELECTED[2]=1 ;;
      4|codex|chatgpt)           SELECTED[3]=1 ;;
      5|cursor)                  SELECTED[4]=1 ;;
      6|windsurf)                SELECTED[5]=1 ;;
      7|roocode|roo|cline)       SELECTED[6]=1 ;;
    esac
  done
else
  while true; do
    echo ""
    echo "----------------------------------------------------------------------"
    echo -e "${BOLD}LANGKAH 2/2 — Pilih AI Agent (Multi-Select | Mode: ${GREEN}${SCOPE^^}${RESET}):"
    echo ""
    for i in "${!AGENT_KEYS[@]}"; do
      num=$((i + 1))
      path_prev="$(get_agent_path_preview "$i")"
      if [[ "${SELECTED[$i]}" -eq 1 ]]; then mark="${GREEN}${BOLD}[x]${RESET}"; else mark="[ ]"; fi
      echo -e "  $mark ${BOLD}${num})${RESET} ${AGENT_NAMES[$i]} ${DIM}-> ${path_prev}${RESET}"
    done
    echo ""
    echo -e "  • Ketik angka untuk toggle/centang (contoh: ${BOLD}1,2,4${RESET} atau ${BOLD}3 5${RESET}) | ${BOLD}a${RESET} = Semua | ${BOLD}n${RESET} = Reset"
    echo -e "  • Tekan ${GREEN}${BOLD}ENTER${RESET} jika selesai memilih untuk mulai install"
    read -rp "👉 Pilihan Anda: " user_input
    if [[ -z "${user_input// /}" || "$user_input" =~ ^[yYdD]$ ]]; then
      total_sel=0
      for s in "${SELECTED[@]}"; do total_sel=$((total_sel + s)); done
      if [[ "$total_sel" -eq 0 ]]; then echo -e "${RED}⚠️  Pilih minimal 1 agent!${RESET}"; continue; fi
      break
    elif [[ "$user_input" =~ ^[aA]$ || "$user_input" == "all" ]]; then
      SELECTED=(1 1 1 1 1 1 1)
    elif [[ "$user_input" =~ ^[nN]$ ]]; then
      SELECTED=(0 0 0 0 0 0 0)
    else
      clean_input="${user_input//,/ }"
      for token in $clean_input; do
        if [[ "$token" =~ ^[1-7]$ ]]; then
          idx=$((token - 1))
          SELECTED[$idx]=$((1 - SELECTED[$idx]))
        fi
      done
    fi
  done
fi

append_or_copy_rule() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]]; then
    if ! grep -q "Vibe Coding Pipeline" "$dest" 2>/dev/null; then
      echo "" >> "$dest"
      cat "$src" >> "$dest"
    fi
  else
    cp "$src" "$dest"
  fi
}

copy_skills_tree() {
  local dest_skills_dir="$1"
  mkdir -p "$dest_skills_dir"
  cp -R "$SCRIPT_DIR/skills/"* "$dest_skills_dir/"
}

echo ""
echo "======================================================================"

install_agent() {
  local key="$1"
  case "$key" in
    claude)
      if [[ "$SCOPE" == "global" ]]; then
        mkdir -p "$GLOBAL_CLAUDE_CMD"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_CLAUDE_CMD/"
        copy_skills_tree "$GLOBAL_CLAUDE_SKILLS"
        append_or_copy_rule "$SCRIPT_DIR/rules/CLAUDE.md" "$GLOBAL_CLAUDE_RULE"
        echo -e "✅ ${GREEN}Claude Code (Global)${RESET} -> $GLOBAL_CLAUDE_CMD & $GLOBAL_CLAUDE_SKILLS"
      else
        mkdir -p "$TARGET_DIR/.claude/commands"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.claude/commands/"
        copy_skills_tree "$TARGET_DIR/.claude/skills"
        append_or_copy_rule "$SCRIPT_DIR/rules/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        echo -e "✅ ${GREEN}Claude Code (Project)${RESET} -> $TARGET_DIR/.claude/{commands,skills}"
      fi
      ;;

    antigravity)
      if [[ "$SCOPE" == "global" ]]; then
        mkdir -p "$GLOBAL_ANTIGRAVITY_CMD" "$USER_HOME/.agent/workflows" "$USER_HOME/.agent/rules"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_ANTIGRAVITY_CMD/"
        cp "$SCRIPT_DIR/prompts/"*.md "$USER_HOME/.agent/workflows/"
        copy_skills_tree "$GLOBAL_ANTIGRAVITY_SKILLS"
        cp "$SCRIPT_DIR/rules/AGENTS.md" "$USER_HOME/.agent/rules/vibe-pipeline.md"
        append_or_copy_rule "$SCRIPT_DIR/rules/AGENTS.md" "$GLOBAL_ANTIGRAVITY_RULE"
        echo -e "✅ ${GREEN}Antigravity White-Icon IDE (Global)${RESET} -> $GLOBAL_ANTIGRAVITY_CMD & $GLOBAL_ANTIGRAVITY_SKILLS"
      else
        mkdir -p "$TARGET_DIR/.agent/workflows" "$TARGET_DIR/.agent/rules"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.agent/workflows/"
        copy_skills_tree "$TARGET_DIR/.agent/skills"
        cp "$SCRIPT_DIR/rules/AGENTS.md" "$TARGET_DIR/.agent/rules/vibe-pipeline.md"
        echo -e "✅ ${GREEN}Antigravity White-Icon IDE (Project)${RESET} -> $TARGET_DIR/.agent/{workflows,skills,rules}"
      fi
      ;;

    opencode)
      if [[ "$SCOPE" == "global" ]]; then
        mkdir -p "$GLOBAL_OPENCODE_CMD_SINGULAR" "$GLOBAL_OPENCODE_CMD_PLURAL"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_OPENCODE_CMD_SINGULAR/"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_OPENCODE_CMD_PLURAL/"
        copy_skills_tree "$GLOBAL_OPENCODE_SKILLS"
        append_or_copy_rule "$SCRIPT_DIR/rules/AGENTS.md" "$GLOBAL_OPENCODE_RULE"
        if [[ "$OS_TYPE" == "windows" ]]; then
          mkdir -p "$APPDATA_DIR/opencode/command" "$APPDATA_DIR/opencode/commands"
          cp "$SCRIPT_DIR/prompts/"*.md "$APPDATA_DIR/opencode/command/"
          cp "$SCRIPT_DIR/prompts/"*.md "$APPDATA_DIR/opencode/commands/"
        fi
        echo -e "✅ ${GREEN}OpenCode (Global)${RESET} -> $GLOBAL_OPENCODE_CMD_SINGULAR & $GLOBAL_OPENCODE_SKILLS"
      else
        mkdir -p "$TARGET_DIR/.opencode/command" "$TARGET_DIR/.opencode/commands"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.opencode/command/"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.opencode/commands/"
        copy_skills_tree "$TARGET_DIR/.opencode/skills"
        append_or_copy_rule "$SCRIPT_DIR/rules/AGENTS.md" "$TARGET_DIR/AGENTS.md"
        echo -e "✅ ${GREEN}OpenCode (Project)${RESET} -> $TARGET_DIR/.opencode/{command,skills}"
      fi
      ;;

    codex)
      if [[ "$SCOPE" == "global" ]]; then
        mkdir -p "$GLOBAL_CODEX_PROMPTS"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_CODEX_PROMPTS/"
        copy_skills_tree "$GLOBAL_CODEX_SKILLS"
        copy_skills_tree "$GLOBAL_AGENTS_SKILLS"
        append_or_copy_rule "$SCRIPT_DIR/rules/AGENTS.md" "$GLOBAL_CODEX_RULE"
        echo -e "✅ ${GREEN}Codex CLI + ChatGPT App (Global)${RESET} -> $GLOBAL_CODEX_SKILLS, $GLOBAL_AGENTS_SKILLS & $GLOBAL_CODEX_PROMPTS"
      else
        mkdir -p "$TARGET_DIR/.codex/prompts"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.codex/prompts/"
        copy_skills_tree "$TARGET_DIR/.codex/skills"
        copy_skills_tree "$TARGET_DIR/.agents/skills"
        append_or_copy_rule "$SCRIPT_DIR/rules/AGENTS.md" "$TARGET_DIR/AGENTS.md"
        echo -e "✅ ${GREEN}Codex CLI + ChatGPT App (Project)${RESET} -> $TARGET_DIR/{.codex,.agents}/skills & AGENTS.md"
      fi
      ;;

    cursor)
      if [[ "$SCOPE" == "global" ]]; then
        mkdir -p "$GLOBAL_CURSOR_CMD" "$GLOBAL_CURSOR_RULE"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_CURSOR_CMD/"
        copy_skills_tree "$GLOBAL_CURSOR_SKILLS"
        cp "$SCRIPT_DIR/rules/vibe-pipeline.mdc" "$GLOBAL_CURSOR_RULE/vibe-pipeline.mdc"
        echo -e "✅ ${GREEN}Cursor (Global)${RESET} -> $GLOBAL_CURSOR_CMD & $GLOBAL_CURSOR_SKILLS"
      else
        mkdir -p "$TARGET_DIR/.cursor/commands" "$TARGET_DIR/.cursor/rules"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.cursor/commands/"
        copy_skills_tree "$TARGET_DIR/.cursor/skills"
        cp "$SCRIPT_DIR/rules/vibe-pipeline.mdc" "$TARGET_DIR/.cursor/rules/vibe-pipeline.mdc"
        echo -e "✅ ${GREEN}Cursor (Project)${RESET} -> $TARGET_DIR/.cursor/{commands,skills,rules}"
      fi
      ;;

    windsurf)
      if [[ "$SCOPE" == "global" ]]; then
        mkdir -p "$GLOBAL_WINDSURF_CMD" "$USER_HOME/.windsurf/workflows" "$GLOBAL_WINDSURF_RULE"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_WINDSURF_CMD/"
        cp "$SCRIPT_DIR/prompts/"*.md "$USER_HOME/.windsurf/workflows/"
        append_or_copy_rule "$SCRIPT_DIR/rules/AGENTS.md" "$GLOBAL_WINDSURF_RULE/global_rules.md"
        echo -e "✅ ${GREEN}Windsurf (Global)${RESET} -> $GLOBAL_WINDSURF_CMD"
      else
        mkdir -p "$TARGET_DIR/.windsurf/workflows" "$TARGET_DIR/.windsurf/rules"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.windsurf/workflows/"
        cp "$SCRIPT_DIR/rules/AGENTS.md" "$TARGET_DIR/.windsurf/rules/vibe-pipeline.md"
        echo -e "✅ ${GREEN}Windsurf (Project)${RESET} -> $TARGET_DIR/.windsurf/workflows"
      fi
      ;;

    roocode)
      if [[ "$SCOPE" == "global" ]]; then
        mkdir -p "$GLOBAL_ROO_CMD" "$GLOBAL_ROO_RULE"
        cp "$SCRIPT_DIR/prompts/"*.md "$GLOBAL_ROO_CMD/"
        cp "$SCRIPT_DIR/rules/AGENTS.md" "$GLOBAL_ROO_RULE/vibe-pipeline.md"
        echo -e "✅ ${GREEN}Roo Code / Cline (Global)${RESET} -> $GLOBAL_ROO_CMD"
      else
        mkdir -p "$TARGET_DIR/.roo/commands" "$TARGET_DIR/.roo/rules" "$TARGET_DIR/.clinerules/workflows"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.roo/commands/"
        cp "$SCRIPT_DIR/prompts/"*.md "$TARGET_DIR/.clinerules/workflows/"
        cp "$SCRIPT_DIR/rules/AGENTS.md" "$TARGET_DIR/.roo/rules/vibe-pipeline.md"
        echo -e "✅ ${GREEN}Roo Code / Cline (Project)${RESET} -> $TARGET_DIR/.roo/commands & .clinerules/workflows"
      fi
      ;;
  esac
}

[[ "$SCOPE" == "project" ]] && mkdir -p "$TARGET_DIR/docs/vibe"

for i in "${!AGENT_KEYS[@]}"; do
  [[ "${SELECTED[$i]}" -eq 1 ]] && install_agent "${AGENT_KEYS[$i]}"
done

echo "======================================================================"
echo -e "🎉 ${GREEN}${BOLD}INSTALASI SELESAI!${RESET}"
echo -e "Gunakan ${CYAN}/vibe-init${RESET}, ${CYAN}/vibe-prd${RESET}, ${CYAN}/vibe-design${RESET}, ${CYAN}/vibe-sa${RESET}, ${CYAN}/vibe-tasks${RESET}, ${CYAN}/vibe-code${RESET}, ${CYAN}/vibe-review${RESET}, ${CYAN}/vibe-test${RESET}, ${CYAN}/vibe-status${RESET}"
echo -e "(Di ChatGPT App / Codex terbaru, Anda juga bisa memanggil skill dengan ${CYAN}\$vibe-prd${RESET}, ${CYAN}\$vibe-sa${RESET}, atau ${CYAN}/vibe-prd${RESET})."
echo "======================================================================"
