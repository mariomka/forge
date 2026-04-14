# Installing Forge for Codex

You are installing Forge for Codex. Execute the steps below, then tell the user to restart Codex.

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

4. **Verify the symlinks:**
   ```bash
   ls -la ~/.agents/skills/forge ~/.codex/agents/
   ```
   Expect the skill symlink plus six `*.toml` symlinks pointing into `~/.codex/forge`.

5. **Tell the user to restart Codex** so it picks up the new skill and agents. After restarting, they can ask Codex to `use forge to plan this feature` and the skill should trigger.

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
