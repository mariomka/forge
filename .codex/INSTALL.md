# Installing Forge for Codex

Forge installs as a native Codex skill plus six native Codex sub-agents. Clone once, symlink, done.

## Prerequisites

- Git

## Installation

1. **Clone the forge repository:**
   ```bash
   git clone https://github.com/mariomka/forge.git ~/.codex/forge
   ```

2. **Symlink the skill into `~/.agents/skills/`:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -sfn ~/.codex/forge/skills/forge ~/.agents/skills/forge
   ```

3. **Symlink the sub-agents into `~/.codex/agents/`:**
   ```bash
   mkdir -p ~/.codex/agents
   for a in strategist analyst builder validator reviewer auditor; do
     ln -sfn ~/.codex/forge/.codex/agents/$a.toml ~/.codex/agents/$a.toml
   done
   ```

4. **Restart Codex** so it picks up the new skill and agents.

## Verify

```bash
ls -la ~/.agents/skills/forge ~/.codex/agents/
```

You should see the skill symlink and six `*.toml` symlinks pointing into the cloned repo. Start a session and ask Codex to `use forge to plan this feature` — the skill should trigger.

## Updating

```bash
cd ~/.codex/forge && git pull
```

Existing symlinks pick up changes automatically. If new agents were added upstream, re-run step 3 to create the missing symlinks.

## Uninstalling

```bash
rm ~/.agents/skills/forge
rm ~/.codex/agents/{strategist,analyst,builder,validator,reviewer,auditor}.toml
rm -rf ~/.codex/forge
```
