# Installing Forge for Google Antigravity

You are installing Forge for Google Antigravity. Execute the steps below so the `forge` skill and all seven specialized sub-agents are registered as a native Antigravity plugin and automatically stay in sync with upstream updates.

## Prerequisites

- Git
- PowerShell (Windows) or Bash (macOS / Linux)

## Installation

### Windows (PowerShell)

1. **Clone the repository (if not already cloned):**
   ```powershell
   git clone https://github.com/mariomka/forge.git "$HOME\.gemini\forge-src"
   ```
   *(If you already cloned it to a custom directory such as `d:\mariomka-forge`, run the next step from that directory instead).*

2. **Run the Antigravity sync & link script:**
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\<path-to-repo>\.antigravity-plugin\sync.ps1
   ```
   This script:
   - Converts all upstream `agents/*.md` definitions into Antigravity-native sub-agent definitions in `.antigravity-plugin/agents/*.md` (mapping tool grants and adding `subagent: true`, `mainAgent: false`).
   - Creates the global Antigravity plugin at `~/.gemini/config/plugins/forge` with directory junctions pointing to `skills/`, `assets/`, and `.antigravity-plugin/agents/`.
   - Installs Git `post-merge` and `post-rewrite` hooks so every future `git pull` automatically propagates upstream changes to Antigravity.

### macOS / Linux (Bash)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mariomka/forge.git ~/.gemini/forge-src
   ```

2. **Run the Antigravity sync & link script:**
   ```bash
   chmod +x ~/.gemini/forge-src/.antigravity-plugin/sync.sh
   ~/.gemini/forge-src/.antigravity-plugin/sync.sh
   ```

## Updating from Upstream

Whenever the upstream repository (`mariomka/forge`) publishes changes to `SKILL.md`, `discovery.md`, or `agents/*.md`, simply pull:

```bash
cd <path-to-repo> && git pull
```

- Changes to `skills/forge/` and `assets/` take effect immediately via the directory junctions / symlinks.
- Changes to `agents/*.md` (or new agents added upstream) are automatically re-synced into Antigravity by the `post-merge` Git hook installed during setup.

## Uninstalling

### Windows (PowerShell)
```powershell
Remove-Item -Recurse -Force "$HOME\.gemini\config\plugins\forge"
```

### macOS / Linux (Bash)
```bash
rm -rf ~/.gemini/config/plugins/forge
```
