# Forge

An orchestration skill for coding agents. Forge takes ownership of complex tasks end-to-end — it helps you discover intent, then plans the approach, delegates the work to specialized sub-agents, and verifies quality before declaring the job done.

The goal: prevent the most expensive mistake in software — building the wrong thing, or building the right thing badly. Discovery costs minutes; rework costs hours.

Forge orchestrates sub-agents so the main context is almost never filled — each noisy step (code reading, planning, building, verification, review) runs in a fresh sub-agent with its own context window. What comes back is a concise synthesis, not a wall of tool output. In practice that means:

- **Longer tasks without running out of context** — the expensive reads and multi-file edits live in sub-agents that you throw away after each step.
- **Cleaner main conversation** — you see decisions and summaries, not `grep` output and `tsc` logs.
- **Better decisions** — each sub-agent is prompted for one narrow job, so it stays focused instead of drifting.
- **Parallel work when it's safe** — independent sub-agents run concurrently, which is only possible because they don't share context.

## How to Use

Just tell Forge what you want, using the slash command:

```text
/forge add a rate limiter to the public API
```

Forge will take it from there — starting with a discovery conversation, then planning, then execution, with explicit checkpoints along the way.

**The discovery conversation is where the real value lives.** Don't rush through it — treat it as a collaborator thinking out loud, not a form to fill in.

## Lifecycle

```
DISCOVERY → APPROVE → RESEARCH → PLAN → [RECONFIRM*] → EXECUTION → VERIFY
```

*\* Reconfirm only fires when the plan deviates from the approved approach. If it tracks, Forge skips straight to execution instead of asking for another rubber-stamp.*

## Sub-agents

Forge coordinates a team of specialized agents:

- **strategist** — turns goals into sequenced roadmaps
- **analyst** — investigates how the code works, and root-causes failures
- **builder** — builds the solution
- **validator** — validates against acceptance criteria with evidence
- **reviewer** — checks code quality
- **auditor** — security audit for sensitive surfaces (runs in parallel with reviewer)

## Installation

**Note:** Installation differs by platform. Claude Code and Cursor have built-in plugin marketplaces. Codex requires a small amount of manual setup.

### Claude Code (via Plugin Marketplace)

In Claude Code, register the marketplace first:

```bash
/plugin marketplace add mariomka/forge
```

Then install the plugin from this marketplace:

```bash
/plugin install forge@forge-marketplace
```

### Cursor

In Cursor Agent chat, install from the plugin marketplace:

```text
/add-plugin forge
```

Or search for "forge" in the plugin marketplace.

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/mariomka/forge/main/.codex/INSTALL.md
```

### Other harnesses

Forge works with any harness that can load local skills and agent definitions — point its loader at `skills/` and `agents/` in this repo. If you've wired up OpenCode, Gemini CLI, Copilot CLI, or another harness and want to contribute the integration, PRs welcome.
