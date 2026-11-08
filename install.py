#!/usr/bin/env python3
"""
Vibe Coding Pipeline — Universal Cross-Platform Installer (2026 Edition)
Supports Windows, macOS, Linux/WSL2 | Global vs Project | Multi-Select | Commands + Agent Skills (SKILL.md)
"""
import argparse
import os
import platform
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROMPTS_DIR = SCRIPT_DIR / "prompts"
SKILLS_DIR = SCRIPT_DIR / "skills"
RULES_DIR = SCRIPT_DIR / "rules"

# The rules block is wrapped in these markers so a re-install can replace it in place.
VIBE_BLOCK_START = "<!-- vibe-pipeline:start -->"
VIBE_BLOCK_END = "<!-- vibe-pipeline:end -->"
# Installs from before the markers existed: the block runs from this header through rule 4.
LEGACY_BLOCK_START = "# Vibe Coding Pipeline — Multi-Agent Engineering Protocol"
LEGACY_BLOCK_LAST_LINE = "4. **Atomic Coding**"
# Rule files that belong to the pipeline alone and can simply be overwritten.
DEDICATED_RULE_FILES = {"vibe-pipeline.md", "vibe-pipeline.mdc"}


def detect_os_env():
    sys_name = platform.system().lower()
    machine = platform.machine()
    home = Path.home()

    if sys_name == "windows":
        os_type = "windows"
        os_label = f"Windows ({platform.release()} {machine})"
        user_home = Path(os.environ.get("USERPROFILE", str(home)))
        appdata = Path(os.environ.get("APPDATA", str(user_home / "AppData" / "Roaming")))
        xdg_cfg = user_home / ".config"
    elif sys_name == "darwin":
        os_type = "macos"
        os_label = f"macOS ({platform.mac_ver()[0]} {machine})"
        user_home = home
        appdata = home / "Library" / "Application Support"
        xdg_cfg = Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config")))
    else:
        os_type = "linux"
        is_wsl = False
        try:
            if "microsoft" in Path("/proc/version").read_text().lower():
                is_wsl = True
        except Exception:
            pass
        os_label = f"Linux ({'WSL2 ' if is_wsl else ''}{machine})"
        user_home = home
        xdg_cfg = Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config")))
        appdata = xdg_cfg

    return {
        "os_type": os_type,
        "os_label": os_label,
        "home": user_home,
        "appdata": appdata,
        "xdg_cfg": xdg_cfg,
    }


def get_agent_specs(env, target_dir: Path):
    h = env["home"]
    appdata = env["appdata"]
    xdg = env["xdg_cfg"]
    is_win = env["os_type"] == "windows"

    return [
        {
            "key": "claude",
            "name": "Claude Code (CLI & IDE)",
            "global_cmd": [h / ".claude" / "commands"],
            "global_skills": [h / ".claude" / "skills"],
            "global_rules": [(RULES_DIR / "CLAUDE.md", h / ".claude" / "CLAUDE.md")],
            "project_cmd": [target_dir / ".claude" / "commands"],
            "project_skills": [target_dir / ".claude" / "skills"],
            "project_rules": [(RULES_DIR / "CLAUDE.md", target_dir / "CLAUDE.md")],
        },
        {
            "key": "antigravity",
            "name": "Google Antigravity (IDE & CLI)",
            "global_cmd": [
                h / ".gemini" / "config" / "global_workflows",
                h / ".gemini" / "config" / "workflows",
            ],
            "global_skills": [h / ".gemini" / "config" / "skills"],
            "global_rules": [
                (RULES_DIR / "AGENTS.md", h / ".gemini" / "GEMINI.md"),
                (RULES_DIR / "AGENTS.md", h / ".gemini" / "config" / "GEMINI.md"),
            ],
            "project_cmd": [
                target_dir / ".agents" / "workflows",
                target_dir / ".agent" / "workflows",
            ],
            "project_skills": [
                target_dir / ".agents" / "skills",
                target_dir / ".agent" / "skills",
            ],
            "project_rules": [
                (RULES_DIR / "AGENTS.md", target_dir / ".agents" / "rules" / "vibe-pipeline.md"),
                (RULES_DIR / "AGENTS.md", target_dir / ".agent" / "rules" / "vibe-pipeline.md"),
                (RULES_DIR / "AGENTS.md", target_dir / "AGENTS.md"),
            ],
        },
        {
            "key": "opencode",
            "name": "OpenCode (CLI / Desktop)",
            "global_cmd": (
                [
                    xdg / "opencode" / "command",
                    xdg / "opencode" / "commands",
                    appdata / "opencode" / "command",
                    appdata / "opencode" / "commands",
                ]
                if is_win
                else [xdg / "opencode" / "command", xdg / "opencode" / "commands"]
            ),
            "global_skills": [xdg / "opencode" / "skills"],
            "global_rules": [(RULES_DIR / "AGENTS.md", xdg / "opencode" / "AGENTS.md")],
            "project_cmd": [
                target_dir / ".opencode" / "command",
                target_dir / ".opencode" / "commands",
            ],
            "project_skills": [target_dir / ".opencode" / "skills"],
            "project_rules": [(RULES_DIR / "AGENTS.md", target_dir / "AGENTS.md")],
        },
        {
            "key": "codex",
            "name": "Codex CLI + ChatGPT App",
            "global_cmd": [h / ".codex" / "prompts"],
            "global_skills": [h / ".codex" / "skills"],
            "global_rules": [(RULES_DIR / "AGENTS.md", h / ".codex" / "AGENTS.md")],
            "project_cmd": [target_dir / ".codex" / "prompts"],
            "project_skills": [target_dir / ".codex" / "skills"],
            "project_rules": [(RULES_DIR / "AGENTS.md", target_dir / "AGENTS.md")],
        },
        {
            "key": "cursor",
            "name": "Cursor (AI IDE)",
            "global_cmd": [h / ".cursor" / "commands"],
            "global_skills": [h / ".cursor" / "skills"],
            "global_rules": [
                (RULES_DIR / "vibe-pipeline.mdc", h / ".cursor" / "rules" / "vibe-pipeline.mdc")
            ],
            "project_cmd": [target_dir / ".cursor" / "commands"],
            "project_skills": [target_dir / ".cursor" / "skills"],
            "project_rules": [
                (
                    RULES_DIR / "vibe-pipeline.mdc",
                    target_dir / ".cursor" / "rules" / "vibe-pipeline.mdc",
                )
            ],
        },
        {
            "key": "windsurf",
            "name": "Windsurf (Agentic IDE)",
            "global_cmd": [
                h / ".codeium" / "windsurf" / "global_workflows",
                h / ".windsurf" / "workflows",
            ],
            "global_skills": [],
            "global_rules": [
                (
                    RULES_DIR / "AGENTS.md",
                    h / ".codeium" / "windsurf" / "memories" / "global_rules.md",
                )
            ],
            "project_cmd": [target_dir / ".windsurf" / "workflows"],
            "project_skills": [],
            "project_rules": [
                (
                    RULES_DIR / "AGENTS.md",
                    target_dir / ".windsurf" / "rules" / "vibe-pipeline.md",
                )
            ],
        },
        {
            "key": "roocode",
            "name": "Roo Code / Cline",
            "global_cmd": [h / ".roo" / "commands"],
            "global_skills": [],
            "global_rules": [(RULES_DIR / "AGENTS.md", h / ".roo" / "rules" / "vibe-pipeline.md")],
            "project_cmd": [
                target_dir / ".roo" / "commands",
                target_dir / ".clinerules" / "workflows",
            ],
            "project_skills": [],
            "project_rules": [
                (RULES_DIR / "AGENTS.md", target_dir / ".roo" / "rules" / "vibe-pipeline.md")
            ],
        },
    ]


def copy_skills(dest_root: Path):
    dest_root.mkdir(parents=True, exist_ok=True)
    for skill_folder in SKILLS_DIR.iterdir():
        if skill_folder.is_dir():
            target_skill_dir = dest_root / skill_folder.name
            target_skill_dir.mkdir(parents=True, exist_ok=True)
            for item in skill_folder.iterdir():
                if item.is_file():
                    shutil.copy2(item, target_skill_dir / item.name)


def replace_rule_block(existing: str, block: str):
    """Swap a previously installed Vibe block for `block`; None if no complete block is found."""
    lines = existing.splitlines(keepends=True)
    for first, last in ((VIBE_BLOCK_START, VIBE_BLOCK_END), (LEGACY_BLOCK_START, LEGACY_BLOCK_LAST_LINE)):
        start = next((i for i, line in enumerate(lines) if line.startswith(first)), None)
        if start is None:
            continue
        end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith(last)), None)
        if end is None:
            continue
        trailing = "\n" if lines[end].endswith("\n") else ""
        return "".join(lines[:start]) + block.rstrip("\n") + trailing + "".join(lines[end + 1:])
    return None


def install_rule(src_rule: Path, dest_rule: Path):
    """Install the rules block, updating an older installed copy instead of skipping it."""
    dest_rule.parent.mkdir(parents=True, exist_ok=True)
    if dest_rule.name in DEDICATED_RULE_FILES or not dest_rule.exists():
        shutil.copy2(src_rule, dest_rule)
        return
    block = src_rule.read_text(encoding="utf-8")
    existing = dest_rule.read_text(encoding="utf-8", errors="surrogateescape")
    updated = replace_rule_block(existing, block)
    if updated is None:
        if "Vibe Coding Pipeline" in existing:
            print(f"⚠️  {dest_rule} has a modified Vibe Coding Pipeline block; update it manually from {src_rule}")
            return
        updated = (existing.rstrip("\n") + "\n\n" if existing.strip() else "") + block
    dest_rule.write_text(updated, encoding="utf-8", errors="surrogateescape")


def main():
    parser = argparse.ArgumentParser(description="Vibe Coding Pipeline Universal 2026 Installer")
    parser.add_argument("-g", "--global", dest="is_global", action="store_true", help="Install globally for current OS user")
    parser.add_argument("-p", "--project", dest="is_project", action="store_true", help="Install into a single project")
    parser.add_argument("-t", "--target", default=os.getcwd(), help="Target project directory")
    parser.add_argument("-a", "--agents", default="", help="Comma-separated agent list or 'all'")
    args = parser.parse_args()

    env = detect_os_env()
    print("=" * 72)
    print("   ⚡ VIBE CODING PIPELINE — UNIVERSAL INSTALLER (2026 EDITION)")
    print("=" * 72)
    print(f"   🖥️  Detected OS   : {env['os_label']}")
    print(f"   🏠 Home Directory: {env['home']}")
    print("-" * 72)

    scope = "global" if args.is_global else ("project" if args.is_project else "")
    target_dir = Path(args.target).resolve()

    if not scope:
        print("\nSTEP 1/2 — Choose the installation scope:")
        print(f"  [1] 🌍 GLOBAL (Recommended) — install once on {env['os_label']}, available in EVERY project")
        print("  [2] 📁 SINGLE PROJECT       — install into one project folder only")
        choice = input("\n👉 Choose scope [1 = Global, 2 = Project] (default: 1): ").strip().lower()
        if choice in ("", "1", "g", "global"):
            scope = "global"
        else:
            scope = "project"
            custom_t = input(f"📂 Project folder (ENTER for {target_dir}): ").strip()
            if custom_t:
                target_dir = Path(custom_t).expanduser().resolve()

    specs = get_agent_specs(env, target_dir)
    selected = [True, True, False, True, False, False, False]

    if args.agents:
        selected = [False] * len(specs)
        tokens = [t.strip().lower() for t in args.agents.replace(",", " ").split() if t.strip()]
        if "all" in tokens:
            selected = [True] * len(specs)
        else:
            for idx, sp in enumerate(specs):
                if sp["key"] in tokens or str(idx + 1) in tokens:
                    selected[idx] = True
    else:
        while True:
            print("\n" + "-" * 72)
            print(f"STEP 2/2 — Choose your AI agents (multi-select | scope: {scope.upper()}):")
            for idx, sp in enumerate(specs):
                mark = "[x]" if selected[idx] else "[ ]"
                preview = sp["global_cmd"][0] if scope == "global" else sp["project_cmd"][0]
                print(f"  {mark} {idx + 1}) {sp['name']:<28} -> {preview}")
            print("\n  • Type numbers to toggle (e.g. 1,2,4) | 'a' = all | 'n' = none")
            print("  • Press ENTER when you are done to start installing")
            ans = input("👉 Your choice: ").strip().lower()
            if ans in ("", "y", "d", "install"):
                if any(selected):
                    break
                print("⚠️  Select at least 1 agent!")
            elif ans in ("a", "all"):
                selected = [True] * len(specs)
            elif ans in ("n", "none"):
                selected = [False] * len(specs)
            else:
                for tok in ans.replace(",", " ").split():
                    if tok.isdigit() and 1 <= int(tok) <= len(specs):
                        i = int(tok) - 1
                        selected[i] = not selected[i]

    print("\n" + "=" * 72)
    prompt_files = list(PROMPTS_DIR.glob("*.md"))
    if scope == "project":
        (target_dir / "docs" / "vibe").mkdir(parents=True, exist_ok=True)

    for idx, sp in enumerate(specs):
        if not selected[idx]:
            continue
        cmd_dirs = sp["global_cmd"] if scope == "global" else sp["project_cmd"]
        skill_dirs = sp["global_skills"] if scope == "global" else sp["project_skills"]
        rule_pairs = sp["global_rules"] if scope == "global" else sp["project_rules"]

        for cdir in cmd_dirs:
            cdir.mkdir(parents=True, exist_ok=True)
            for pf in prompt_files:
                shutil.copy2(pf, cdir / pf.name)

        for sdir in skill_dirs:
            copy_skills(sdir)

        for src_rule, dest_rule in rule_pairs:
            install_rule(src_rule, dest_rule)

        print(f"✅ {sp['name']} ({scope.upper()}) -> {cmd_dirs[0]}")

    print("=" * 72)
    print("🎉 Installation complete! Use /vibe-init, /vibe-prd, /vibe-design, /vibe-sa, /vibe-tasks, /vibe-code, /vibe-review, /vibe-test, /vibe-status")


if __name__ == "__main__":
    main()
