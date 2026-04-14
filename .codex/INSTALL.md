# Installing Forge for Codex

Enable the Forge skill in Codex via native skill discovery. Clone once, symlink, done.

## Prerequisites

- Git

## Installation

1. **Clone the forge repository:**
   ```bash
   git clone https://github.com/mariomka/forge.git ~/.codex/forge
   ```

2. **Symlink the skill and agents into `~/.agents/`:**
   ```bash
   mkdir -p ~/.agents/skills ~/.agents/agents
   ln -s ~/.codex/forge/skills/forge ~/.agents/skills/forge
   ln -s ~/.codex/forge/agents/strategist.md ~/.agents/agents/strategist.md
   ln -s ~/.codex/forge/agents/analyst.md    ~/.agents/agents/analyst.md
   ln -s ~/.codex/forge/agents/builder.md    ~/.agents/agents/builder.md
   ln -s ~/.codex/forge/agents/validator.md  ~/.agents/agents/validator.md
   ln -s ~/.codex/forge/agents/reviewer.md   ~/.agents/agents/reviewer.md
   ln -s ~/.codex/forge/agents/auditor.md    ~/.agents/agents/auditor.md
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\agents"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\forge" "$env:USERPROFILE\.codex\forge\skills\forge"
   foreach ($a in 'strategist','analyst','builder','validator','reviewer','auditor') {
     cmd /c mklink "$env:USERPROFILE\.agents\agents\$a.md" "$env:USERPROFILE\.codex\forge\agents\$a.md"
   }
   ```

3. **Restart Codex** so it picks up the new skill and agents.

## Verify

```bash
ls -la ~/.agents/skills/forge
```

You should see a symlink to the cloned `skills/forge` directory.

Start a session and ask Codex to `use forge to plan this feature` — the skill should trigger.

## Updating

```bash
cd ~/.codex/forge && git pull
```

Existing symlinks pick up changes automatically. After pulling, check that every skill and agent in the repo has a symlink — re-run step 2 to create any that are missing.

## Uninstalling

```bash
rm ~/.agents/skills/forge
rm ~/.agents/agents/{strategist,analyst,builder,validator,reviewer,auditor}.md
rm -rf ~/.codex/forge
```
