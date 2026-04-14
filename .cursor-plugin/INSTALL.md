# Installing Forge for Cursor

You are installing Forge for Cursor. Execute the steps below, then tell the user to restart Cursor.

## Prerequisites

- Git

## Installation

1. **Clone the forge repository:**
   ```bash
   git clone https://github.com/mariomka/forge.git ~/.cursor/forge
   ```

2. **Symlink the skill into `~/.cursor/skills/`:**
   ```bash
   mkdir -p ~/.cursor/skills
   ln -sfn ~/.cursor/forge/skills/forge ~/.cursor/skills/forge
   ```

3. **Symlink the sub-agents into `~/.cursor/agents/`:**
   ```bash
   mkdir -p ~/.cursor/agents
   for a in strategist analyst builder validator reviewer auditor; do
     ln -sfn ~/.cursor/forge/agents/$a.md ~/.cursor/agents/$a.md
   done
   ```

4. **Verify the symlinks:**
   ```bash
   ls -la ~/.cursor/skills/forge ~/.cursor/agents/
   ```
   Expect the skill symlink plus six `*.md` symlinks pointing into `~/.cursor/forge`.

5. **Tell the user to restart Cursor** so it picks up the new skill and agents. After restarting, they can ask Cursor to `use forge to plan this feature` and the skill should trigger.

## Updating

```bash
cd ~/.cursor/forge && git pull
```

Existing symlinks pick up changes automatically. If new agents were added upstream, re-run step 3 to create the missing symlinks.

## Uninstalling

```bash
rm ~/.cursor/skills/forge
rm ~/.cursor/agents/{strategist,analyst,builder,validator,reviewer,auditor}.md
rm -rf ~/.cursor/forge
```
