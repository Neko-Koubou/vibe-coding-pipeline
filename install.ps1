param(
    [ValidateSet("", "global", "project")]
    [string]$Scope = "",
    [string]$Agents = "",
    [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
python3 "$ScriptDir\install.py" $(if ($Scope -eq "global") { "--global" } elseif ($Scope -eq "project") { "--project" }) $(if ($Agents) { "--agents=$Agents" }) --target="$Target"
