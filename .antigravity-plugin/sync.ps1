<#
.SYNOPSIS
    Synchronizes upstream Forge definitions (agents/*.md and version) into
    Antigravity-native format (.antigravity-plugin/agents/*.md) and optionally
    links/installs the plugin into ~/.gemini/config/plugins/forge and sets up
    a Git post-merge hook so future `git pull` runs update Antigravity automatically.
#>
param(
    [switch]$SyncOnly
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$UpstreamAgentsDir = Join-Path $RepoRoot "agents"
$AgyPluginDir = $PSScriptRoot
$AgyAgentsDir = Join-Path $AgyPluginDir "agents"
$ClaudeManifest = Join-Path $RepoRoot ".claude-plugin\plugin.json"
$AgyManifest = Join-Path $AgyPluginDir "plugin.json"

New-Item -ItemType Directory -Force -Path $AgyAgentsDir | Out-Null

# 1. Sync version and description from upstream .claude-plugin/plugin.json
if ((Test-Path $ClaudeManifest) -and (Test-Path $AgyManifest)) {
    $upstreamJson = Get-Content $ClaudeManifest -Raw -Encoding UTF8 | ConvertFrom-Json
    $agyJson = Get-Content $AgyManifest -Raw -Encoding UTF8 | ConvertFrom-Json
    $changed = $false
    if ($upstreamJson.version -and $agyJson.version -ne $upstreamJson.version) {
        $agyJson.version = $upstreamJson.version
        $changed = $true
    }
    if ($upstreamJson.description -and $agyJson.description -ne $upstreamJson.description) {
        $agyJson.description = $upstreamJson.description
        $changed = $true
    }
    if ($changed) {
        $agyJson | ConvertTo-Json -Depth 5 | Set-Content -Path $AgyManifest -Encoding UTF8
    }
}

# 2. Map Claude Code tool names to Antigravity native tool names
function Convert-ToolsToAntigravity([string]$toolsLine) {
    $rawTools = $toolsLine -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    $mapped = [System.Collections.Generic.List[string]]::new()

    foreach ($t in $rawTools) {
        switch -Regex ($t) {
            '^(Read|Glob|Grep)$'       { if (-not $mapped.Contains('read_file'))   { $mapped.Add('read_file') } }
            '^Write$'                  { if (-not $mapped.Contains('write_file'))  { $mapped.Add('write_file') } }
            '^(Edit|MultiEdit)$'       { if (-not $mapped.Contains('edit_file'))   { $mapped.Add('edit_file') } }
            '^Bash$'                   {
                if (-not $mapped.Contains('run_command')) { $mapped.Add('run_command') }
                if (-not $mapped.Contains('manage_task')) { $mapped.Add('manage_task') }
            }
            '^(WebSearch|WebFetch)$'   { if (-not $mapped.Contains('search_web'))  { $mapped.Add('search_web') } }
        }
    }

    if ($mapped.Count -eq 0) {
        $mapped.AddRange([string[]]@('read_file', 'write_file', 'edit_file', 'run_command', 'manage_task', 'search_web'))
    }
    return "[" + ($mapped -join ", ") + "]"
}

# 3. Convert every upstream agent in agents/*.md into .antigravity-plugin/agents/*.md
$upstreamFiles = Get-ChildItem -Path $UpstreamAgentsDir -Filter "*.md"
$validNames = @{}

foreach ($file in $upstreamFiles) {
    $validNames[$file.Name] = $true
    $raw = Get-Content $file.FullName -Raw -Encoding UTF8

    if ($raw -match '(?s)^---\r?\n(.*?)\r?\n---\r?\n(.*)$') {
        $frontmatter = $Matches[1]
        $body = $Matches[2]

        $name = $file.BaseName
        $description = ""
        $toolsStr = ""

        foreach ($line in ($frontmatter -split "\r?\n")) {
            if ($line -match '^name:\s*(.+)$') {
                $name = $Matches[1].Trim()
            } elseif ($line -match '^description:\s*(.+)$') {
                $description = $Matches[1].Trim()
            } elseif ($line -match '^tools:\s*(.+)$') {
                $toolsStr = $Matches[1].Trim()
            }
        }

        $agyTools = Convert-ToolsToAntigravity $toolsStr

        $newContent = "---`nname: $name`ndescription: $description`nsubagent: true`nmainAgent: false`ntools: $agyTools`n---`n$body"
        $destPath = Join-Path $AgyAgentsDir $file.Name
        [System.IO.File]::WriteAllText($destPath, $newContent, (New-Object System.Text.UTF8Encoding($false)))
    }
}

# Remove any stale agents deleted upstream
Get-ChildItem -Path $AgyAgentsDir -Filter "*.md" | ForEach-Object {
    if (-not $validNames.ContainsKey($_.Name)) {
        Remove-Item $_.FullName -Force
    }
}

Write-Host "[Forge Antigravity] Synced $($upstreamFiles.Count) sub-agents from upstream agents/*.md"

if ($SyncOnly) {
    exit 0
}

# 4. Link into ~/.gemini/config/plugins/forge using directory junctions / hardlinks
$UserPluginsDir = Join-Path $HOME ".gemini\config\plugins"
$TargetPluginDir = Join-Path $UserPluginsDir "forge"

New-Item -ItemType Directory -Force -Path $TargetPluginDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $TargetPluginDir ".antigravity-plugin") | Out-Null

Copy-Item $AgyManifest (Join-Path $TargetPluginDir ".antigravity-plugin\plugin.json") -Force
Copy-Item (Join-Path $RepoRoot "README.md") (Join-Path $TargetPluginDir "README.md") -Force
if (Test-Path (Join-Path $RepoRoot "LICENSE")) {
    Copy-Item (Join-Path $RepoRoot "LICENSE") (Join-Path $TargetPluginDir "LICENSE") -Force
}

$junctions = @(
    @{ Link = (Join-Path $TargetPluginDir "skills"); Target = (Join-Path $RepoRoot "skills") },
    @{ Link = (Join-Path $TargetPluginDir "assets"); Target = (Join-Path $RepoRoot "assets") },
    @{ Link = (Join-Path $TargetPluginDir "agents"); Target = $AgyAgentsDir }
)

foreach ($j in $junctions) {
    if (Test-Path $j.Link) {
        $item = Get-Item $j.Link -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $item.Delete()
        } else {
            Remove-Item $j.Link -Recurse -Force
        }
    }
    New-Item -ItemType Junction -Path $j.Link -Target $j.Target | Out-Null
}

Write-Host "[Forge Antigravity] Linked plugin into $TargetPluginDir"

# 5. Install Git hooks (post-merge & post-rewrite) so `git pull` auto-updates Antigravity
$GitHooksDir = Join-Path $RepoRoot ".git\hooks"
if (Test-Path $GitHooksDir) {
    $hookScript = @"
#!/bin/sh
# Auto-sync Forge upstream changes to Antigravity plugin
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -ExecutionPolicy Bypass -File "`$(git rev-parse --show-toplevel)/.antigravity-plugin/sync.ps1"
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoProfile -ExecutionPolicy Bypass -File "`$(git rev-parse --show-toplevel)/.antigravity-plugin/sync.ps1"
elif [ -x "`$(git rev-parse --show-toplevel)/.antigravity-plugin/sync.sh" ]; then
  "`$(git rev-parse --show-toplevel)/.antigravity-plugin/sync.sh"
fi
"@
    foreach ($hookName in @("post-merge", "post-rewrite")) {
        $hookPath = Join-Path $GitHooksDir $hookName
        [System.IO.File]::WriteAllText($hookPath, ($hookScript -replace "`r`n", "`n"), (New-Object System.Text.UTF8Encoding($false)))
    }
    Write-Host "[Forge Antigravity] Installed Git post-merge & post-rewrite hooks for automatic upstream sync."
}
