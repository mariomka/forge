# Agent Guidelines

Forge is an orchestration skill for coding agents. It owns complex tasks end-to-end — running a discovery conversation, planning the approach, delegating work to specialized sub-agents, and verifying quality before shipping. This repo packages the skill and its sub-agents for every harness that can load local skills and agent definitions.

## Layout

- `skills/forge/` — the skill (`SKILL.md`) and the discovery protocol (`discovery.md`). These two files are the contract for how Forge operates.
- `agents/` — sub-agent definitions. Each file's body is a **prompt**, not documentation — every paragraph lands in a model's context, so keep them tight and behavior-shaping.
- `.claude-plugin/` — Claude Code `plugin.json` + `marketplace.json`.
- `.cursor-plugin/` — Cursor `plugin.json`.
- `.codex/INSTALL.md` — per-harness setup docs.

## Cross-Reference Hotspots

Editing one file usually means editing several. The common landmines:

- **Adding a new sub-agent** — create `agents/<name>.md`, then wire it into: SKILL.md (lifecycle if it has a phase, briefing, parallelize principle if it runs concurrently), `README.md` sub-agents list, and `.codex/INSTALL.md` symlink block.
- **Version bumps** — `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` must stay in sync. `.cursor-plugin/plugin.json` too.

## Rules

- No tests, CI, or dependencies. This is a markdown + JSON distribution.
- `CLAUDE.md` is a symlink to `AGENTS.md`. Don't turn it into a separate file.
