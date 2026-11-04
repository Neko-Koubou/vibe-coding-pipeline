# ==============================================================================
# ⚡ VIBE CODING PIPELINE — WINDOWS UNINSTALLER (POWERSHELL)
# Removes all global /vibe-* commands, skills, workflows, and prompts.
# ==============================================================================
[CmdletBinding()]
param()

$ErrorActionPreference = "SilentlyContinue"

Write-Host "🗑️  Menghapus global commands & skills /vibe-* untuk Windows..." -ForegroundColor Cyan

$UserHome = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
$AppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
$ConfigDir = Join-Path $UserHome ".config"

$pathsToDelete = @(
    # Claude
    (Join-Path $UserHome ".claude\commands\vibe-*.md"),
    (Join-Path $UserHome ".claude\skills\vibe-*"),

    # Antigravity (Config & Workflows)
    (Join-Path $UserHome ".gemini\config\global_workflows\vibe-*.md"),
    (Join-Path $UserHome ".gemini\config\workflows\vibe-*.md"),
    (Join-Path $UserHome ".gemini\config\skills\vibe-*"),

    # Antigravity (Legacy incorrect paths)
    (Join-Path $UserHome ".gemini\antigravity\global_workflows\vibe-*.md"),
    (Join-Path $UserHome ".gemini\antigravity\skills\vibe-*"),
    (Join-Path $UserHome ".agent\workflows\vibe-*.md"),
    (Join-Path $UserHome ".agent\rules\vibe-pipeline.md"),
    (Join-Path $UserHome ".agents\skills\vibe-*"),

    # OpenCode (.config & AppData)
    (Join-Path $ConfigDir "opencode\command\vibe-*.md"),
    (Join-Path $ConfigDir "opencode\commands\vibe-*.md"),
    (Join-Path $ConfigDir "opencode\skills\vibe-*"),
    (Join-Path $AppData "opencode\command\vibe-*.md"),
    (Join-Path $AppData "opencode\commands\vibe-*.md"),
    (Join-Path $AppData "opencode\skills\vibe-*"),

    # Codex CLI + ChatGPT App
    (Join-Path $UserHome ".codex\prompts\vibe-*.md"),
    (Join-Path $UserHome ".codex\skills\vibe-*"),

    # Cursor
    (Join-Path $UserHome ".cursor\commands\vibe-*.md"),
    (Join-Path $UserHome ".cursor\skills\vibe-*"),
    (Join-Path $UserHome ".cursor\rules\vibe-pipeline.mdc"),

    # Windsurf
    (Join-Path $UserHome ".codeium\windsurf\global_workflows\vibe-*.md"),
    (Join-Path $UserHome ".windsurf\workflows\vibe-*.md"),

    # Roo Code
    (Join-Path $UserHome ".roo\commands\vibe-*.md")
)

foreach ($pathPattern in $pathsToDelete) {
    if (Test-Path $pathPattern) {
        Remove-Item -Path $pathPattern -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "✅ Semua global command & skill /vibe-* berhasil dihapus." -ForegroundColor Green
