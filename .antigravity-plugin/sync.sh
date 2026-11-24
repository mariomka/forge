#!/usr/bin/env bash
# Synchronizes upstream Forge definitions (agents/*.md and version) into
# Antigravity-native format (.antigravity-plugin/agents/*.md), links the
# plugin into ~/.gemini/config/plugins/forge, and installs Git post-merge
# and post-rewrite hooks so `git pull` automatically propagates upstream changes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UPSTREAM_AGENTS_DIR="$REPO_ROOT/agents"
AGY_AGENTS_DIR="$SCRIPT_DIR/agents"
CLAUDE_MANIFEST="$REPO_ROOT/.claude-plugin/plugin.json"
AGY_MANIFEST="$SCRIPT_DIR/plugin.json"

mkdir -p "$AGY_AGENTS_DIR"

# 1. Sync version from .claude-plugin/plugin.json if jq or python3 is available
if [[ -f "$CLAUDE_MANIFEST" && -f "$AGY_MANIFEST" ]]; then
  if command -v jq >/dev/null 2>&1; then
    UPSTREAM_VER="$(jq -r '.version // empty' "$CLAUDE_MANIFEST")"
    if [[ -n "$UPSTREAM_VER" ]]; then
      tmp="$(mktemp)"
      jq --arg v "$UPSTREAM_VER" '.version = $v' "$AGY_MANIFEST" > "$tmp" && mv "$tmp" "$AGY_MANIFEST"
    fi
  fi
fi

# 2. Convert every upstream agent in agents/*.md into .antigravity-plugin/agents/*.md
rm -f "$AGY_AGENTS_DIR"/*.md

for src in "$UPSTREAM_AGENTS_DIR"/*.md; do
  [[ -e "$src" ]] || continue
  fname="$(basename "$src")"
  name="${fname%.md}"

  awk '
    BEGIN { in_fm = 0; fm_done = 0; name = ""; desc = ""; tools_raw = "" }
    NR == 1 && /^---[ \t]*\r?$/ { in_fm = 1; next }
    in_fm && /^---[ \t]*\r?$/ {
      in_fm = 0; fm_done = 1
      # Map tools
      n = split(tools_raw, arr, ",")
      out_tools = ""
      seen_read = 0; seen_write = 0; seen_edit = 0; seen_run = 0; seen_task = 0; seen_web = 0
      for (i = 1; i <= n; i++) {
        gsub(/^[ \t]+|[ \t\r]+$/, "", arr[i])
        t = arr[i]
        if ((t == "Read" || t == "Glob" || t == "Grep") && !seen_read) {
          out_tools = out_tools (out_tools ? ", " : "") "read_file"; seen_read = 1
        } else if (t == "Write" && !seen_write) {
          out_tools = out_tools (out_tools ? ", " : "") "write_file"; seen_write = 1
        } else if ((t == "Edit" || t == "MultiEdit") && !seen_edit) {
          out_tools = out_tools (out_tools ? ", " : "") "edit_file"; seen_edit = 1
        } else if (t == "Bash") {
          if (!seen_run)  { out_tools = out_tools (out_tools ? ", " : "") "run_command"; seen_run = 1 }
          if (!seen_task) { out_tools = out_tools (out_tools ? ", " : "") "manage_task"; seen_task = 1 }
        } else if ((t == "WebSearch" || t == "WebFetch") && !seen_web) {
          out_tools = out_tools (out_tools ? ", " : "") "search_web"; seen_web = 1
        }
      }
      if (out_tools == "") {
        out_tools = "read_file, write_file, edit_file, run_command, manage_task, search_web"
      }
      print "---"
      print "name: " name
      print "description: " desc
      print "subagent: true"
      print "mainAgent: false"
      print "tools: [" out_tools "]"
      print "---"
      next
    }
    in_fm {
      sub(/\r$/, "")
      if ($0 ~ /^name:[ \t]*/) { sub(/^name:[ \t]*/, ""); name = $0 }
      else if ($0 ~ /^description:[ \t]*/) { sub(/^description:[ \t]*/, ""); desc = $0 }
      else if ($0 ~ /^tools:[ \t]*/) { sub(/^tools:[ \t]*/, ""); tools_raw = $0 }
      next
    }
    { print }
  ' "$src" > "$AGY_AGENTS_DIR/$fname"
done

echo "[Forge Antigravity] Synced sub-agents from upstream agents/*.md"

if [[ "${1:-}" == "--sync-only" ]]; then
  exit 0
fi

# 3. Link into ~/.gemini/config/plugins/forge
TARGET_PLUGIN_DIR="${HOME}/.gemini/config/plugins/forge"
mkdir -p "$TARGET_PLUGIN_DIR/.antigravity-plugin"

cp -f "$AGY_MANIFEST" "$TARGET_PLUGIN_DIR/.antigravity-plugin/plugin.json"
cp -f "$REPO_ROOT/README.md" "$TARGET_PLUGIN_DIR/README.md"
[[ -f "$REPO_ROOT/LICENSE" ]] && cp -f "$REPO_ROOT/LICENSE" "$TARGET_PLUGIN_DIR/LICENSE"

rm -rf "$TARGET_PLUGIN_DIR/skills" "$TARGET_PLUGIN_DIR/assets" "$TARGET_PLUGIN_DIR/agents"
ln -sfn "$REPO_ROOT/skills" "$TARGET_PLUGIN_DIR/skills"
ln -sfn "$REPO_ROOT/assets" "$TARGET_PLUGIN_DIR/assets"
ln -sfn "$AGY_AGENTS_DIR" "$TARGET_PLUGIN_DIR/agents"

echo "[Forge Antigravity] Linked plugin into $TARGET_PLUGIN_DIR"

# 4. Install Git post-merge & post-rewrite hooks
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"
if [[ -d "$GIT_HOOKS_DIR" ]]; then
  for hook in post-merge post-rewrite; do
    cat > "$GIT_HOOKS_DIR/$hook" <<'EOF'
#!/bin/sh
# Auto-sync Forge upstream changes to Antigravity plugin
REPO_TOP="$(git rev-parse --show-toplevel)"
if [ -x "$REPO_TOP/.antigravity-plugin/sync.sh" ]; then
  "$REPO_TOP/.antigravity-plugin/sync.sh"
elif command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -ExecutionPolicy Bypass -File "$REPO_TOP/.antigravity-plugin/sync.ps1"
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoProfile -ExecutionPolicy Bypass -File "$REPO_TOP/.antigravity-plugin/sync.ps1"
fi
EOF
    chmod +x "$GIT_HOOKS_DIR/$hook"
  done
  echo "[Forge Antigravity] Installed Git post-merge & post-rewrite hooks for automatic upstream sync."
fi
