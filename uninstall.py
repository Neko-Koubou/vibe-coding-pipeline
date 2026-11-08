#!/usr/bin/env python3
"""
Vibe Coding Pipeline — Universal Cross-Platform Uninstaller (2026 Edition)
Removes global /vibe-* commands, skills, workflows, and prompts across Windows, macOS, and Linux.
"""
import glob
import os
import platform
import shutil
from pathlib import Path


def detect_os_env():
    sys_name = platform.system().lower()
    home = Path.home()

    if sys_name == "windows":
        user_home = Path(os.environ.get("USERPROFILE", str(home)))
        appdata = Path(os.environ.get("APPDATA", str(user_home / "AppData" / "Roaming")))
        xdg_cfg = user_home / ".config"
    elif sys_name == "darwin":
        user_home = home
        appdata = home / "Library" / "Application Support"
        xdg_cfg = Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config")))
    else:
        user_home = home
        xdg_cfg = Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config")))
        appdata = xdg_cfg

    return {"home": user_home, "appdata": appdata, "xdg_cfg": xdg_cfg}


def remove_glob(pattern: str):
    for match in glob.glob(pattern):
        p = Path(match)
        try:
            if p.is_dir():
                shutil.rmtree(p, ignore_errors=True)
            elif p.is_file():
                p.unlink(missing_ok=True)
        except Exception:
            pass


def main():
    env = detect_os_env()
    h = env["home"]
    xdg = env["xdg_cfg"]
    appdata = env["appdata"]

    print("🗑️  Removing the global /vibe-* commands & skills...")

    # Claude Code
    remove_glob(str(h / ".claude" / "commands" / "vibe-*.md"))
    remove_glob(str(h / ".claude" / "skills" / "vibe-*"))

    # Antigravity (Config & Workflows)
    remove_glob(str(h / ".gemini" / "config" / "global_workflows" / "vibe-*.md"))
    remove_glob(str(h / ".gemini" / "config" / "workflows" / "vibe-*.md"))
    remove_glob(str(h / ".gemini" / "config" / "skills" / "vibe-*"))

    # Antigravity (Legacy incorrect paths cleanup)
    remove_glob(str(h / ".gemini" / "antigravity" / "global_workflows" / "vibe-*.md"))
    remove_glob(str(h / ".gemini" / "antigravity" / "skills" / "vibe-*"))
    remove_glob(str(h / ".agent" / "workflows" / "vibe-*.md"))
    remove_glob(str(h / ".agent" / "rules" / "vibe-pipeline.md"))
    remove_glob(str(h / ".agents" / "skills" / "vibe-*"))

    # OpenCode
    remove_glob(str(xdg / "opencode" / "command" / "vibe-*.md"))
    remove_glob(str(xdg / "opencode" / "commands" / "vibe-*.md"))
    remove_glob(str(xdg / "opencode" / "skills" / "vibe-*"))
    remove_glob(str(appdata / "opencode" / "command" / "vibe-*.md"))
    remove_glob(str(appdata / "opencode" / "commands" / "vibe-*.md"))
    remove_glob(str(appdata / "opencode" / "skills" / "vibe-*"))

    # Codex CLI + ChatGPT App
    remove_glob(str(h / ".codex" / "prompts" / "vibe-*.md"))
    remove_glob(str(h / ".codex" / "skills" / "vibe-*"))

    # Cursor
    remove_glob(str(h / ".cursor" / "commands" / "vibe-*.md"))
    remove_glob(str(h / ".cursor" / "skills" / "vibe-*"))
    remove_glob(str(h / ".cursor" / "rules" / "vibe-pipeline.mdc"))

    # Windsurf
    remove_glob(str(h / ".codeium" / "windsurf" / "global_workflows" / "vibe-*.md"))
    remove_glob(str(h / ".windsurf" / "workflows" / "vibe-*.md"))

    # Roo Code
    remove_glob(str(h / ".roo" / "commands" / "vibe-*.md"))

    print("✅ Removed all global /vibe-* commands & skills.")


if __name__ == "__main__":
    main()
