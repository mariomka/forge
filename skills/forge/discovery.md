# Discovery

Discovery is a conversation, not an interrogation. You're thinking through the problem *with* the user — proposing ideas, exploring tradeoffs, pushing back when something doesn't add up, letting the user redirect you. The goal is shared understanding of what "done" looks like and why. A ten-minute conversation saves an hour of rework.

<HARD-GATE>
Do NOT edit, create, or delete any file until discovery and approval are complete. `analyst` is allowed during discovery to understand the codebase — but no `builder`, no code changes.
</HARD-GATE>

<HARD-GATE>
**One question per turn. No exceptions.** Pick the single most important open thing, ask it, listen, follow the thread. Stacking multiple questions means the user answers the easy ones and the important ones get lost.

**Every question goes through the ask-user tool.** Questions buried in plain text get missed. If you need to set context (show code, explain options, lay out a tradeoff), output context as plain text, then ask via the tool. Use multiple-choice when the space of answers is finite, but always include "Other" so the user can redirect. Fall back to inline text only if no ask-user tool exists.
</HARD-GATE>

## Adaptive Scaling

Scale the conversation to the ambiguity of the task:

- **Vague or underspecified** — Fundamental questions open: *who* controls it, *how* it triggers, *what* the data source is. A short description doesn't mean a simple task. Dig until every ambiguous word maps to a concrete behavior.
- **Moderate ambiguity** (e.g. "refactor the auth system") — A handful of questions on scope, constraints, and what "better" means.
- **High ambiguity** (e.g. "improve performance") — A deeper conversation. What's slow? What's acceptable? What can't change? You may need to read code before you can ask the right questions.

Goal: enough shared understanding to define a testable outcome with concrete acceptance criteria.

## How Discovery Flows

Discovery is exploratory — you don't march through a checklist. But by the end you need:

- **The real problem**, not the symptom. "Add a button" is never the real problem.
- **What "done" looks like**, concretely enough that the validator can check it.
- **Scope boundaries** — what's in, what's explicitly out.
- **The decisions** strategist and builder can't infer from code: defaults, limits, interaction patterns, edge cases, structural choices.
- **The constraints** — things that must not change, dependencies, technical limits.

Moves that work well:

### Propose, don't interrogate

Instead of "what do you want this to do?", say: "I'm reading this as [interpretation] — is that right, or am I missing something?" Gives the user something concrete to react to and surfaces hidden assumptions on both sides.

### Think out loud

"I'd be tempted to do X because Y — but that might conflict with Z. What's your read?" beats silence followed by a leading question. Invites disagreement, which is when the good stuff comes out.

### Follow threads

When the user mentions something unexpected — a constraint, a related feature, a past incident — chase it before returning to your own agenda. The thread you didn't follow is the one that bites you in implementation.

### Read code early

Don't wait until all questions are answered. The moment you know the task area, read the code — or spawn `analyst` for a deep look. A question grounded in a specific file is worth five generic ones.

### Disagree when you should

If the user is about to ship a bad decision, say so. Be direct, not preachy. Discovery is your last chance to catch it before the plan locks in.

## Closing Discovery

When you have enough to start planning, don't jump to Approve. Give the user one more chance to steer:

1. Name one or two areas you **intentionally didn't dig into**. Examples: "I haven't pushed on behavior when X is empty", "We didn't talk about migration path for existing data", "I didn't ask about rollout — feature flag, cut-over, gradual?"
2. Ask via the ask tool: *"I think I have enough to start planning. Before I move on, do you want to go deeper on any of these — [list] — or anywhere else?"*
3. If the user picks one, loop back into the conversation on that topic. Don't limit them to the options you named.
4. If the user says no (or picks "move on"), transition to **Approve** in `SKILL.md`.

This is the only "keep talking?" checkpoint discovery has. Don't mix it with Approve — Approve is for confirming the summary and approach, not for squeezing in one more exploratory question.
